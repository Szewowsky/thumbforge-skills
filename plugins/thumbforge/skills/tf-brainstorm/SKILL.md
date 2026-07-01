---
name: tf-brainstorm
description: >-
  Brainstorm original YouTube thumbnail concepts and turn the chosen one into a
  safe freeform thumbforge custom prompt. Use when inventing a thumbnail from
  scratch — "/tf-brainstorm", "wymyśl thumbnail", "brainstorm miniatury",
  "zrób swobodny prompt", or a topic plus references but no fixed preset.
argument-hint: "[topic/inspiration] [--refs <paths>] [--custom-prompt]"
allowed-tools: Bash, Read
---

# tf-brainstorm

Original concept → Swobodny prompt → handoff to `thumbforge generate
--custom-prompt`. This skill is for ideation and prompt composition first; it
does not spend during the brainstorm. The paid stage is a normal generate call
with dry-run-first, explicit consent, and the triple lock.

## Not for

- Generating directly from an existing preset → `tf-generate`.
- Cloning a competitor's thumbnail → `tf-reverse`.
- Concepts from a transcript → `tf-scenario`.
- Editing reusable presets/styles → `tf-preset`.
- Listing or adding reference images → `tf-assets`.

## Step 0 — Bootstrap (paid handoff skill)

```bash
cd "/Users/robert/Windsurf Projekty/thumbforge"
thumbforge --help            # CLI reachable? (free)
thumbforge inventory         # live presets/styles/models/refs overview (free)
```

Read and apply these guardrails before proposing concepts:

- `../thumbforge/references/paid-call-protocol.md`
- `../thumbforge/references/discovery-contract.md`
- `../thumbforge/references/thumbnail-craft.md`
- `../thumbforge/references/gotchas.md`

Triple lock for the later real run: env `THUMBFORGE_ALLOW_PAID_CALLS=1`
(inline, never `export`) + `--confirm` + dry-run-first. Consent is per-call:
never re-run a `--confirm` command without fresh approval.

## Workflow

1. **Discover live inputs (free).** Before selecting refs or style cues, discover
   what exists in this account:
   ```bash
   thumbforge list-refs --category character-primary
   thumbforge list-refs --category icon
   thumbforge list-styles
   thumbforge inventory
   ```
   `list-refs` is an index, not visual inspection. If several refs could fit,
   inspect the relevant `_thumb.png` previews. In repo/dev only, a contact sheet
   can help: `pnpm cli refs:contact-sheet --category <category> --out <dir>`.
2. **Brainstorm 2-3 concepts in chat.** Keep each concept short: layout, visible
   headline, refs to use, emotional hook, and the main risk. Do not run
   generation here.
3. **Choose one concept and compose the Swobodny prompt.** `--custom-prompt`
   bypasses the preset resolver, so any normally injected safety must be present
   manually:
   - If a face or identity ref is used, include a literal `FACE_LOCK` block that
     says the first reference image is the identity source, preserve exact
     photographic identity, and keep the full head inside the frame.
   - If visible text is present, include safe-zone text rules: central 85%
     safe-zone, at least 8% edge padding, and auto-scale/shrink the headline so
     nothing clips.
   - Keep the prompt specific enough to render: composition, subject, expression,
     background, lighting, text, and what to avoid.
4. **Dry-run the handoff (free).** `generate` always needs a `--preset` carrier — even in
   Swobodny prompt mode the server requires a non-empty preset id to enter generation. The
   carrier's *prompt* is fully replaced by `--custom-prompt`, but the carrier still drives slot
   auto-bind and ref ordering — so pick an archetype matching the concept's subject count (e.g.
   `hero-chest-up` for one person, `collab-duo` for two); refs come from `--refs`.
   ```bash
   thumbforge generate --preset hero-chest-up --topic "<topic>" \
     --custom-prompt "<freeform prompt>" \
     --refs <face,icon,...> \
     --provider openai --model gpt-image-2 --quality low \
     --out "$HOME/Downloads/<temat-slug>"
   ```
   Show the resolved plan and cost estimate, then wait for explicit consent.
5. **Paid run only after consent.**
   ```bash
   THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge generate --preset hero-chest-up --topic "<topic>" \
     --custom-prompt "<freeform prompt>" \
     --refs <face,icon,...> \
     --provider openai --model gpt-image-2 --quality high \
     --out "$HOME/Downloads/<temat-slug>" \
     --confirm
   ```
6. **Grid for 2+ images (free).**
   ```bash
   thumbforge grid <sessionId> --out "$HOME/Downloads/<temat-slug>/grid.png"
   ```
7. **Optional — turn a winning concept into a reusable template.** A Swobodny
   prompt is one-shot; the resolver does not save it as a preset. If the brainstormed
   thumbnail works and the user wants to reuse the layout, hand off to **/tf-reverse
   `--file <the generated PNG>`** — it analyzes the *rendered* image into a custom
   preset (Reverse-preset). That is the route to "my own template": brainstorm →
   generate → reverse → reusable preset. Note it is a separate **paid** vision call;
   only suggest it once the concept is proven.

## Existing template vs original concept

This skill is for **original** concepts (Swobodny prompt). If the user instead wants
to build on an **existing** template, that is just a normal preset run — route to
**/tf-generate `--preset <id>`** (optionally after brainstorming which preset fits).
Use Swobodny prompt only when no preset captures the idea.

## Load-bearing rules

- `--custom-prompt` is Swobodny prompt mode: the resolver does not add
  FACE_LOCK, expression fragments, or text safe-zone phrases for you. Re-inject
  FACE_LOCK and safe-zone text whenever refs/faces/text are part of the concept.
- `--custom-prompt` still needs a `--preset <archetype>` carrier — the server rejects a
  generate with an empty preset id ("Podaj --preset"). The carrier's prompt is overridden by
  `--custom-prompt`; choose it by subject count (single-subject archetype, or `collab-duo` for
  two).
- `medium` quality is blocked. Use `low` for dry-run/test framing and `high`
  for the final paid render.
- More than one concept or variant means one batch/session/grid, never repeated
  paid loops.
- Do not copy an exact competitor thumbnail. If the user wants to adapt a source
  thumbnail, route to **/tf-reverse** first; use this only for original concepts.
- No extra machinery here: this skill is prose plus the shared guardrail docs.

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
