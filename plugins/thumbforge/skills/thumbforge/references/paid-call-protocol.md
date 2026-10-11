# Paid-call protocol (triple lock)

The whole point: the agent must **never** spend the user's money without his
explicit, in-the-moment consent. The CLI enforces a triple lock; this protocol is
how you operate within it safely.

## The triple lock

A paid command runs for real only when ALL THREE hold:

1. env `THUMBFORGE_ALLOW_PAID_CALLS=1`
2. flag `--confirm`
3. the dry-run default is thereby overridden

Paid commands: `generate`, `reverse`, `analyze-transcript`, `eval`, `retry`,
`edit`. Everything else (`list-*`, `cost-estimate`, `config-set`, `upload-ref`,
`refs:rethumb`, `refs:contact-sheet`) is free / local.

## Environment

The thin CLI inherits provider/analyzer keys from the running app. Do **not**
inspect or source secret/config files. The direct repo CLI has separate dev
configuration, but it is available only after the shared cwd manifest check.
In both modes keep `THUMBFORGE_ALLOW_PAID_CALLS=1` inline and ephemeral.

## Five rules that keep it safe

1. **Dry-run first, always.** Run the command WITHOUT `--confirm`, show the user the
   plan + estimated cost (use `cost-estimate` for `generate`), and wait.
2. **Consent is per-call, not per-session.** Only run the paid command after
   the user says yes *in this turn*. Never re-issue a `--confirm` command without
   fresh consent — not on retry, not after an error, not after Ctrl-C, not
   "because he approved a similar one earlier".
3. **`THUMBFORGE_ALLOW_PAID_CALLS=1` stays inline** on the single command line.
   Never `export` it or add it to any persistent env. A parent-env `ALLOW=1`
   would make `--confirm` the only remaining lock — half the protection gone.
4. **Chained flows = separate consent per stage.** `reverse → generate` and
   `analyze-transcript → generate` are multiple paid stages. Each gets its own
   dry-run, its own cost line, and its own approval. One yes never authorizes the
   next paid stage.
5. **Show cost before asking.** `cost-estimate` is free — surface the number so
   the user approves with the price in front of him.

## Shape: dry-run → confirm

```bash
# 1) dry-run (free) - show the plan + cost + Slug odcinka, then WAIT
thumbforge generate --preset hero-pointing --topic "..." --quality low --refs /references/character-primary/<id>.png \
  --out "$HOME/Downloads/<slug>" --out-name <slug>
thumbforge cost-estimate --count 1 --model <model> --quality low

# 2) only after the user approves in this turn:
THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge generate \
  --preset hero-pointing --topic "..." --quality low \
  --refs /references/character-primary/<id>.png \
  --out "$HOME/Downloads/<slug>" --out-name <slug> \
  --confirm
```

`cost-estimate` nie czyta Ustawień, więc podaj model z linii dry-runu (cienki
klient: `model: <dostawca>/<model> (<jakość>, źródło: ustawienia aplikacji)`,
dev CLI: `plan: <dostawca>/<model> @ <jakość>`).

Podsumowanie dry-runu, które pokazujesz przed prośbą o zgodę, podaje proponowany
Slug odcinka (2-4 słowa z roboczego tytułu odcinka, np. `codex-sdk`) i katalog
`$HOME/Downloads/<slug>`, żeby user mógł zmienić slug jednym słowem. Płatne
wywołanie powtarza argumenty dry-runu i dodaje tylko inline env oraz `--confirm`.

For optional GPT Image 2.5 Sunburst or Flare, use the registry id and one of
`low|medium|high|xhigh|max|auto` only when `inventory` lists that model. `auto`
is an orientational max-output estimate, not a guaranteed cost ceiling. Preserve
a model/quality already chosen by the user in the dry-run. Bez `--model` CLI
bierze model z Ustawień aplikacji (dry-run cienkiego klienta drukuje
`źródło: ustawienia aplikacji`); na prośbę usera podaj inne ID z katalogu, np.
`--model gemini-nano-banana-2.1` bez `--provider`, z jakością z tierów tego
modelu (`low`..`max`). Inventory shows the client model catalog; it does not
prove account access or edit support in an older app. For edit, use
`thumbforge edit --help` for the thin client's flags, then let the dry-run
perform the live capability
check before a positive plan or POST. Documentation recommendation: Sunburst for
precise edits, Flare for fast daily iterations.

The thin client requires an absolute `--out` export directory. In verified
repo/dev mode only, `--out` is optional because canonical files land in the dev
generations root.

`reverse` (one paid invocation, no `--out`):

```bash
thumbforge reverse --url "<yt>" --context "<the user's topic>"      # dry-run, no vision call
THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge reverse \
  --url "<yt>" --context "<the user's topic>" --apply --confirm
```

`analyze-transcript` (no `--out`, requires `--preset`):

```bash
thumbforge analyze-transcript --text "<scenario>" --preset hero-pointing    # dry-run
THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge analyze-transcript \
  --text "<scenario>" --preset hero-pointing --confirm
```

## If a paid command fails

Report the failure and the cost already incurred. Do **not** auto-retry the
`--confirm` command — a retry is another paid call and needs fresh consent.
