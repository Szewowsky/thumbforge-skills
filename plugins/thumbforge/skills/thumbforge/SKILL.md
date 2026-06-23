---
name: thumbforge
description: >-
  Entry point and router for the thumbforge thumbnail CLI (pnpm cli). Use when
  Robert wants to drive thumbforge from chat — "odpal thumbforge", "co potrafi
  thumbforge", "/thumbforge", or when you need the shared paid-call protocol,
  command catalog, preset list, or bootstrap check before a thumbforge task.
  This skill operates the CLI on Robert's behalf: it picks sane defaults,
  dry-runs first, shows the plan and cost, and only runs a paid call after
  Robert's explicit per-call consent. Consult it whenever a request touches
  thumbnail generation, cloning a competitor thumbnail, or a video scenario in
  this repo, even if Robert doesn't name the CLI. NOT for the actual work itself
  once intent is clear — route to the task skills instead: generating thumbnails
  from a topic → tf-generate; cloning/adapting a competitor thumbnail from a
  URL/image → tf-reverse; turning a scenario/transcript into concepts →
  tf-scenario; listing or adding reference images (face, icons, inspirations) →
  tf-assets. NOT for editing the Next.js app, the web UI, or non-thumbforge
  projects.
argument-hint: "[what you want to do with thumbforge]"
allowed-tools: Bash
---

# thumbforge (umbrella)

The user triggers, you operate. The thumbforge CLI (`pnpm cli`) is the engine;
this skill is the operator's manual: how to drive it safely, pick defaults,
dry-run, and never burn a paid call without the user's explicit say-so. For a
concrete task, route to a task skill (see Routing). Use this skill directly for
bootstrap checks, the command catalog, or the shared paid-call protocol.

## Step 0 — Bootstrap

Run from the repo root: `/Users/robert/Windsurf Projekty/thumbforge`.

```bash
cd "/Users/robert/Windsurf Projekty/thumbforge"
thumbforge --help                  # CLI reachable? (free)
test -f .env.local && grep -q THUMBFORGE_SECRET .env.local \
  && echo "secret: ok" || echo "secret: MISSING in .env.local"
test -s data/config.json && echo "config: present" || echo "config: MISSING"
ls public/references/*/*.png >/dev/null 2>&1 \
  && echo "refs: present" || echo "refs: none yet"
```

Never print the contents of `data/config.json` or `.env.local` — only their
presence. `config.json` holds encrypted API keys; checking presence is enough.
If `secret` or `config` is missing, paid commands will fail — tell the user to set
keys (`pnpm --silent cli config-set --provider <p> --key <k>`) and ensure
`THUMBFORGE_SECRET` is in `.env.local`; don't try to run a paid call.

The authoritative flag reference is always `pnpm cli <command> --help` (generated
from code, never drifts). `docs/cli.md` is the human overview. Confirm flags
there rather than trusting any example in a skill.

## Paid-call protocol (triple lock)

Paid commands (`generate`, `reverse`, `eval`, `retry`, `analyze-transcript`,
`edit`) are dry-run by default. To actually spend money you need **all three**:
env `THUMBFORGE_ALLOW_PAID_CALLS=1` + flag `--confirm` + the dry-run-default being
overridden. The discipline that keeps this safe:

1. **Secret auto-loads.** The CLI reads `THUMBFORGE_SECRET` from `.env.local`
   itself (allowlist loader — ADR 0005); you no longer source it. Just keep the
   secret in `.env.local` (a pre-set env var wins).
2. **Dry-run first.** Run the command WITHOUT `--confirm`, show the user the plan +
   estimated cost (`cost-estimate` for generate), and wait.
3. **Consent is per-call, not per-session.** Only after the user says yes in this
   turn, run the paid command. Never re-issue a `--confirm` command without fresh
   consent — not on retry, not after an error, not after Ctrl-C.
4. **Keep `THUMBFORGE_ALLOW_PAID_CALLS=1` inline** on the one command line. Never
   `export` it, never put it in `.env.local` — otherwise `--confirm` becomes the
   only remaining lock.
5. **Chained flows = separate consent.** reverse→generate and scenario→generate
   are multiple paid stages; each gets its own dry-run and its own approval.

Full details + examples: `references/paid-call-protocol.md`.

## Discovery gate + batch-first (universal)

These skills run on **any** account, so never assume which presets, styles, or refs
exist — discover them. Two rules, full detail in `references/discovery-contract.md`:

