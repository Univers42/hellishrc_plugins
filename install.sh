#!/bin/sh
# hellishrc_plugins installer — set up ~/.hellish and wire ~/.hellishrc.
#
#   sh install.sh                          interactive
#   sh install.sh --plugins all            everything the catalog defaults on
#   sh install.sh --plugins none           framework only, all plugins off
#   sh install.sh --plugins choose         ask y/n per plugin (needs a tty)
#   sh install.sh --plugins "git jump z"   exactly these
#   sh install.sh --home DIR               install under DIR (tests)
#
# hellish's own `curl | sh` installer calls this with the user's answers, but
# it stands alone: clone the repo and run it, and you get the same result.
#
# What it will NEVER do is eat your configuration. An existing ~/.hellishrc
# that is not already our loader is copied verbatim into
# ~/.hellish/rc.d/95-previous-rc.hsh -- so it keeps loading, after the
# framework, exactly as before -- and the original is also kept beside itself
# as ~/.hellishrc.pre-hellish-<date> for good measure.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET_HOME="$HOME"
PLUGINS="ask"

say() { printf '\033[1;36mhellish-plugins:\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mhellish-plugins:\033[0m %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
	case "$1" in
	--home)    shift; [ $# -gt 0 ] || die "--home needs a directory"; TARGET_HOME="$1" ;;
	--plugins) shift; [ $# -gt 0 ] || die "--plugins needs a value"; PLUGINS="$1" ;;
	--plugins=*) PLUGINS="${1#--plugins=}" ;;
	-h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
	*) die "unknown argument '$1'" ;;
	esac
	shift
done

HX="$TARGET_HOME/.hellish"
RC="$TARGET_HOME/.hellishrc"
CATALOG="$HERE/plugins/catalog.tsv"
[ -f "$CATALOG" ] || die "no plugins/catalog.tsv next to this script"

# The tty probe runs in a SUBSHELL on purpose: `:` is a POSIX special
# builtin, and a failed redirection on a special builtin is fatal to a
# non-interactive shell -- even inside an `if`. The subshell dies instead.
TTY=0
if ( exec </dev/tty ) 2>/dev/null; then TTY=1; fi
[ "$PLUGINS" = "ask" ] && { [ "$TTY" = "1" ] && PLUGINS="choose" || PLUGINS="all"; }
[ "$PLUGINS" = "choose" ] && [ "$TTY" = "0" ] && PLUGINS="all"

# ── 1. the framework itself ─────────────────────────────────────────────────
# themes/ and docs/ are part of the framework, not optional extras: the prompt
# module loads $HX_HOME/themes and `guide` reads $HX_HOME/docs, so an install
# without them boots with no prompt theme and a help command that points at
# nothing.
#
# Two files are the user's and are never overwritten once they exist:
# rc.d/99-local.hsh (machine overrides) and themes/90-local.hsh (own themes).
# Both say so in their first lines; this is what makes that true on upgrade.
mkdir -p "$HX"
for d in lib rc.d bin test themes docs; do
	mkdir -p "$HX/$d"
	for f in "$HERE/$d/"*; do
		[ -e "$f" ] || continue
		case "$d/${f##*/}" in
		rc.d/99-local.hsh|themes/90-local.hsh)
			[ -e "$HX/$d/${f##*/}" ] && continue ;;
		esac
		cp "$f" "$HX/$d/"
	done
done
chmod +x "$HX/bin/"* 2>/dev/null || true
mkdir -p "$HX/plugins" "$HX/state"
cp "$CATALOG" "$HX/plugins/catalog.tsv"

# ── 2. plugin selection ─────────────────────────────────────────────────────
# Builtin plugins are copied and toggled in hellish.conf; externals are
# fetched by bin/hx-fetch-plugin. One catalog drives both.
chosen=""
case "$PLUGINS" in
none) ;;
all)
	# tr, because has() matches on spaces and awk prints newlines
	chosen="$(grep -v '^#' "$CATALOG" | awk -F'\t' '$4 == "on" { print $1 }' | tr '\n' ' ')" ;;
choose)
	say "pick your plugins (Enter takes the default):"
	while IFS='	' read -r name kind _url def desc; do
		case "$name" in ''|'#'*) continue ;; esac
		if [ "$def" = "on" ]; then _p="[Y/n]"; else _p="[y/N]"; fi
		printf '  \033[1m%-22s\033[0m %s %s ' "$name" "$desc" "$_p" >/dev/tty
		IFS= read -r _a </dev/tty || _a=""
		case "$_a" in
		[yY]*) chosen="$chosen $name" ;;
		[nN]*) ;;
		*) [ "$def" = "on" ] && chosen="$chosen $name" ;;
		esac
	done < "$CATALOG" ;;
*)
	chosen="$PLUGINS" ;;
esac

has() { case " $chosen " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

conf="$HX/hellish.conf"
if [ ! -f "$conf" ]; then
	{
		printf '# ~/.hellish/hellish.conf -- written by the installer.\n'
		printf '# One directive per line: feature <name> <on|off>, set <VAR> <value>.\n'
	} > "$conf"
fi

installed=""; skipped=""
while IFS='	' read -r name kind url def desc; do
	case "$name" in ''|'#'*) continue ;; esac
	if [ "$kind" = "builtin" ]; then
		mkdir -p "$HX/plugins/$name"
		cp "$HERE/plugins/$name/"* "$HX/plugins/$name/" 2>/dev/null || true
		if has "$name"; then st=on; else st=off; fi
		# replace-or-append keeps the file one line per feature
		grep -v "^feature $name " "$conf" > "$conf.tmp" 2>/dev/null || true
		printf 'feature %-16s %s\n' "$name" "$st" >> "$conf.tmp"
		mv "$conf.tmp" "$conf"
		[ "$st" = "on" ] && installed="$installed $name"
	elif has "$name"; then
		if sh "$HX/bin/hx-fetch-plugin" "$name" --home "$TARGET_HOME" >/dev/null 2>&1; then
			installed="$installed $name"
		else
			skipped="$skipped $name"
		fi
	fi
done < "$CATALOG"

# ── 3. wire ~/.hellishrc, without eating anything ───────────────────────────
if [ -f "$RC" ] && ! grep -q 'HX_HOME=' "$RC" 2>/dev/null; then
	_stamp="$(date +%Y%m%d-%H%M%S)"
	cp "$RC" "$RC.pre-hellish-$_stamp"
	{
		printf '# rc.d/95-previous-rc.hsh -- your pre-framework ~/.hellishrc,\n'
		printf '# preserved by the installer on %s. Still loads, after the\n' "$_stamp"
		printf '# framework, exactly as before. Delete when absorbed.\n'
		cat "$RC"
	} > "$HX/rc.d/95-previous-rc.hsh"
	say "kept your old ~/.hellishrc (as rc.d/95-previous-rc.hsh + a backup)"
fi
cp "$HERE/.hellishrc" "$RC"

say "installed -> $HX"
[ -n "$installed" ] && say "plugins on:$installed"
[ -n "$skipped" ] && say "could not fetch (offline?):$skipped -- retry later with: hxp install <name>"
say "open a new shell, then: conf list · hxp list · help_conf"
