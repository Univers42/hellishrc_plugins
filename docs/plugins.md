# Plugins

A plugin is a directory with one file in it. Eight ship here, and anything on
GitHub that is a single shell file can be added to the catalog in one line.

```sh
hxp list              what is installed, and whether it is on
hxp info git          one plugin in detail: purpose, dependencies, what it defines
hxp catalog           everything installable, installed or not
hxp install z         fetch an external one
hxp doctor            plugins missing their external commands
conf on|off <name>    toggle, persisted
```

---

## What ships

| plugin | what it is for |
|---|---|
| `git` | repo overview, safe undo, wip commits, branch cleanup |
| `jump` | frecency directory jumping (`j`), plus named bookmarks |
| `devkit` | one set of verbs — `build` `run` `test_` `fmt` `lint` — for any project type |
| `clean` | report and reclaim regenerable space in your home directory |
| `docker` | container and image overview, shell-in, compose shortcuts, prune |
| `net` | ports, addresses, DNS, HTTP timing, waiting for a port |
| `sentinel` | system dashboard: load, memory, disk, hungry processes |
| `forge` | the plugin toolkit — scaffold, lint and document plugins |

`hxp info <name>` lists exactly what each one defines. The [reference](reference.md)
has all of them in one page.

## Installing an external plugin

The catalog carries proven third-party plugins — oh-my-zsh's `sudo`,
`extract`, `dirhistory` and `colored-man-pages`, git's own `git-completion`
and `git-prompt`, `bash-preexec`, and `z`.

```sh
hxp catalog
hxp install omz-web-search
conf reload
```

A `.zsh` file is fetched **keeping its extension**, and that is load-bearing:
hellish arms its zsh dialect when it sources a path ending in `.zsh` and
disarms it at the end of the file. A real oh-my-zsh plugin therefore parses as
zsh without any shim, and without the wrapper mentioning dialects at all.

Adding a plugin to the ecosystem is one tab-separated line in
`plugins/catalog.tsv`:

```
name<TAB>kind<TAB>url<TAB>default<TAB>description
```

`kind` is `builtin`, `zsh` or `sh`. Both the framework installer and `hxp
install` read that one file, so there is exactly one definition of how a
plugin is fetched.

---

## Writing your own

```sh
hxp new mytool          scaffold it
forge lint mytool       check it against the contract
conf on mytool && conf reload
```

The scaffold is a *working* plugin, not a stub full of TODOs — you can enable
it immediately and it does something.

### The contract

The first executable line must be:

```sh
hx_plugin <name> <on|off> <group> "one-line description" || return 0
```

`hx_plugin` registers the plugin as a toggleable feature and returns non-zero
when the user has it switched off, so `|| return 0` skips the rest of the file
at no cost. Everything after that line may assume the plugin is enabled.

`<group>` is one of `core ui vcs dev nav net sys ai` — it only decides where
`conf list` files it.

### Declaring what you provide

This is not optional bookkeeping. The registry is what `help_conf`, `hxp
info`, the completion module and the generated [reference](reference.md) all
read. A function you do not register is invisible to every one of them.

```sh
mytool_run() { ...; }
hx_func_doc mytool_run "what it does" "mytool_run <arg>"

hx_alias_doc mt   "short for mytool_run"
hx_var_doc   MYTOOL_HOME "where mytool keeps its state"
```

`declare -F` can list function *names* on a recent hellish. It cannot say what
yours is for, who owns it, or how to call it — that exists only because you
wrote it down.

### Dependencies

```sh
hx_needs curl jq          # declare them; never fatal
hx_have curl || return 0  # guard one optional command inside a function
```

A missing command never fails the load. A plugin degrades; it does not
explode. What is missing shows up in `hxp doctor` and `conf doctor`.

### Hooks

```sh
_mytool_precmd() { :; }
hx_hook_add precmd  _mytool_precmd     # before every prompt
hx_hook_add preexec _mytool_log        # before each typed line; "$1" is the line
```

These compose. hellish 2.9+ has native hook arrays (`HELLISH_PRECMD_FUNCS`),
and `hx_hook_add` uses them when they exist and falls back to a
`PROMPT_COMMAND` dispatch list when they do not — you write the same line
either way. `hx_hook_del` unregisters, so a plugin can switch itself off
without a reload.

Never install a `trap ... DEBUG` for this. There is exactly one DEBUG handler,
so the second plugin to install one silently removes the first and neither can
tell.

### Completion

```sh
hx_complete mytool run status help
```

On a hellish with `complete` this installs immediately and reaches TAB. On an
older one it is recorded and installs itself the day you upgrade. Same line
either way.

### Asking what the shell can do

Never branch on a version number:

```sh
hx_cap builtin_complete && ...
hx_cap rprompt          && ...
hx_cap extglob          || ...   # still broken on every release so far
conf caps                        # the whole probe
```

See [architecture](architecture.md#capabilities) for why this exists.

---

## The rules that actually bite

Each of these cost someone a debugging session.

**Never call `rm`, `mv` or `cp` bare inside a function.** `30-aliases.hsh`
defines them with `-i`, and an alias is expanded when a file is **parsed** —
so every module and plugin loaded after it is parsed with those aliases live.
A function containing `mv "$a" "$b"` silently becomes `mv -i "$a" "$b"` and
blocks on a prompt nobody can see. Write `command mv`. `forge lint` fails you
for this and the test suite has a regression guard, because it has happened
more than once — including inside the test suite itself.

**Never give a function the same name as an alias.** The alias expands inside
`name() {` and the definition becomes a syntax error. Nothing warns you; the
plugin just silently fails to load. The suite checks for collisions.

**Never call an alias from a function.** Call the real command.

**Prefix private helpers** `_<plugin>_<thing>` so two plugins cannot collide.

**A prompt cannot expand `$( )`.** If your plugin sets `PS1`, compute into a
variable from a precmd hook instead. `forge lint` checks this too.

**Single-quote a prompt.** In double quotes `$?` expands once, when you assign
it, and is frozen for the session.

`forge lint` knows all of these. It also knows which interpreter gaps are real
on *your* binary — the rules about `local -n`, `printf %q` and `[ -v ]` were
unconditional once, and by hellish 2.10 every one of them was wrong. A linter
that fails you for things that work is a linter you learn to ignore.

```sh
forge lint              every plugin
forge lint mytool       just yours
forge api               the whole contract, in the terminal
forge doc mytool        regenerate its README from the live registry
```
