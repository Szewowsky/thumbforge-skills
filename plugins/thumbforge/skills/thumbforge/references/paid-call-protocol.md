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

The CLI **auto-loads** `THUMBFORGE_SECRET` from repo-root `.env.local` (an
allowlist loader — ADR 0005). You do **not** source it manually: a direct
`pnpm cli generate … --confirm` decrypts the saved key on its own. A pre-set
`THUMBFORGE_SECRET` in the env wins, and a missing `.env.local` is a no-op.

The loader reads **only** `THUMBFORGE_SECRET` — never any other line in the
file. That is the point: even if `THUMBFORGE_ALLOW_PAID_CALLS=1` ended up in
`.env.local`, the loader would not import it, so the cost lock cannot collapse to
`--confirm` alone from the file. Still keep `ALLOW=1` out of `.env.local` and any
persistent env as defense-in-depth (rule 3).

## Five rules that keep it safe

1. **Dry-run first, always.** Run the command WITHOUT `--confirm`, show the user the
   plan + estimated cost (use `cost-estimate` for `generate`), and wait.
2. **Consent is per-call, not per-session.** Only run the paid command after
   the user says yes *in this turn*. Never re-issue a `--confirm` command without
   fresh consent — not on retry, not after an error, not after Ctrl-C, not
   "because he approved a similar one earlier".
3. **`THUMBFORGE_ALLOW_PAID_CALLS=1` stays inline** on the single command line.
   Never `export` it, never add it to `.env.local` or any persistent env. The
   secret loader ignores it from the file (allowlist), but a parent-env `ALLOW=1`
   would still make `--confirm` the only remaining lock — half the protection gone.
4. **Chained flows = separate consent per stage.** `reverse → generate` and
   `analyze-transcript → generate` are multiple paid stages. Each gets its own
   dry-run, its own cost line, and its own approval. One yes never authorizes the
   next paid stage.
5. **Show cost before asking.** `cost-estimate` is free — surface the number so
   the user approves with the price in front of him.

## Shape: dry-run → confirm

```bash
# 1) dry-run (free) — show the plan + cost, then WAIT
pnpm cli generate --preset hero-pointing --topic "..." --quality low --refs /references/character-primary/<id>.png
pnpm cli cost-estimate --count 1 --model gpt-image-2 --quality low

# 2) only after the user approves in this turn (secret auto-loads from .env.local):
THUMBFORGE_ALLOW_PAID_CALLS=1 pnpm cli generate \
  --preset hero-pointing --topic "..." --quality low \
  --refs /references/character-primary/<id>.png \
  --confirm
```

`--out` is optional (export policy, ADR 0005): omit it and the images still land
in `public/generations` (visible in the UI / `/sessions/batch/<run>`); pass
`--out <absDir>` to ALSO copy the finals somewhere handy.

`reverse` (one paid invocation, no `--out`):

```bash
pnpm cli reverse --url "<yt>" --context "<the user's topic>"      # dry-run, no vision call
THUMBFORGE_ALLOW_PAID_CALLS=1 pnpm cli reverse \
  --url "<yt>" --context "<the user's topic>" --apply --confirm
```

`analyze-transcript` (no `--out`, requires `--preset`):

```bash
pnpm cli analyze-transcript --text "<scenario>" --preset hero-pointing    # dry-run
THUMBFORGE_ALLOW_PAID_CALLS=1 pnpm cli analyze-transcript \
  --text "<scenario>" --preset hero-pointing --confirm
```

## If a paid command fails

Report the failure and the cost already incurred. Do **not** auto-retry the
`--confirm` command — a retry is another paid call and needs fresh consent.
