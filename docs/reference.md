# Reference

Every alias, function, variable and shell option this configuration defines.

**This file is generated** from the live registry by `bin/hx-gendoc`. Do not
edit it: change the `hx_func_doc` / `hx_alias_doc` call next to the code and
regenerate. The same data is available in the shell, where it is searchable:

```sh
help_conf                 the whole reference, paged
help_conf functions       one section
help_conf -s <term>       search every name and description
hxp info <plugin>         one plugin, in detail
```

Generated 2026-09-15 from hellish 2.10.2, 208 items.

## Contents

- [Getting around](#getting-around) — 3 items
- [Aliases](#aliases) — 41 items
- [Everyday functions](#everyday-functions) — 34 items
- [Environment and PATH](#environment-and-path) — 11 items
- [History](#history) — 7 items
- [Shell options](#shell-options) — 11 items
- [Completion](#completion) — 6 items
- [Prompt](#prompt) — 2 items
- [Framework internals](#framework-internals) — 10 items
- [git plugin](#git-plugin) — 15 items
- [jump plugin](#jump-plugin) — 11 items
- [devkit plugin](#devkit-plugin) — 10 items
- [clean plugin](#clean-plugin) — 5 items
- [docker plugin](#docker-plugin) — 14 items
- [net plugin](#net-plugin) — 10 items
- [sentinel plugin](#sentinel-plugin) — 9 items
- [forge plugin](#forge-plugin) — 2 items
- [AI block](#ai-block) — 1 item

## Getting around

The way in: a one-screen cheat sheet and the written guides.

| function | usage | what it does |
|---|---|---|
| `cheat` | `cheat [nav|find|git|dev|disk|prompt|conf|all]` | one-screen cheat sheet; a section name for more depth |
| `guide` | `guide [tour|prompt|plugins|arch|trouble|reference]` | open a written guide in $PAGER |


| variable | what it controls |
|---|---|
| `HX_DOCS` | where the written guides live (~/.hellish/docs) |


## Aliases

Short forms. An alias is expanded when a file is PARSED, so these are live inside every module and plugin loaded after them -- which is why any function here that moves or deletes a file calls `command mv` / `command rm`.

| alias | expands to | what it does |
|---|---|---|
| `-` | `cd -` | cd to the previous directory |
| `..` | `cd ..` | up one directory |
| `...` | `cd ../..` | up two directories |
| `....` | `cd ../../..` | up three directories |
| `cp` | `cp -i` | cp -i (prompt before overwrite) |
| `df` | `df -h` | disk free, human units |
| `du` | `du -h` | disk usage, human units |
| `egrep` | `grep -E --color=auto` | extended-regex grep |
| `fgrep` | `grep -F --color=auto` | fixed-string grep |
| `free` | `free -h` | memory, human units |
| `g` | `git` | git |
| `ga` | `git add` | git add |
| `gb` | `git branch` | git branch |
| `gc` | `git commit` | git commit |
| `gca` | `git commit --amend` | git commit --amend |
| `gco` | `git checkout` | git checkout |
| `gd` | `git diff` | git diff (unstaged) |
| `gds` | `git diff --staged` | git diff --staged |
| `gl` | `git log --oneline --graph --decorate -20` | git log, graph, last 20 |
| `gp` | `git push` | git push |
| `gpl` | `git pull --ff-only` | git pull --ff-only (never creates a merge) |
| `grep` | `grep --color=auto` | grep with colour |
| `gs` | `git status --short --branch` | git status, short with branch header |
| `hxd` | `conf doctor` | configuration health check |
| `hxe` | `conf edit` | edit hellish.conf in $EDITOR |
| `hxl` | `conf list` | list features and their state |
| `hxr` | `conf reload` | reload the whole configuration |
| `l1` | `ls -1 --color=auto` | one entry per line |
| `la` | `ls -lha --color=auto --group-directories-first` | long listing including dot-files |
| `ll` | `ls -lh --color=auto --group-directories-first` | long listing, human sizes |
| `ln` | `ln -i` | ln -i (prompt before overwrite) |
| `ls` | `ls --color=auto --group-directories-first` | colourised ls, directories first |
| `lt` | `ls -lhtr --color=auto` | long listing, oldest-modified last |
| `mv` | `mv -i` | mv -i (prompt before overwrite) |
| `now` | `date "+%Y-%m-%d %H:%M:%S"` | current timestamp |
| `path` | `path_list` | print PATH one entry per line |
| `psg` | `ps aux \| grep -v grep \| grep -i` | search running processes |
| `reload` | `conf reload` | reload the configuration |
| `rg-` | `grep -rn --color=auto` | recursive grep with line numbers (plain-grep fallback) |
| `rm` | `rm -i` | rm -i (prompt before delete; use \rm to bypass) |
| `week` | `date +%V` | ISO week number |


## Everyday functions

The general-purpose set: navigation, files, text, dev utilities, and the shims that paper over interpreter gaps.

| function | usage | what it does |
|---|---|---|
| `bak` | `bak <file>...` | timestamped backup copy of a file |
| `biggest` | `biggest [count]` | largest files below here |
| `calc` | `calc '3.5 * 2'` | floating-point calculator |
| `cdf` | `cdf <pattern>` | cd to the first matching directory below here |
| `cols` | `... | cols 2 11` | pick whitespace-separated columns out of stdin |
| `confirm` | `confirm 'delete everything?'` | ask a yes/no question (returns 0 for yes) |
| `count` | `count [file]` | lines, words and characters, labelled |
| `envdiff` | `envdiff [file]` | what envload would change, without changing it |
| `envload` | `envload [file]` | export every KEY=VALUE from a .env file |
| `extract` | `extract <archive>` | extract any archive by extension |
| `fd_` | `fd_ <pattern>` | find directories by name below here |
| `ff` | `ff <pattern>` | find files by name below here (skips .git, node_modules) |
| `freq` | `... | freq [count]` | most frequent lines of stdin, with counts |
| `genpass` | `genpass [length]` | random password from /dev/urandom |
| `glob_into` | `glob_into <array> <pattern>...` | fill an array with only real glob matches (nullglob shim) |
| `grepf` | `grepf <pattern> [dir]` | search file contents below here (uses ripgrep when installed) |
| `hxcd` | | cd to the configuration directory (~/.hellish) |
| `hxnew` | `hxnew <name>` | scaffold a new plugin (via the forge plugin) |
| `is_set` | `is_set <VARNAME>` | true when a variable is set, even if empty (test -v shim) |
| `killport` | `killport <port>` | kill whatever is listening on a TCP port |
| `mkcd` | `mkcd <dir>` | create a directory (with parents) and cd into it |
| `note` | `note [text]` | jot a timestamped note, or print them all |
| `pack` | `pack <archive.tar.gz> <path>...` | build an archive; the extension picks the format |
| `quote` | `quote <string>` | shell-quote a string safely (printf %q shim) |
| `retry` | `retry <count> <command>...` | re-run a command until it succeeds, with exponential backoff |
| `rglob` | `rglob <dir> <pattern>` | recursive file search by name (streams, unlike **) |
| `root` | | cd to the repository or project root above here |
| `serve` | `serve [port] [dir]` | static HTTP server for a directory, localhost-only by default |
| `sysinfo` | | this machine, in ten lines |
| `timer` | `timer <command>...` | time a command in milliseconds |
| `tmpd` | | create a temp directory and cd into it |
| `trim` | | strip leading and trailing whitespace from each line |
| `up` | `up [count]` | climb N directories |


| variable | what it controls |
|---|---|
| `HX_SERVE_ALL` | set to 1 to make serve() listen on every interface, not just localhost |


## Environment and PATH

PATH helpers and the variables this configuration sets for you.

| function | usage | what it does |
|---|---|---|
| `path_append` | `path_append <dir>...` | put directories at the end of PATH (deduped) |
| `path_dedupe` | | collapse duplicate PATH entries, keeping first |
| `path_list` | | print PATH one entry per line |
| `path_prepend` | `path_prepend <dir>...` | put directories at the front of PATH (deduped) |
| `path_remove` | `path_remove <dir>` | drop a directory from PATH |


| variable | what it controls |
|---|---|
| `EDITOR` | preferred editor, auto-detected (nvim/vim/vi/nano) |
| `HX_COLOR` | colour policy: auto \| always \| never |
| `HX_HIST_SIZE` | history size kept in memory and on disk |
| `HX_HOME` | root of this configuration (~/.hellish) |
| `LESS` | less flags: -R colour, -F short-quit, -X no-clear, -i smart case |
| `PAGER` | preferred pager |


## History

What is remembered, what is deliberately forgotten, and how to search it.

| function | usage | what it does |
|---|---|---|
| `h` | `h [pattern]` | search history, or show the last 30 entries |
| `histtop` | `histtop [count]` | your most-used commands |


| variable | what it controls |
|---|---|
| `HISTCONTROL` | ignoredups:ignorespace:erasedups - leading space hides a command |
| `HISTFILE` | where history is kept (~/.hellish_history) |
| `HISTIGNORE` | commands never recorded (ls, cd, exit, ...) |
| `HISTSIZE` | commands kept in memory |
| `HISTTIMEFORMAT` | timestamp shown by `history` |


## Shell options

Every `set -o` and `shopt` decision, with the reason. Several of these are deliberately OFF and say why.

| variable | what it controls |
|---|---|
| `COLUMNS` | NOT maintained by hellish (bash sets it); hx_cols forks tput and caches |


| option | state and reason |
|---|---|
| `cd-spell` | cd tolerates a one-character typo |
| `dotglob` | OFF by choice (it works now): '*' matching dot-files makes 'rm *' dangerous |
| `emacs` | emacs line editing (swap for: set -o vi) |
| `extglob` | NOT available: shopt accepts it and reports 'on', but @() +() are a lexer error |
| `globstar` | ON: ** matches across directory levels (verified working) |
| `multiline-history` | history recall keeps newlines and indentation |
| `nocaseglob` | OFF by choice (it works now): case-blind globs do not survive being pasted into a script |
| `nullglob` | OFF by choice (it works now): it changes what every failed glob means -- see glob_into |
| `pipefail` | NOT enabled: it makes '\| head' and '\| grep -q' report 141 (SIGPIPE) |
| `resize-aware` | re-read terminal size after every command |


## Completion

TAB completion. On hellish 2.10 these install for real; on an older binary they are recorded and install themselves the day you upgrade.

| function | usage | what it does |
|---|---|---|
| `hx_complete` | `hx_complete <cmd> <word>...` | declare (and install) a completion wordlist for a command |
| `hx_complete_dynamic` | | rebuild the completions that depend on the live registry |
| `hx_complete_flush` | | install every declared completion wordlist |
| `hx_complete_show` | `hx_complete_show [cmd]` | show declared completion wordlists |


| option | state and reason |
|---|---|
| `bind` | NOT available: no `bind` builtin, so key bindings cannot be set from an rc |
| `progcomp` | armed here: without it an installed `complete` spec never reaches TAB |


## Prompt

The theme engine's own entry points. See [the prompt guide](prompt.md) for the token language.

| variable | what it controls |
|---|---|
| `HELLISH_ANIM` | prompt animation: off, and deliberately so (upstream warns it can corrupt terminals) |
| `HX_THEME_DIR` | where prompt themes live (~/.hellish/themes) |


## Framework internals

The registry, the capability probe and the hook system. You need these only when writing a plugin -- see [writing a plugin](plugins.md).

| command | usage | what it does |
|---|---|
| `prompt` | `prompt [name|list|preview|next|random|save|new|tokens|doctor]` | switch, preview and design prompt themes |


| function | usage | what it does |
|---|---|---|
| `hx_precmd_add` | `hx_precmd_add <function>` | register a function to run before each prompt |
| `hx_preexec_add` | `hx_preexec_add <function>` | register a function to run before each typed command (gets the line as $1) |
| `theme` | `theme <name>` | alias for the prompt command |


| variable | what it controls |
|---|---|
| `HX_NERD` | 1 to use powerline glyphs (needs a patched font) |
| `HX_PATH_MAX` | path components before {path} elides the middle |
| `HX_PATH_STYLE` | how {path} is drawn: smart \| short \| fish \| tail \| full |
| `HX_PS_ACCENT` | the palette colour themes lean on (prompt palette) |
| `HX_THEME` | the prompt theme (prompt list to browse, prompt save to keep) |
| `PROMPT_COMMAND` | the fallback prompt hook; inert when hellish has native HELLISH_PRECMD_FUNCS |


## git plugin

git: repo status, safe undo, wip commits, branch cleanup

Requires: `git`

```sh
conf on git && conf reload
```

| function | usage | what it does |
|---|---|---|
| `gbranch` | | print the current branch name |
| `gfind` | `gfind <string>` | find commits that added or removed a string |
| `ginfo` | | one-screen repository overview: branch, drift, counts, recent log |
| `gnuke` | | discard every local change (shows them and asks first) |
| `groot` | | cd to the repository root |
| `gsw` | `gsw <branch>` | switch to a branch, creating it if needed |
| `gsweep` | | delete local branches already merged into the default branch |
| `gundo` | | undo the last commit, keeping its changes staged |
| `gunstage` | `gunstage [path...]` | unstage everything, or the given paths |
| `gunwip` | | undo the last wip commit (refuses if it is not one) |
| `gwhen` | `gwhen <file>` | history of one file, following renames |
| `gwho` | `gwho [rev-range]` | commit counts per author |
| `gwip` | | commit everything as a timestamped wip (skips hooks) |


| variable | what it controls |
|---|---|
| `HX_GIT_AUTOINFO` | set to 1 to run ginfo automatically on entering a new repo |


## jump plugin

jump: frecency directory jumping, bookmarks, back-stack

```sh
conf on jump && conf reload
```

| function | usage | what it does |
|---|---|---|
| `j` | `j <fragment>` | jump to the best-scoring directory matching a fragment |
| `jclean` | | drop dead paths and prune the jump database |
| `jl` | `jl [fragment]` | list jump candidates and their scores |
| `jrm` | `jrm <fragment>` | forget jump entries matching a fragment |
| `mark` | `mark [name]` | bookmark the current directory |
| `marks` | | list bookmarks |
| `to` | `to <name>` | jump to a bookmark (no argument lists them) |
| `unmark` | `unmark <name>` | remove a bookmark |


| variable | what it controls |
|---|---|
| `HX_JUMP_DB` | frecency database for the jump plugin |
| `HX_JUMP_MAX` | how many directories to remember before pruning |


## devkit plugin

devkit: project detection, universal run/build/test/fmt/lint

```sh
conf on devkit && conf reload
```

| function | usage | what it does |
|---|---|---|
| `build` | `build [args]` | build this project, whatever kind it is |
| `fmt` | | format this project's source |
| `lint` | | lint this project |
| `proj` | | describe the project you are standing in |
| `proj_root` | | nearest directory above here that looks like a project |
| `proj_type` | `proj_type [dir]` | detect the project type of a directory |
| `run` | `run [args]` | run this project |
| `scratch` | `scratch [extension]` | open a timestamped scratch file in $EDITOR |
| `test_` | `test_ [args]` | test this project (named test_ so it never shadows the 'test' builtin) |


## clean plugin

clean: report and reclaim regenerable space in $HOME

Requires: `du df find`

```sh
conf on clean && conf reload
```

| function | usage | what it does |
|---|---|---|
| `bigdirs` | `bigdirs [dir] [count]` | largest directories below here, one filesystem only |
| `bigfiles` | `bigfiles [dir] [count]` | largest files below here |
| `clean` | `clean [-y] [-t] [--fonts|--docker|--heavy|-a] [group...]` | report and reclaim regenerable space in $HOME (dry run unless -y) |
| `diskfree` | | disk usage per mount, with bars |


## docker plugin

docker: container/image overview, shell-in, prune, compose

Requires: `docker`

```sh
conf on docker && conf reload
```

| function | usage | what it does |
|---|---|---|
| `dcd` | `dcd [args]` | compose down |
| `dcl` | `dcl [service]` | follow compose logs |
| `dclean` | | prune stopped containers and dangling images (shows usage, asks first) |
| `dcps` | | compose service status |
| `dcr` | `dcr [service]` | restart compose services |
| `dcu` | `dcu [service]` | compose up, detached |
| `dimg` | | images with sizes and age |
| `dip` | `dip <container>` | a container's IP address(es) |
| `dlog` | `dlog <container>` | follow a container's logs (last 100 lines first) |
| `dps` | `dps [docker ps args]` | running containers: name, status, ports, image |
| `dpsa` | | every container including stopped ones |
| `dsh` | `dsh <container>` | interactive shell inside a container (bash, falling back to sh) |
| `dstopall` | | stop every running container (asks first) |


## net plugin

net: ports, local/public IP, DNS, HTTP probing, port waiting

Requires: `ss curl dig`

```sh
conf on net && conf reload
```

| function | usage | what it does |
|---|---|---|
| `dns` | `dns <hostname>` | A/AAAA/CNAME/MX/TXT/NS records for a name |
| `hdr` | `hdr <url>` | HTTP response headers, following redirects |
| `httptime` | `httptime <url>` | break an HTTP request into dns/tcp/tls/ttfb timings |
| `localip` | | this machine's LAN addresses per interface |
| `port` | `port <number>` | what is listening on one port |
| `ports` | `ports [pattern]` | listening TCP/UDP sockets, optionally filtered |
| `pubip` | | your public IP (contacts ifconfig.me; never called automatically) |
| `scan` | `scan <host> [from] [to]` | sweep a TCP port range using /dev/tcp |
| `waitport` | `waitport <host> <port> [timeout]` | block until a TCP port accepts connections |


## sentinel plugin

sentinel: system dashboard, disk/load/memory watch, repo scan

```sh
conf on sentinel && conf reload
```

| function | usage | what it does |
|---|---|---|
| `repos` | `repos [dir]` | git repositories below a directory with uncommitted changes |
| `sentinel` | | the full system dashboard |
| `sys_disk` | | disk usage per mount, with bars |
| `sys_load` | | load average and uptime |
| `sys_mem` | | memory and swap usage |
| `sys_top` | | the five hungriest processes |


| variable | what it controls |
|---|---|
| `HX_SENTINEL_DISK_WARN` | disk %% at which sentinel warns (default 90) |
| `HX_SENTINEL_WATCH` | set to 1 to warn once per shell when a disk crosses the threshold |


## forge plugin

forge (official): scaffold, lint and document plugins

```sh
conf on forge && conf reload
```

| function | usage | what it does |
|---|---|---|
| `forge` | `forge new|lint|doc|list|api <name>` | scaffold, lint and document plugins |


## AI block

| variable | what it controls |
|---|---|
| `HELLISH_AI_SUGGEST` | AI inline suggestions (inert until the 'ai' builtin ships) |


---

## Anything not listed here

If a name is missing from this file it is not registered, which means
`help_conf` cannot see it either. For your own code that is a bug worth
fixing — add an `hx_func_doc` line next to it and it appears in both places at
once.

```sh
myfunc() { ...; }
hx_func_doc myfunc "what it does" "myfunc <arg>"
```

`forge lint <plugin>` warns about a plugin that registers nothing.
