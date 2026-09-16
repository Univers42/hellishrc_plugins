# How it works

You do not need this page to use the configuration. You need it to change one
safely.

---

## The tree

```
~/.hellishrc          the loader — deliberately tiny
~/.hellish/
  lib/                the framework      ui · core · plugin · conf · prompt
  rc.d/               config modules     10-env … 99-local, in lexical order
  themes/             30 prompt themes   six families + 90-local.hsh
  plugins/            one directory each + catalog.tsv
  bin/                hx-fetch-plugin · hx-clean · hx-gendoc
  hellish.conf        which features are on
  state/              jump db, marks, capability cache — never committed
  test/               run.hsh · prompt.hsh
```

## Load order, and why it is what it is

`~/.hellishrc` does ten things, in this order, and each step depends on the
one before it:

1. **`lib/ui.hsh`** — colours and glyphs. First because everything prints.
2. **`lib/core.hsh`** — the registry and the capability probe.
3. **`lib/plugin.hsh`**, **`lib/conf.hsh`** — the plugin contract and the
   `conf` command.
4. **`hx_caps_load`** — what this hellish can do. Before any module, because
   modules branch on it.
5. **`hx_conf_load`** — your saved on/off state. Before any module, so
   `hx_guard` can see it and a disabled module can skip its own body.
6. **`hx_color_init` / `hx_glyph_init` again** — `hellish.conf` may have set
   `HX_COLOR` or `HX_NERD`, and the tables were built before it was read.
7. **`lib/prompt.hsh`** — after `conf`, so the palette variables are in place.
8. **`rc.d/*`** — lexical order: `10-env`, `20-options`, `30-aliases`,
   `40-functions`, `50-prompt`, `60-history`, `70-completion`, `80-ai`,
   `99-local`.
9. **plugins** — after `rc.d`, so a plugin can use anything a module defined.
10. **errors** — reported once, quietly, pointing at `conf doctor`.

Two ordering facts have bitten and are worth stating plainly:

- **`40-functions.hsh` cannot call `hx_complete`**, which `70-completion.hsh`
  defines. Doing so printed `command not found` on every shell start. The
  completions for functions live in the completion module.
