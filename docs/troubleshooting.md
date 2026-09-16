# When something is wrong

Four commands answer most of it. Run them in this order.

```sh
conf doctor      load errors, missing dependencies, known interpreter gaps
conf caps        what your hellish can actually do
prompt doctor    what your terminal and hellish support for prompts
hxp doctor       plugins missing their external commands
```

---

## My shell prints an error at every prompt

```
hellishrc: 2 problem(s) during load — run: conf doctor
```

`conf doctor` lists them under **load errors**. The usual causes:

- a file in `rc.d/` or a plugin has a syntax error — `hellish -n <file>` tells
  you the line
- `hellish.conf` names a feature that no longer exists
- a theme named in `hellish.conf` was deleted; the loader falls back to
  `vault` and records it

## My prompt is broken or empty

```sh
prompt doctor
prompt vault        switch to a known-good theme
prompt list
```

If `prompt doctor` says your colour depth is `none` or unicode is `0`, that is
your terminal, not the theme: check `TERM` and that your locale ends in
`UTF-8`.

**Boxes render as `?` or blank squares.** Your font or terminal is not showing
the box-drawing characters. Themes fall back to ASCII automatically when the
locale is not UTF-8, so force it:

```sh
conf set HX_UNICODE 0 && conf reload
```

**Powerline separators are empty rectangles.** Those are private-use
codepoints that only exist in a patched font. Turn them off:

```sh
prompt nerd off
```

**My prompt shows `$(something)` literally.** hellish never expands command
substitution in a prompt. Use a computed segment instead — see
[the prompt guide](prompt.md#rules-that-will-bite-you).

**A segment is always empty.** The theme interpolates something it did not
declare in `needs`, so the hook never computes it. `prompt doctor` shows what
the active theme asked for.

**My prompt is slow.** `prompt doctor` reports the per-prompt cost. `vcs` is a
git process per prompt; `rule` is a `tput cols`. A theme using neither costs
nothing — `prompt blade` is the extreme case.

## A command hangs with no output

Almost always the `-i` safety alias. `rm`, `mv`, `cp` and `ln` prompt before
overwriting, and inside a function or a script that prompt can go somewhere
you are not looking.

```sh
command mv a b      bypass the alias for one call
\mv a b             the same
```

If it is your own function, that is the bug: see
[the alias hazard](architecture.md#the-alias-hazard). `forge lint` catches it.

## A plugin's commands do not exist

```sh
hxp list            is it on?
conf on git && conf reload
hxp doctor          is it missing an external command?
hxp info git        what it should be defining
```

A plugin whose dependency is missing still loads — it degrades rather than
exploding — so the functions exist but fail when run. `hxp doctor` is the
check.

## TAB completion does nothing

```sh
conf caps | grep complete
```

If `builtin_complete` is `✘`, your hellish predates the `complete` builtin and
the wordlists are recorded but not installed. They will install themselves the
day you upgrade — nothing to change.

If it is `✔`, check that `progcomp` is armed; the completion module does that
for you, so if it is not, the module is off:

```sh
conf on completion && conf reload
```

## `@(a|b)` is a syntax error even though `shopt` says extglob is on

That is a real hellish bug, not your code. `shopt -s extglob` is accepted and
`shopt extglob` then reports `on`, but the pattern operators are a **lexer**
error — so the file containing them never parses, and you cannot guard against
it with `shopt -q` from inside that same file.

Use a `case` with ordinary patterns, or `grep -E`. Filed upstream as
[hellish#134](https://github.com/Univers42/hellish/issues/134).

## My `~/.hellish` edits keep disappearing

Only two files are yours and are never overwritten by an upgrade:

```
~/.hellish/rc.d/99-local.hsh      your aliases, functions, overrides
~/.hellish/themes/90-local.hsh    your prompt themes
```

Anything else in `lib/`, `rc.d/`, `themes/` or `plugins/` is framework and
*will* be replaced on the next install. Put your changes in the two files
above — `99-local.hsh` loads last, so it wins over everything.

For secrets or work-only settings that should not be in version control,
`99-local.hsh` already sources `~/.hellish/private.hsh` when it exists.

## I want to check something without touching my real config

`HX_HOME` is the only knob; the state and config paths derive from it.

```sh
sh install.sh --home /tmp/sbox --plugins all
HX_HOME=/tmp/sbox/.hellish HX_RC=/tmp/sbox/.hellishrc \
    hellish /tmp/sbox/.hellish/test/run.hsh
```

## My whole shell is broken and I cannot fix it from inside it

hellish is your login shell, so a broken `lib/*.hsh` means every new terminal
is broken. The escape hatches, in increasing order of permanence:

```sh
HELLISH_NO_EXEC=1 <terminal>     one session in your previous shell
touch ~/.hellish-disable         every new session, until you delete it
```

Both are checked by the block in `~/.zshrc`, before it execs hellish. From
another machine, since your passwd shell is untouched:

```sh
ssh you@host 'touch ~/.hellish-disable'
```

To reinstall the framework over a broken tree:

```sh
cd /path/to/hellishrc_plugins && sh install.sh --plugins all
```

That keeps `99-local.hsh` and `90-local.hsh` and replaces everything else.

## Nothing above helped

```sh
conf doctor          load errors and gaps
conf modules         what actually loaded, in order
conf profile         reload with per-module timings — finds the slow one
HX_DEBUG=1 hellish   verbose load
hellish -n <file>    syntax-check one file without running it
```

`hellish ~/.hellish/test/run.hsh` runs 169 assertions against your live
configuration and is the fastest way to find out whether the problem is yours
or the framework's.