1. **Discover before you choose.** Before picking a resource on the user's behalf,
   list that dimension first: archetype → `thumbforge list-presets`; text/background/
   recipe style → `thumbforge list-styles`; refs → `thumbforge list-refs`; model →
   `thumbforge inventory` for all four at once. Every id
   you pass must have appeared in a list this session (built-in **and** the
   account's custom). Skip a dimension only when the user named it explicitly. The
   static catalogs are reasoning, not the id source.
   For refs, the list is only the index: if several candidates could fit, inspect
   their `_thumb.png` previews or a contact sheet before choosing.
2. **Batch, don't loop.** More than one concept → one `thumbforge generate
   --concepts-file <abs.json>` (one logical Run, one consent). The CLI may split
   the Run into review-sized sessions of ≤4 images; never loop single `generate`
   calls yourself (that spawns unrelated duplicate-looking sessions).

## UX Rules

1. Reply in Polish (full diacritics ą/ć/ę/ł/ń/ó/ś/ź/ż), no emoji. Technical args
   (`--preset hero-pointing`) stay as-is.
2. No raw ULIDs or JSON dumps in chat. Deliver output **paths**
   (`public/generations/...`) + a one-line summary (preset, model, cost).
3. Pick sane defaults; ask one thing at a time, only when genuinely missing.
4. Don't narrate "running cost-estimate", "calling the model". Show the result.

## Command catalog

Authoritative flags: `pnpm cli <cmd> --help`. Map: `references/cli-reference.md`.

| Command | Paid? | Purpose |
|---|---|---|
| `list-models` | no | image models + pricing |
| `list-presets` | no | built-in + custom presets |
| `list-styles` | no | text / background / recipe styles (built-in + custom) |
| `list-refs` | no | reference images on disk (`--category`) |
| `inventory` | no | one-shot overview: presets + styles + models + refs |
| `list-sessions` | no | past generation sessions |
| `cost-estimate` | no | estimate batch cost (no provider call) |
| `generate` | **yes** | generate thumbnails → **tf-generate** |
| `reverse` | **yes** | clone a competitor thumbnail → **tf-reverse** |
| `analyze-transcript` | **yes** | infer slots from a scenario → **tf-scenario** |
| `eval` | **yes** | golden-set eval (out of core scope) |
| `retry` | **yes** | re-run a session (out of core scope) |
| `edit` | **yes** | instruction-edit an image (out of core scope) |
| `config-set` | no | store an encrypted key (the user does setup) |
| `upload-ref` | no | add a reference image → **tf-assets** |
| `refs:rethumb` | no | rebuild reference `_thumb.png` previews → **tf-assets** |
| `refs:contact-sheet` | no | labeled visual ref sheet → **tf-assets** |
| `preset:slots` | no | a preset's slots → **tf-preset** |
| `preset:show` | no | a preset's 6 spec blocks (`--block` for raw) → **tf-preset** |
| `preset:create` | no | fork a preset → **tf-preset** |
| `preset:edit` | no | edit a custom preset → **tf-preset** |
| `preset:preview` | no | replace a custom preset grid cover → **tf-preset** |
| `preset:delete` | no | soft-delete a custom preset → **tf-preset** |
| `style:create` | no | author a text/background style → **tf-preset** |
| `style:edit` | no | edit a custom style → **tf-preset** |
| `style:delete` | no | soft-delete a custom style → **tf-preset** |

## Routing

- Generate thumbnails from a topic/preset → **`/tf-generate`**.
- Clone/adapt a competitor thumbnail (URL or image) → **`/tf-reverse`**.
- Turn a video scenario/transcript into concepts → **`/tf-scenario`**.
- List or add reference images — face, icons, inspirations → **`/tf-assets`** (free).
- Author or edit a custom preset (fork an archetype, edit a block) or a custom
  text/background style → **`/tf-preset`** (free). Also where a reverse-template
  preset gets refined before generation.
- Editing an already-generated image (`edit`), re-running a past session as-is
  (`retry`), or a golden-set `eval` — these are paid but out of the core skill
  set. Handle them **here**, by hand, via `docs/cli.md` + the paid-call protocol
  with the same locks. The task skills redirect these asks back to this umbrella.

## Errors

Common failures and fixes: `references/troubleshooting.md`. Quick hits:
`command not found` → you used a stale name (`list`/`cost` don't exist; use
`list-presets`/`cost-estimate`). `429` → Google free-tier wall (use the default
Anthropic analyzer). Missing `THUMBFORGE_SECRET` → ensure it is in `.env.local`
(the CLI auto-loads it).

## Reference docs

Load on demand:

- `references/cli-reference.md` — command → purpose → "flags via `--help`".
- `references/discovery-contract.md` — discover-before-propose + batch-first + concepts-file format.
- `references/paid-call-protocol.md` — env + triple lock + dry-run→confirm examples.
- `references/presets-catalog.md` — the built-in archetypes + slots.
- `references/thumbnail-craft.md` — universal design craft: layout, text, archetype→preset map, hooks, series continuity. Read before picking a preset/text.
- `references/gotchas.md` — universal pitfalls that tank a thumbnail (read with craft).
- `references/troubleshooting.md` — common errors and fixes.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają **`thumbforge`** — cienki klient HTTP. U testera z samą
aplikacją (.dmg, bez repo) `thumbforge` jest wbudowany w apkę (instalacja: ikona w
tray → „Zainstaluj CLI"). W repozytorium (dev) `thumbforge` to launcher do
bezpośredniego CLI — raz wykonaj `pnpm link --global` (albo używaj równoważnego
`pnpm cli <komenda>`).

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `inventory`, `cost-estimate`, `generate`, `reverse`, `analyze-transcript`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `upload-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `edit`, `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
