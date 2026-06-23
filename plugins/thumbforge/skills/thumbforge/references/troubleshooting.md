# Troubleshooting

## `command not found` / unknown command

You used a stale name. `list` and `cost` do **not** exist. The real names are
`list-models` / `list-presets` / `list-refs` / `list-sessions` and
`cost-estimate`. Run `pnpm cli --help` for the full list.

## `429` / quota exceeded (Google free-tier)

The Google API key is on the free tier (~20 requests/min). `gemini-2.5-flash`
(used as the default `analyze-transcript` extractor, and selectable for
`reverse`) hits this wall under load. Fixes:
- For `reverse`, use the default `claude-opus-4-8-thinking` (Anthropic — no
  free-tier wall).
- For `analyze-transcript`, retry after a minute, or pass `--model` to a
  non-free-tier model.
- Don't auto-retry a paid command in a tight loop — each retry costs.

## Missing `THUMBFORGE_SECRET`

The CLI auto-loads the secret from repo-root `.env.local` (allowlist — ADR 0005),
so this usually means `.env.local` is absent or has no `THUMBFORGE_SECRET` line.
Add it (`openssl rand -hex 32`) — the same value the keys were saved with. If it
is missing, paid commands can't decrypt the keys — tell the user; don't try to
work around it. The `generate` pre-flight reports "Zły lub brak THUMBFORGE_SECRET"
distinctly from a missing provider key, so you know which one to fix.

## Missing API key for a provider

`config.json` has no key for the provider you're calling. the user sets it (do not
print key values):

```bash
pnpm --silent cli config-set --provider openai --key <KEY>
```

## `--out` and where images land

`generate` no longer requires `--out` (ADR 0005): omit it and the images still
land in `public/generations`, visible in the UI / `/sessions/batch/<run>`. Pass
`--out <absDir>` only to ALSO copy the finals somewhere handy (a project's
thumbnails dir, `~/Downloads/<slug>/`, …); it must be absolute. `retry` / `edit`
/ `eval` still require an absolute `--out`. `reverse` and `analyze-transcript`
take no `--out`.

## Missing / 404 reference path

A `--refs` path no longer resolves. Re-run `pnpm cli list-refs [--category <c>]`
to get current paths — reference files are immutable once created, but you may
have an outdated path.

## `no valid JSON` from `reverse`

A known failure mode of thinking analyzers (the model's reasoning overran
`max_tokens` and truncated the JSON). It was fixed by raising `max_tokens` for
thinking models. If it recurs, report it — don't blindly retry, since each
`reverse --confirm` is a paid call.

## Paid command outside the core skills

`eval`, `retry`, and `edit` are paid too but aren't wrapped by a core skill.
Drive them by hand via `docs/cli.md` with the same triple lock + dry-run-first +
per-call consent from `paid-call-protocol.md`.
