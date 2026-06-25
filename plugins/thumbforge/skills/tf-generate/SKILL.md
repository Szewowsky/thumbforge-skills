---
name: tf-generate
description: >-
  Generate YouTube thumbnail candidates with the thumbforge CLI from a topic and
  a preset. Use when Robert wants Claude to produce thumbnail images for a video
  idea — "/tf-generate", "zrób miniaturę o…", "wygeneruj thumbnail", "potrzebuję
  miniatury na film o X", or hands you a topic plus optional reference images and
  wants candidates. You operate the CLI: pick a sensible preset/model, dry-run to
  show the plan and cost, and only spend money after Robert's explicit per-call
  consent. NOT for cloning or adapting a specific competitor's thumbnail from a
  URL/image (use tf-reverse), NOT for inferring a thumbnail from a video
  scenario/transcript (use tf-scenario), and NOT for editing an already-generated
  image or re-running a past session as-is — those are the paid `edit` / `retry`
  commands; fall back to the thumbforge umbrella, which drives them by hand.
  Prefer this skill whenever the ask is "make me a thumbnail for this topic".
argument-hint: "[topic] [--preset <id>] [--refs <paths>] [--variants N]"
allowed-tools: Bash
---

# tf-generate

Topic + preset + references → 1..N thumbnails, via `thumbforge generate`. The user
triggers; you operate. The flow is always: discover inputs → pick defaults →
estimate cost → dry-run → get consent → paid run → preview grid → deliver paths.

## Step 0 — Bootstrap (paid skill)

```bash
cd "/Users/robert/Windsurf Projekty/thumbforge"
thumbforge --help            # CLI reachable? (free)
```

Triple lock for the real run: env `THUMBFORGE_ALLOW_PAID_CALLS=1` (inline, never
`export`) + `--confirm` + dry-run-first. Consent is per-call: never re-run a
`--confirm` command without fresh approval. `THUMBFORGE_SECRET` **auto-loads**
from `.env.local` (allowlist — ADR 0005), so a direct `--confirm` run decrypts the
saved key on its own — you no longer source it. Full rules:
`../thumbforge/references/paid-call-protocol.md`.

## Workflow

1. **Discover before you choose (free).** Discover each dimension you are about to
   pick on the user's behalf — skip only the dimensions the user gave explicitly
   (a named `--preset`, a named style, explicit ref paths). The ids you pass MUST
   have appeared in these lists this session (the CLI does not reject an unknown
   preset — it silently falls back to a generic prompt, so the gate holds here):
   ```bash
   thumbforge list-presets                              # archetype (built-in + custom)
   thumbforge list-styles                               # text/background/recipe ids
   thumbforge list-refs --category character-primary    # the host's face
   thumbforge list-refs --category character-secondary  # guest/persona (collab-duo / host-plus-persona)
   thumbforge list-refs --category icon
   ```
   `list-refs` prints `/references/<category>/<id>.png` paths — pass those to
   `--refs`. Two-subject presets need one `character-primary` (host, first) + one
   `character-secondary` (guest/persona, second). Full rule (built-in vs custom, how
   to consume the output): `../thumbforge/references/discovery-contract.md`.
   When multiple refs in a category could fit, use `thumbforge list-refs` as the
   thin-client index, then inspect the relevant `_thumb.png` previews before
   picking. In repo/dev only, you may also run
   `pnpm cli refs:contact-sheet --category <category> --out <dir>`. Do not choose a
   face/icon/screen solely because the id or display name sounds right.
2. **Pick defaults.** Choose a preset that fits the topic (see
   `../thumbforge/references/presets-catalog.md`; for the design reasoning behind
   the choice — layout, text, hooks — read `../thumbforge/references/thumbnail-craft.md`
   and the pitfalls in `../thumbforge/references/gotchas.md`). Pick `--text-style`
   (and any background/recipe direction) from the `list-styles` output of step 1, not
   from memory — that is how this account's custom styles get used. Sensible defaults:
   provider `openai`, model `gpt-image-2`, quality `low` for a test / `high` for a
   final, `--variants 1`. Confirm real values with `thumbforge generate --help` and
   `thumbforge inventory`. State the choices to the user; don't over-ask.
3. **Estimate cost (free).**
   ```bash
   thumbforge cost-estimate --count <variants> --model gpt-image-2 --quality <q>
   ```
4. **Dry-run (free).** Run `generate` WITHOUT `--confirm` to surface the resolved
   prompt + plan:
   ```bash
   thumbforge generate --preset <id> --topic "<topic>" \
     [--visible-text "<headline>"] [--refs <p1,p2>] [--variants N] --quality <q>
   ```
   The dry-run also prints a **pre-flight checklist** (key / secret / `--out`) —
   resolve any `⚠` before asking for consent. Show the user the plan + the cost
   estimate, then **wait for explicit consent**.
5. **Paid run (only after consent).** The secret auto-loads — just run:
   ```bash
   THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge generate \
    --preset <id> --topic "<topic>" \
    [--visible-text "<headline>"] [--refs <p1,p2>] [--variants N] \
     --quality <q> \
     --out "$HOME/Downloads/<temat-slug>" \
     --confirm
   ```
   `--out` is an **export policy, not a lock** (ADR 0005): default it to an
   absolute `$HOME/Downloads/<temat-slug>` so the user always knows where the PNGs
   are (override on request; if `~/Downloads` is unavailable, fall back to the
   repo `public/generations`). Omit `--out` entirely and the images still land in
   `public/generations` (UI / `/sessions/batch/<run>`). The cost lock stays
   `--confirm` + `ALLOW=1`.
