# clean

Report and reclaim regenerable space in your home directory.

```sh
conf on clean && conf reload
```

## Provides

| kind | name | usage | description |
|---|---|---|---|
| func | `clean` | `clean [-y] [-t] [--fonts\|--docker\|--heavy\|-a] [group...]` | report and reclaim regenerable space (dry run unless `-y`) |
| func | `diskfree` | `diskfree` | disk usage per mount, with bars |
| func | `bigdirs` | `bigdirs [dir] [count]` | largest directories below here |
| func | `bigfiles` | `bigfiles [dir] [count]` | largest files below here |

## The safety model

`clean` is a **dry run by default** and there is no setting that changes that.
Every invocation that deletes something has `-y` typed on it by a human at that
moment.

A path is only ever a candidate when all of these hold: it lives under your home
directory or `/tmp`, it is not on the protected list, and it is something the
system rebuilds on demand. The protected list covers your credential
directories, Documents, Desktop, Downloads, Pictures, and the hellish
configuration itself.

Totals are reported **per filesystem**, because `/tmp` is frequently a separate
mount and clearing it frees nothing on a full home partition — a single combined
number there promises space that deleting will never deliver.

## Groups

`trash cache thumbs pkg logs cores tmp dconf nvim rust node vscode browser apps`

Opt-in extras: `--fonts` trims installed Nerd Font variants down to the four a
terminal actually uses, `--docker` prunes images and build cache, `--heavy`
includes slow-to-rebuild caches such as the maven and cargo registries.

```sh
clean              # report only — always start here
clean -t           # …and list the 25 largest directories
clean -y           # free the safe categories
clean --fonts -y   # also reclaim the unused font weights
clean -a -y        # everything, docker included
```

## Why the work is a bash script

`bin/hx-clean` is bash, not a hellish function. It needs arrays of paths,
`find -print0`, and a map keyed by filesystem device number. Carrying those
through the shims in `rc.d/40-functions.hsh` would buy nothing: it deletes
files, it does not change your shell's environment, so it has no reason to run
inside your shell.
