# examples/

Worked examples that use the framework, or stand in for it.

## `hellishrc` — the standalone prompt engine

A single-file, dependency-free `~/.hellishrc`: 30 prompt themes, a context
collector layer, and an `hx` command suite. It is **self-contained** — it does
not need `~/.hellish/lib`, the plugin system, or anything else in this repo.
Copy it over `~/.hellishrc` and it works.

```sh
cp examples/hellishrc ~/.hellishrc
exec hellish
hx help
```

It is the counterpart to the repo's own `.hellishrc`, which is a ~60-line
loader for the modular `~/.hellish/` tree. Use whichever suits you:

|                | `.hellishrc` (framework) | `examples/hellishrc` (standalone) |
|----------------|--------------------------|-----------------------------------|
| shape          | loader + `rc.d/` + `plugins/` | one file |
| needs          | `~/.hellish/lib`         | nothing |
| extend by      | writing a plugin         | editing the file |
| prompt         | `rc.d/50-prompt.hsh`     | 30 themes, switchable at runtime |
| command        | `conf`, `hxp`            | `hx` |

The two coexist: the standalone file deliberately owns `hx` and never `hxp`,
so installing it does not shadow the plugin manager.

### What it does

```
hx                  status card             hx doctor      capability report
hx theme list       30 themes               hx bench [N]   prompt render cost
hx theme set NAME   switch, persisted       hx segments    every collected value
hx theme demo       all themes, live data   hx colors      palette + 256 ramp
hx conf             configuration           hx glyphs      unicode / nerd test card
hx conf set K V     write one key           hx keys        what this shell honors
```

Themes: `hellish` `minimal` `pure` `powerline` `agnoster` `lambda` `classic`
`bracket` `arrow` `dots` `matrix` `neon` `rails` `compact` `zen` `dev` `boxed`
`ascii` `hex` `night` `ocean` `sunset` `mono` `gitfocus` `kernel` `ops`
`status` `cyber` `pill` `quantum`.

Collected per prompt: exit code (named for signals — `SIGSEGV`, not `139`),
path, git (branch, dirty flags, ahead/behind, stash, worktree, merge/rebase
state), toolchain, virtualenv, kubernetes context, cloud profile, container,
multiplexer, ssh, jobs, load, battery, and command duration.

### Configuration

`~/.hellish/prompt.conf`, written and read by `hx conf`. Plain `KEY=VALUE`.

It is deliberately **not** `~/.hellish/hellish.conf` — that file belongs to the
plugin framework and uses a different grammar (`feature <name> on`). An earlier
version of this file wrote its own keys there and ate every enabled plugin.

### Design notes

The file is POSIX-parseable end to end — no arrays, no `[[ ]]`, no `${x//a/b}`
outside `eval` — so `dash`, `bash`, `zsh` and `hellish` all read it without a
syntax error even where they cannot execute every branch. Capability detection
is at runtime, so it degrades rather than breaks: no colour becomes plain text,
no UTF-8 becomes ASCII, no git drops the vcs segment.

Rendering a prompt starts no process it can avoid. Under a hellish that
publishes `HELLISH_GIT_*` (see below) it starts none: the hook measured
0-2 ms per prompt in a repository with ten submodules, where the old
collector (seven `git` calls per prompt) took 77 ms. Under bash and zsh the
git segment is one `git status --porcelain=v2` per prompt inside a
repository (6-9 ms there) and nothing outside one; the clock comes from
`printf '%(…)T'` or zsh's `%D`, and only dash still forks `date`. `hx bench`
reports the real figure.

### Running under hellish specifically

hellish reports `BASH_VERSION`, so the bash branch is the correct one to
take, but two things differ, and `hx doctor` names them:

| | hellish | bash |
|---|---|---|
| `bind` | not a builtin (use `~/.inputrc`) | works |
| repository state | `vcs_info` sets `HELLISH_GIT_*` from the shell's own background `git status` | a `git` process per question |
| right prompt | native `RPROMPT` (zsh syntax: `%` is doubled) | emulated with a padded `\r` |

The native path is detected, not assumed: a hellish that predates
`HELLISH_GIT_*` takes the same portable path as bash.

### Tests

```sh
hellish test/prompt.hsh
```

The theme registry, every theme rendering with and without colour, the
string helpers, the config whitelist, the clock, the preexec guard, and the
prompt hook itself: stand-in `git` and `date` binaries count what 20
prompts start (nothing under hellish, one `git status` each under bash),
and the git label is checked in a real repository -- staged, unstaged,
untracked, ahead, stash, a subdirectory, a detached HEAD -- with the native
and portable paths required to agree. It also runs under `bash`.
