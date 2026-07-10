# Troubleshooting

## `command not found` / unknown command

You used a stale name. `list` and `cost` do **not** exist. The real names are
`list-models` / `list-presets` / `list-refs` / `list-sessions` and
`cost-estimate`. Run `thumbforge --help` for the full list.

## `429` / quota exceeded (Google free-tier)

The Google API key is on the free tier (~20 requests/min). `gemini-2.5-flash`
(used as the default `analyze-transcript` extractor, and selectable for
`reverse`) hits this wall under load. Fixes:
- For `reverse`, use the default `claude-opus-4-8-thinking` (Anthropic — no
  free-tier wall).
- For `analyze-transcript`, retry after a minute, or pass `--model` to a
  non-free-tier model.
- Don't auto-retry a paid command in a tight loop — each retry costs.

## Missing key / configuration

The thin CLI inherits keys from the running app. Open Settings in Thumbforge and
configure the requested provider/analyzer there; do not inspect app storage or
secret files. A `THUMBFORGE_SECRET` error belongs only to verified repo/dev mode,
which has separate dev configuration.

## Missing API key for a provider

The running app has no key for the provider you're calling. The user sets it in
Settings; do not print key values.

## `--out` and where images land

The thin `generate` requires an absolute `--out <absDir>` export directory. In
verified repo/dev mode only, it is optional because the direct CLI has separate
dev storage. `retry` / `edit` / `eval` remain repo/dev-only and require an
absolute `--out`. `reverse` and `analyze-transcript` take no `--out`.

## Missing / 404 reference path

A `--refs` path no longer resolves. Re-run `thumbforge list-refs [--category <c>]`
to get current paths — reference files are immutable once created, but you may
have an outdated path.

## `no valid JSON` from `reverse`

A known failure mode of thinking analyzers (the model's reasoning overran
`max_tokens` and truncated the JSON). It was fixed by raising `max_tokens` for
thinking models. If it recurs, report it — don't blindly retry, since each
`reverse --confirm` is a paid call.

## Paid command outside the core skills

`eval`, `retry`, and `edit` are paid too but aren't wrapped by a core skill.
Drive them only in verified repo/dev mode with the same triple lock +
dry-run-first + per-call consent from `paid-call-protocol.md`.