6. **Preview grid (ALWAYS, for 2+ images).** After a successful paid run that
   produced **two or more** images, ALWAYS compose a review grid and open it — the
   user expects a single side-by-side preview every time, not just on request:
   ```bash
   thumbforge grid <sessionId> --out "$HOME/Downloads/<temat-slug>/grid.png"
   ```
   Use the `sessionId` printed by the paid run. `grid` is **free** (no model call)
   and uses the server's final images for that session. Skip the grid only for a
   **single** image (a 1-up grid is pointless). Surface the grid path
   in the delivery alongside the individual finals.
7. **Deliver.** Report the session id, UI path (`/history` / `/sessions/<id>`),
   exported PNG dir, the preview-grid path (step 6), and a one-line summary (preset,
   model, quality, variants, cost). No JSON dumps.

## Flags (confirm with `thumbforge generate --help`)

| Flag | Use |
|---|---|
| `--preset <id>` | preset archetype (`list-presets`) |
| `--topic <t>` | the video topic (quote it) |
| `--visible-text <text>` | headline baked on the thumbnail (defaults to the preset's text style) |
| `--text-style <id>` | `<id>` from `thumbforge list-styles --type text` (built-in + custom); `none` keeps a text-less base |
| `--text-color <hex>` | headline color `#RRGGBB` (default `#FFFFFF`) |
| `--glow-color <hex>` | brand glow / rim-light color `#RRGGBB` — tints background, rim light & accents (e.g. teal `#14B8A6`); hex only, non-hex dropped |
| `--background-style <id>` | background style id from `thumbforge list-styles --type background` (built-in + custom); replaces the preset's default background sentence |
| `--refs <p1,p2>` | comma-separated reference paths (order matters — see below) |
| `--provider openai\|google` | provider (default openai) |
| `--model <id>` | model (`list-models`; default gpt-image-2) |
| `--quality <tier>` | quality tier (low test / high final) |
| `--variants <n>` | images per preset (default 1) |
| `--concepts-file <abs.json>` | batch mode: one logical Run with per-concept preset/text/refs/glow/quantity; >4 images split into ≤4-image sessions |
| `--out <absDir>` | optional export dir — also copy finals here; omit and images still land in `public/generations` |
| `--confirm` | spend money (also needs the env) |

## Load-bearing rules

- **Ref ordering is positional.** For `collab-duo` and `host-plus-persona`, the
  host is `character-primary` and must be the FIRST character-role ref in
  `--refs`; the guest/persona is `character-secondary` and goes second. The
  resolver clusters refs by role and preserves order within the character bucket,
  so don't interleave other character refs between them and don't pass the guest
  as `character-primary` — either way the model swaps host and guest.
- **Visual ref choice.** `list-refs` is discovery, not eyesight. Run
  `refs:contact-sheet` or inspect ambiguous `_thumb.png` previews before selecting
  refs, especially face slots where a named person might be a torso/hoodie crop
  rather than a usable face.
- **NO_TEXT_GUARD.** If the user wants text on the thumbnail, pass `--visible-text`.
  An empty visible text triggers a guard in the resolver — that's intended.
- **`--out`** must be absolute — it is an export copy, not a cost lock (ADR 0005).
  In the **dev CLI** it is optional: the CLI writes the canonical session files to
  `public/generations`, so history and previews work whether or not `--out` is
  passed. In **thin-client mode** (the installed `thumbforge` launcher driving the
  running desktop app) `--out` is **REQUIRED** — the CLI can't write into the app's
  userData, so it needs an export dir or `generate` errors `--out <absDir> jest
  wymagany`. Either way, default it to `$HOME/Downloads/<temat-slug>` for a tidy
  hand-off so the run never fails on a missing `--out`.
- **Batch mode.** If the user wants several concepts for one video, prefer
  `--concepts-file <abs.json>` over repeated single-concept runs. It creates one
  session and reduces noisy duplicate-looking history rows. The discovery gate +
  JSON format live in `../thumbforge/references/discovery-contract.md`.
- Don't reorder slots, don't hand-build prompts — the CLI resolver owns that.

## Errors

See `../thumbforge/references/troubleshooting.md`. If a path in `--refs` 404s,
re-run `list-refs` for the current paths. `command not found` means a stale name
— it's `cost-estimate`/`list-presets`, never `cost`/`list`.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają **`thumbforge`** — cienki klient HTTP. U testera z samą
aplikacją (.dmg, bez repo) `thumbforge` jest wbudowany w apkę (instalacja: ikona w
tray → „Zainstaluj CLI"). W repozytorium (dev) `thumbforge` to launcher do
bezpośredniego CLI — raz wykonaj `pnpm link --global` (albo używaj równoważnego
`pnpm cli <komenda>`).

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `inventory`, `cost-estimate`, `generate`, `reverse`, `analyze-transcript`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `edit`, `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
