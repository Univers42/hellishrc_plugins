# Documentation

Five guides and a generated reference. Read them in this order, or use them as
a map and jump.

| | | |
|---|---|---|
| **[The first ten minutes](tour.md)** | the twenty commands that matter, in the order you will want them | start here |
| **[The prompt](prompt.md)** | choosing a theme, the token language, writing your own | |
| **[Plugins](plugins.md)** | using them, writing one, and the rules that bite | |
| **[How it works](architecture.md)** | load order, the registry, capabilities, hooks | before you change the framework |
| **[When something is wrong](troubleshooting.md)** | symptoms, and what to run | |
| **[Reference](reference.md)** | every registered item, generated from the live registry | when you know what you want |

## From inside the shell

The same material, without leaving your terminal:

```sh
cheat                  one screen: the commands worth memorising
cheat git              …or one section: nav find git dev disk prompt conf
guide                  the written guides, opened in your pager
guide tour             one of them

help_conf              every registered item, paged
help_conf -s branch    search names and descriptions — the fastest way in
hxp info git           one plugin in detail
forge api              the plugin contract
prompt tokens          the prompt token language
```

If you only remember one thing, make it **`help_conf -s <term>`**. You do not
have to know a command's name to find it — search for what you are trying to
do.

## Keeping the reference honest

`reference.md` is **generated** from the live registry:

```sh
hellish ~/.hellish/bin/hx-gendoc > docs/reference.md
```

Every module declares what it provides with `hx_func_doc` and friends, and
that declaration is what `help_conf`, `hxp info`, the completion wordlists and
this file all read. There is one copy of each fact. If a description here is
wrong, fix the `hx_func_doc` call next to the code and regenerate — never edit
`reference.md` directly.

The prose guides are written by hand, because ordering, judgement and worked
examples are exactly what a registry cannot hold.
