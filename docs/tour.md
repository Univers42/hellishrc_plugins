# The first ten minutes

There are two hundred-odd things in this configuration. You do not need them. This page is
the twenty or so that earn their place on day one, in the order you are likely
to want them.

Everything here is already loaded. Type it and it works.

---

## 1. Find out what you have

Three commands, and they are the reason you never have to read the source:

```sh
help_conf                 every alias, function and variable, documented, paged
help_conf -s branch       search all of it — names and descriptions
help_conf functions       just one section
```

`help_conf -s` is the one to remember. You do not have to know a name to find
it — search for what you are trying to do.

```sh
$ help_conf -s archive
  func   extract            extract any archive by extension (functions)
  func   pack               build an archive; the extension picks the format (functions)
```

## 2. Move around

```sh
mkcd build/debug      make a directory and enter it, in one step
up 3                  climb three levels
root                  jump to the top of this repo or project
cdf test              cd to the first directory below here called *test*
```

`root` is the one you will use constantly. It walks upwards looking for `.git`,
`Cargo.toml`, `go.mod`, `package.json` or a `Makefile`, so it works in any
project without configuring anything.

Then there is **jump**, which learns where you go:

```sh
j hellish             jump to the best-matching directory you have visited
jl                    show the candidates and their scores
mark api              bookmark here, by name
to api                go to that bookmark
marks                 list bookmarks
```

`j` scores by frequency *and* recency, so somewhere you used forty times last
year loses to somewhere you used five times today. It learns silently as you
`cd`; after a week it is usually right on the first guess.

## 3. Find things

```sh
ff config             find FILES whose name contains "config"
fd_ test              find DIRECTORIES
grepf "TODO"          search file CONTENTS
biggest 20            the 20 largest files below here
```

All of them skip `.git`, `node_modules`, `target`, `build` and `.venv`, which
is the difference between a useful answer and four thousand lines. `grepf`
uses ripgrep when you have it installed and falls back to `grep -r` when you
do not — you type the same thing either way.

## 4. Work with git

The short aliases are what you would expect — `gs`, `ga`, `gc`, `gd`, `gl`,
`gp`. The functions are the ones worth learning:

```sh
ginfo                 one screen: branch, drift, staged/unstaged/untracked, recent log
gundo                 undo the last commit, KEEP the changes staged
gwip                  commit everything as a timestamped "wip:" (skips hooks)
gunwip                undo that wip commit — refuses if the last commit is not one
gsweep                delete local branches already merged into main
gnuke                 throw away every local change (shows them, then asks)
gsw feature/x         switch to a branch, creating it if it does not exist
```

`gundo` is the safe one: the commit object goes away, your work stays staged.
`gnuke` is the dangerous one, which is why it prints what it is about to
destroy and waits for a `y`.

## 5. Build and run anything

You should not have to remember whether this repo wants `cargo test`, `npm
test`, `pytest` or `make test`. **devkit** detects the project and dispatches:

```sh
proj                  what am I standing in?
build                 build it
run                   run it
test_                 test it   (named test_ so it never shadows the `test` builtin)
fmt                   format it
lint                  lint it
```

It recognises rust, go, python, node, maven, gradle, cmake, make and docker,
and for node it works out whether you use npm, pnpm, yarn or bun by looking at
the lockfile.

## 6. Reclaim disk space

```sh
diskfree              usage per mount, with bars
clean                 what COULD be freed — reports, deletes nothing
clean -y              actually free it
clean -a -y           everything, including docker images and unused font weights
bigdirs               where the space went
```

`clean` is a dry run by default and there is no setting that changes that.
Every invocation that deletes something has `-y` typed on it by a human at
that moment. It only ever touches things the system rebuilds on demand, and it
reports per filesystem — `/tmp` is often a different mount, and clearing it
frees nothing on a full home directory.

## 7. Change how your prompt looks

Thirty themes:

```sh
prompt list           browse them, grouped by family
prompt preview        render all thirty with YOUR current directory and branch
prompt vault          switch now
prompt save vault     keep it for every new shell
prompt random         surprise yourself
```

`prompt preview` is the fast way in — it shows every theme with your real data,
so you are choosing between things you can actually read rather than names.

If none of them fit, [write your own](prompt.md) — it is one line.

## 8. The small sharp tools

```sh
extract archive.tar.zst     unpack anything, by extension
pack out.tar.gz src/        the other direction
serve 8080                  static HTTP server for this directory
calc '3.5 * 2 + 1'          floating-point maths
genpass 32                  a random password
killport 3000               kill whatever is on that port
timer make                  how long did that take?
retry 5 curl -f url         retry with exponential backoff
note "remember this"        a timestamped scratch log that outlives the terminal
sysinfo                     this machine, in ten lines
```

`serve` binds to localhost only. `python3 -m http.server` defaults to every
interface, which on a shared machine publishes your working directory to
everyone — set `HX_SERVE_ALL=1` when you actually want that.

## 9. Text plumbing

The three shapes you keep retyping, as commands:

```sh
... | freq            most frequent lines, with counts  (sort | uniq -c | sort -rn)
... | cols 2 11       pick whitespace-separated columns
... | trim            strip leading and trailing whitespace
count file.txt        lines, words, characters — labelled, so you need not remember wc's order
```

```sh
$ ps aux | cols 1 11 | freq 5
```

## 10. Turn things off

Nothing here is mandatory.

```sh
conf list             every feature and whether it is on
conf off docker       turn one off
conf on docker        and back
conf reload           apply, without opening a new shell
```

Your own overrides go in `~/.hellish/rc.d/99-local.hsh`. It loads last, so
anything you put there wins, and no upgrade will ever overwrite it.

---

## When something looks wrong

```sh
conf doctor           load errors, missing dependencies, known gaps
conf caps             what your hellish can actually do
prompt doctor         what your terminal and hellish support for prompts
hxp doctor            plugins missing their external commands
```

See [troubleshooting](troubleshooting.md) for what the answers mean.

---

## Where to go next

- [The prompt](prompt.md) — the token language, and writing your own theme
- [Plugins](plugins.md) — using them, and writing one
- [Architecture](architecture.md) — how the framework works, if you want to extend it
- [Reference](reference.md) — every registered item, generated from the live registry
