# The prompt

Thirty themes, a token language to write more, and an engine that does almost
nothing per prompt because hellish does the work in C.

```sh
prompt                which theme is on, what it shows, what it costs
prompt list           all thirty, grouped by family
prompt preview        render every one with your real directory and branch
prompt gallery        the same, with descriptions and right prompts
prompt <name>         switch now
prompt save <name>    keep it for every new shell
prompt next | prev | random
```

`theme` is the same command.

---

## Choosing one

Start with `prompt preview`. It draws all thirty using your current directory
and git state, so you are comparing things you can read rather than names.

The families are a way of narrowing, not a taxonomy:

| family | the idea | try |
|---|---|---|
| `minimal` | the prompt is what you look *past* | `blade`, `pip` |
| `classic` | five shells' own defaults, reproduced | `classic`, `plain` |
| `frames` | spend a row to keep the cursor in one column | `vault`, `atrium` |
| `blocks` | filled colour reads as objects, not words | `powerline`, `slab` |
| `expressive` | pick the palette first | `ember`, `neon` |
| `focus` | each answers one question you ask all day | `cockpit`, `gitlab` |

Two worth calling out because they are unlike the rest:

- **`telemetry`** puts *everything* in the right prompt and leaves a single
  arrow on the left. Every command you type starts in column three, forever,
  and the shell erases the right side when your line grows into it.
- **`cockpit`** is the opposite: path, virtualenv, toolchain, full git
  summary, failure, duration and jobs, all at once.

## Making it yours without writing a theme

Every theme draws from five palette colours. Change one and all thirty
restyle:

```sh
prompt palette                        show them
prompt palette HX_PS_ACCENT 208       the colour themes lean on
prompt palette HX_PS_ERR 196          the colour of failure
prompt colors                         the 256-colour ramp, to pick a number
```

Other knobs, all persisted by `conf set`:

```sh
prompt nerd on            powerline triangles (needs a patched font)
conf set HX_PATH_STYLE smart     smart | short | fish | tail | full
conf set HX_PATH_MAX 4           components before the middle is elided
```

`HX_PATH_STYLE=smart` is the default and the interesting one: inside a git
work tree it shows the repository name and your path below it, because "which
repo, which file" is the actual question. `~/src/work/acme/backend/src/api`
becomes `backend/src/api`.

---

## Writing a theme

A theme is **one string**. Not a function, not a file of shell code.

```sh
prompt new mine
prompt edit mine
```

That appends a starting point to `~/.hellish/themes/90-local.hsh`, which is
yours and is never overwritten by an upgrade. The full form:

```sh
hx_theme <name> <family> '<needs>' '<description>' '<ps1>' ['<right prompt>']
```

A real one, from the shipped set:

```sh
hx_theme vault frames 'path' 'rounded two-row frame; repo-relative path' \
    '{f:238}{tl}{h}{r} {f:117}{bold}{path}{/bold}{r} {f:244}{git}{r}{f:203}{fail}{r}{nl}{f:238}{bl}{h}{r} {stf}{arr}{r} ' \
    '{f:238}{time}{r}'
```

Read that as: faint corner, bold blue path, grey branch, red failure badge,
newline, faint corner, an arrow coloured by the last exit status. The clock
goes on the right.

### The tokens

`prompt tokens` prints this table in your terminal, which is the copy that
cannot go stale.

**Colour**

| token | meaning |
|---|---|
| `{f:117}` `{b:24}` | foreground / background, any 256-colour index |
| `{/f}` `{/b}` `{r}` | end foreground / background / everything |
| `{bold}{/bold}` | also `{ul}{/ul}`, `{rev}{/rev}` |

**Reacts to the last command** — these are free, the renderer evaluates them:

| token | meaning |
|---|---|
| `{stf}` | green when it succeeded, red when it did not |
| `{stb}` | the same, as a background |
| `{stg}` | a tick or a cross |
| `{priv}` | `$` normally, `#` as root |

**Where you are**

| token | meaning |
|---|---|
| `{cwd}` | `~/full/path` |
| `{cwd:2}` | the last two components |
| `{base}` | just the directory name |
| `{cwdt:40}` | truncated to 40 columns, elided at the front |
| `{path}` | smart, repo-relative — **needs `path`** |

