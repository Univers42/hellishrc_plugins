# Prompt themes

Thirty themes in six families, plus one file that is yours.

```
prompt              which theme is on, and what it shows
prompt list         all of them, grouped, active one marked
prompt <name>       switch now          prompt save <name>   keep it
prompt preview      render every theme with this directory's live data
prompt gallery      the same, grouped and described
prompt next|prev|random
prompt new <name>   scaffold your own into 90-local.hsh
prompt tokens       the token language
prompt doctor       what this terminal and this hellish can actually do
```

`theme` is the same command.

## Why themes are data

A theme is one string, not a function. hellish renders the prompt in C and its
renderer speaks two languages at once — zsh's percent escapes (`%F{117}`,
`%~`, `%(?.ok.bad)`) and hellish's own self-spacing badges (`\g` branch, `\S`
failure, `\p` duration, `\J` jobs, `\U` update). Between them, most of these
themes need no shell code at all and cannot be slow.

Themes are written in **tokens** rather than raw escapes, so one palette change
restyles all thirty, an 8-colour terminal degrades instead of smearing, and a
terminal without UTF-8 gets `+--+` instead of a row of question marks.

## The three rules

Verified against the running binary by `test/prompt.hsh`:

1. **`$(...)` is not expanded in a prompt.** `${VAR}` and `$((...))` are, at
   every render. Anything the percent language cannot express is computed once
   per prompt into a variable by `hx_prompt_precmd`.
2. **Escapes coming out of a variable are not re-scanned.** So every computed
   segment holds plain text only and the theme colours it from the static side.
   That is also what keeps the width arithmetic exact.
3. **A literal `%` is written `%%`**, and computed segments have their percents
   doubled before they reach the prompt.

## The families

| family | the idea |
|---|---|
| `minimal` | the prompt is what you look past |
| `classic` | five shells' own defaults, reproduced |
| `frames` | spend a row to keep the cursor in one column |
| `blocks` | filled colour reads as objects, not words |
| `expressive` | pick the palette first |
| `focus` | each answers one question you ask all day |

## What a theme costs

Most cost nothing: the renderer does all of it. The ones that use computed
segments declare them in the `needs` field, and the per-prompt hook runs
exactly that set. `prompt doctor` prints the cost of the active theme.

| segment | cost |
|---|---|
| `path` `venv` `lang` `ctx` `load` | none — shell string work and `/proc` |
| `vcs` | one `git status --porcelain=v2 --branch` |
| `rule` | one `tput cols` |
