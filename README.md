# hellishrc_plugins

The configuration framework for [hellish](https://github.com/Univers42/hellish):
a `~/.hellish/` tree with ordered config modules, a plugin system with a
catalog, and a `conf` command that keeps everything toggleable and documented.

## Install

The easy way — hellish's own installer offers it and asks which plugins you
want:

```sh
curl -fsSL https://raw.githubusercontent.com/Univers42/hellish/main/install.sh | sh
```

Standalone:

```sh
git clone https://github.com/Univers42/hellishrc_plugins && cd hellishrc_plugins
sh install.sh                    # interactive: pick plugins one by one
sh install.sh --plugins all      # everything the catalog defaults on
sh install.sh --plugins "git jump omz-sudo"
```

An existing `~/.hellishrc` is never eaten: it is preserved as
`~/.hellish/rc.d/95-previous-rc.hsh` (still loads, after the framework) plus
a timestamped backup beside the original.

## Layout

```
~/.hellishrc        the loader — deliberately tiny, everything real lives in:
~/.hellish/
  lib/              ui.hsh core.hsh plugin.hsh conf.hsh   (the framework)
  rc.d/             10-env … 99-local                     (config modules, in order;
                                                           a .zsh module is read with zsh rules)
  plugins/          one directory per plugin + catalog.tsv
  bin/              hx-fetch-plugin                       (the external-plugin fetcher)
  hellish.conf      which features are on                 (managed by `conf`)
  state/            runtime data (jump db, marks) — never committed
```

## Daily driving

```
conf list            what is on and off        conf on|off <name>
conf doctor          anything wrong with the load
help_conf            every alias, function, variable and option, documented
hxp list             installed plugins         hxp info <name>
hxp catalog          everything installable
hxp install <name>   fetch an external plugin (oh-my-zsh, git's own, z, …)
hxp new <name>       scaffold your own (the `forge` plugin)
```

## The catalog

`plugins/catalog.tsv` lists everything an installer can offer — the seven
builtin plugins (`git`, `jump`, `devkit`, `docker`, `net`, `sentinel`,
`forge`) and the proven external ones: oh-my-zsh's `sudo`, `extract`,
`dirhistory`, `colored-man-pages`, `copypath`, `jsontools`, `web-search`,
git's own `git-completion` and `git-prompt`, `bash-preexec`, and `z`.

Adding a plugin to the ecosystem = **one line in the catalog**. External
`.zsh` files are fetched keeping their extension, which is what arms
hellish's zsh dialect while they load — a real oh-my-zsh plugin parses as
zsh without any shim.

## Writing a plugin

A plugin is `~/.hellish/plugins/<name>/plugin.hsh` whose first executable
line is:

```sh
hx_plugin <name> <on|off> <group> "one-line description" || return 0
```

After that line the plugin is enabled; declare dependencies with
`hx_needs <cmd>…` and document what you define with `hx_alias_doc` /
`hx_func_doc` so `hxp info` and `help_conf` can explain you. `hxp new <name>`
scaffolds all of this.

## Examples

`examples/hellishrc` is a standalone, single-file `~/.hellishrc` — 30 prompt
themes, a context collector layer and an `hx` command suite, with no dependency
on `~/.hellish/lib` or anything else here. It is the "one file, drop it in"
counterpart to the framework above.

```sh
cp examples/hellishrc ~/.hellishrc && exec hellish
hx help
```

See `examples/README.md` for what it collects, how it is configured, and the
four hellish-vs-bash differences it works around.

## Test

```sh
hellish test/run.hsh        # loads the real config, asserts the registry
hellish test/prompt.hsh     # 31 checks against examples/hellishrc
```