**Badges** — each renders *nothing at all* when it has nothing to say, so your
prompt stays quiet in a clean tree:

| token | meaning |
|---|---|
| `{git}` | branch, `*` when dirty. Free: hellish renders it in C |
| `{fail}` | `✘` and the exit code, after a failure |
| `{took}` | how long the last command ran, once it passes 2s |
| `{jobsb}` | background job count, while there are any |
| `{upd}` | a pending hellish release |

**Computed segments** — these cost real work, so you must list them in
`needs`:

| token | needs | cost |
|---|---|---|
| `{vcs}` | `vcs` | one `git status --porcelain=v2` per prompt |
| `{venv}` `{lang}` `{ctx}` | each | none — string work only |
| `{rule}` | `rule` | one `tput cols` per prompt |
| `{load}` | `load` | none — reads `/proc/loadavg` |

`{git}` and `{vcs}` are not the same thing. `{git}` is hellish's own `\g`
escape: the branch name and a dirty marker, rendered in C, free. `{vcs}` is
the full summary — `main +2 ~1 ?3 ↑1` — branch, staged, dirty, untracked,
conflicts, ahead and behind, for one git process per prompt.

**Facts and glyphs**

`{user}` `{host}` `{jobs}` `{time}` `{secs}` `{date}` `{day}` `{nl}` `{sp}`

Glyphs all have an ASCII twin, so a theme still renders on a terminal without
UTF-8: `{arr}` `{tl}` `{tr}` `{bl}` `{br}` `{h}` `{v}` `{dot}` `{dia}` `{lam}`
`{star}` `{bolt}` `{b1}` `{b2}` `{b3}` `{sep}` and about thirty more.

### Rules that will bite you

**List every segment you use in `needs`.** A theme that interpolates `{vcs}`
without declaring `vcs` renders an empty gap forever, because the hook never
computes it. The test suite checks both directions — using an undeclared
segment, and declaring one you never use, which buys a git process per prompt
and throws it away.

**A literal percent is `%%`.** A single `%` starts a prompt escape.

**Do not use `$(...)`.** hellish never expands command substitution in a
prompt — it renders `$(date)` literally, forever. This is the single most
common way to write a broken theme. Anything dynamic goes through a computed
segment instead, which is what `needs` is for.

---

## How it actually works

Worth knowing if you are extending it, and skippable otherwise.

hellish renders prompts itself, in C, and its renderer speaks two languages at
once: zsh's percent escapes (`%F{117}`, `%~`, `%(?.ok.bad)`) and hellish's own
self-spacing badges (`\g`, `\S`, `\p`, `\J`, `\U`). Between them, most themes
here need no shell code whatsoever and cannot be slow. `%(?...)` alone removes
the "recolour the arrow by exit status" function that every dotfiles repo
reimplements.

The token layer exists so that one palette change restyles everything, an
8-colour terminal degrades to sensible hues instead of a smear, and a terminal
without UTF-8 gets `+--+` rather than a row of tofu. Tokens are expanded once,
when a theme is applied — not per prompt.

Three renderer behaviours decide the whole design. All three are verified
against your actual binary by `test/prompt.hsh`, so if a release changes one,
the suite fails and names the assumption that died:

1. **`$( )` is never expanded** in a prompt. `${VAR}` and `$((...))` are, at
   every render. Hence computed segments.
2. **Text arriving out of a variable is inert** — escapes, `%F{n}`, `\g` and a
   bare `%` all render as themselves. So segments hold plain text and the
   theme supplies the colour, which is also what keeps hellish's width
   arithmetic exact.
3. **`print -rP` disagrees with the renderer** on rule 2: it re-scans. A
   directory called `50%off` previews as `50ff`. The preview path escapes
   segments and restores them afterwards, so what you preview is what you get.
   Reported upstream as [hellish#134](https://github.com/Univers42/hellish/issues/134).

`prompt doctor` reports what your terminal and your hellish support, and what
the active theme costs per prompt:

```
  per-prompt cost of the active theme
    path
```

Most themes report nothing there. That is the point.