- **`30-aliases.hsh` runs before everything else that defines a function**,
  and an alias is expanded at *parse* time. See [the alias hazard](#the-alias-hazard).

`conf modules` prints the real load order of your shell. `conf profile`
re-loads with per-module timings.

---

## The registry

Every module declares what it provides:

```sh
hx_feature <name> <on|off> <group> "description"     a toggleable unit
hx_func_doc  <name> "description" ["usage"]          something it defines
hx_alias_doc / hx_var_doc / hx_opt_doc / hx_cmd_doc
```

That declaration is the single source of truth for `help_conf`, `conf list`,
`hxp info`, the completion wordlists, the generated [reference](reference.md)
and the test suite. Nothing is discovered; everything is declared.

This began as a workaround. hellish 2.7.6 returned nothing from `declare -F`
and `alias -p`, so no code could find out what the configuration had defined.
Introspection works now — but the registry stayed, because it carries what
introspection never could: a description, a usage line, and which module owns
the name.

The test suite asserts the registry is honest in both directions: every
registered function must exist, and every registered item must have a
description.

### `hx_aset`

Every subscripted array write goes through one function:

```sh
hx_aset HX_FEAT_STATE "$name" on
```

On hellish 2.7.6 a subscripted write from a function *defined in a sourced
file* was parsed as a command, not an assignment, which would have killed the
whole registry. That is fixed (`hx_cap assoc_sourced`), and `hx_aset` remains
for two reasons: it still works on an old binary, and having exactly one choke
point is what lets `hx_key_ok` guarantee no key is ever re-parsed.

Keys are generated, never user input, and `hx_key_ok` rejects anything with
whitespace or a shell metacharacter in it.

---

## Capabilities

**Never branch on a version number.** Ask what the shell can do.

```sh
hx_cap builtin_complete      true when `complete` exists
hx_cap rprompt               true when RPROMPT is honoured
hx_cap_get version           the version string, if you really need it
conf caps                    every probe and its verdict
conf caps -r                 re-probe (after `update --now`)
```

This exists because the configuration was written against hellish 2.7.6 and
aged badly. By 2.10 most of those gaps had closed, and the config was still
routing around them — refusing to install completions that worked, and failing
`forge lint` on plugins for using `local -n` and `printf %q`, both fixed two
releases earlier. A linter that fails you for things that work is a linter you
learn to ignore.

The probe runs once and is cached in `state/capabilities`, keyed on the
binary's **identity** (`mtime:size`) rather than its version string — a
locally built hellish reports the same version as the release it came from and
would otherwise be served a stale verdict.

Some probes must run out of process. `shopt -s extglob` is accepted and then
reports `on`, but `@(a|b)` is a **lexer** error, so the file containing it
never parses:

```sh
if shopt -q extglob; then         # true
    case $x in @(a|b)) ... ;; esac    # the whole FILE fails to parse
fi
```

You cannot feature-detect your way out of that from inside the file, which is
why the probe shells out.

---

## Hooks

```sh
hx_hook_add precmd  <function>     before every prompt
hx_hook_add preexec <function>     before each typed line; "$1" is the line
hx_hook_del precmd  <function>     unregister
```

hellish 2.9+ has native hook arrays — `HELLISH_PRECMD_FUNCS` and
`HELLISH_PREEXEC_FUNCS` — and they are the right mechanism, because arrays of
function names **compose**. `PROMPT_COMMAND` is one string and appending to it
is string surgery on something another plugin may also be appending to;
`trap ... DEBUG` holds exactly one handler, so the second plugin to install
one silently removes the first.

`hx_hook_add` uses the native arrays where they exist and falls back to the
`PROMPT_COMMAND` dispatch list where they do not. A plugin calls it and never
has to know which. `_hx_precmd_run` returns immediately when the native arrays
are in use, so nothing runs twice.

hellish preserves `$?` across the hooks, so a prompt with a status badge still
shows *your* command's result rather than the hook's.

---

## The alias hazard

`30-aliases.hsh` defines `rm`, `mv`, `cp` and `ln` with `-i`. This is the one
place the configuration is deliberately not minimal: an interactive shell
should ask before it destroys something.

The hazard is that **hellish expands aliases when it parses a file**, and
every module and plugin sourced afterwards is parsed with those aliases live.
So a function containing `mv "$a" "$b"` silently becomes `mv -i "$a" "$b"` and
blocks on a prompt nobody sees.

Every such call in this configuration is therefore `command mv` / `command rm`
/ `command cp`. `forge lint` enforces it, and `test/run.hsh` greps `lib`,
`plugins`, `rc.d`, `themes` **and `test`** for violations.

That last directory is in the list because leaving it out is exactly how the
suite once hung forever: `cp "$HX_CONF" "$(mktemp)"` prompts to overwrite,
since `mktemp` has already created the destination, and the prompt went to a
stdout nobody was watching. The suite enforced the rule everywhere except on
itself.

The related trap: **an alias whose name matches a function** makes that
function's definition a syntax error, because the alias expands inside
`name() {`. Nothing warns you — the plugin just silently fails to load. The
suite checks for collisions.

---

## Sandboxing

`HX_HOME` is the single knob. `HX_CONF` and `HX_STATE` are **derived** from
it, never defaulted with `:-`:

```sh
HX_HOME="${HX_HOME:-$HOME/.hellish}"
HX_CONF="$HX_HOME/hellish.conf"
HX_STATE="$HX_HOME/state"
```

All three are exported, so every child inherits them. With
`${HX_CONF:-$HX_HOME/hellish.conf}` the inherited value would win, and a run
against a throwaway tree would quietly read and *write* your real
`~/.hellish/state`. It did exactly that during development.

To test against a scratch tree:

```sh
HX_HOME=/tmp/sbox/.hellish HX_RC=/tmp/sbox/.hellishrc hellish /tmp/sbox/.hellish/test/run.hsh
```

There is a regression guard for this in the suite.

---

## The prompt engine

Covered in [the prompt guide](prompt.md#how-it-actually-works). The short
version: hellish renders prompts in C and speaks both zsh percent escapes and
its own self-spacing badges, so a theme is one string rather than a function
that runs per prompt. Computed data goes through variables filled by a precmd
hook, because a prompt never expands `$( )`. Themes declare what they need and
the hook computes exactly that set.

---

## Testing

```sh
hellish ~/.hellish/test/run.hsh        169 assertions
hellish ~/.hellish/test/run.hsh -v     show every passing one
hellish ~/.hellish/test/prompt.hsh     the theme engine alone
```

The suite loads your **real** `~/.hellishrc` and asserts against the live
registry, so it tests what you actually run rather than a copy.

Two categories are worth knowing about:

- **Regression guards** for things that shipped broken once: the alias leak,
  alias/function collisions, the `HX_HOME` inheritance bug.
- **Contract assertions** against the running binary. `test/prompt.hsh`
  re-checks that `$( )` is still not expanded, that variable content is still
  inert, and that `print -rP` still disagrees with the renderer. If a release
  changes one, the suite fails and names the assumption that died rather than
  silently rendering wrong.

A plugin that is switched off is a **skip**, not a failure. Asserting the
functions of a plugin the user turned off reported 16 failures on a perfectly
healthy install.

---

## Regenerating the docs

```sh
hellish ~/.hellish/bin/hx-gendoc > docs/reference.md
```

The exhaustive tables are generated from the live registry; the prose is
written by hand. If a name in the reference is wrong, fix the `hx_func_doc`
call next to the code and regenerate — never edit `reference.md`.
