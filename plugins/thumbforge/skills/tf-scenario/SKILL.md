---
name: tf-scenario
description: >-
  Turn a video scenario or transcript into thumbnail concepts with the thumbforge
  CLI. Use when Robert has the script/outline/transcript of a planned or recorded
  video and wants thumbnail ideas from it — "/tf-scenario", "mam scenariusz, zrób
  miniatury", "z tego transkryptu zrób thumbnail", "na podstawie tego skryptu
  zaproponuj miniaturę", or pastes/points at a scenario file. You read the scenario
  in-context and propose concrete thumbnail concepts for free, then generate them as
  a separate dry-run-and-consent step. NOT for a plain topic with no scenario (use
  tf-generate), and NOT for cloning a competitor's thumbnail (use tf-reverse). This
  needs the script/transcript text in hand (pasted or in a file) — a bare video URL
  is not an input; if Robert only has a link, that is tf-reverse, or fetch the
  transcript text first. Prefer this skill whenever the starting material is the
  video's script/transcript rather than a one-line topic.
argument-hint: "<scenario text or file> [--preset <id>]"
allowed-tools: Bash, Read
---

# tf-scenario

Scenario/transcript → concepts → (separately) generated thumbnails → preview grid.

**The analysis is done in-context, by you, for free.** You already hold the
transcript in context, so you reason over it directly — that beats the paid
`analyze-transcript` CLI extractor on quality, handles the full text (no shell argv
limit), costs nothing, and never hits a free-tier rate wall. The paid
`analyze-transcript` command stays available as a **fallback** (headless/automation,
or when the transcript isn't in context). Image generation is **always** a separate
paid stage with its own consent.

## Step 0 — Bootstrap (free)

```bash
cd "/Users/robert/Windsurf Projekty/thumbforge"
thumbforge --help            # CLI reachable? (free)
```

Triple lock for each real generation (step 3): env `THUMBFORGE_ALLOW_PAID_CALLS=1`
(inline, never `export`) + `--confirm` + dry-run-first. Consent is per-call.
`THUMBFORGE_SECRET` **auto-loads** from `.env.local` (allowlist — ADR 0005); you no
longer source it. Full rules: `../thumbforge/references/paid-call-protocol.md`.

## Workflow

### 1. Read the scenario (free)

If the user pasted the text, use it. If they pointed at a file, `Read` it — the full
text, no truncation. A bare video URL is not an input (that's `tf-reverse`, or fetch
the transcript first).

### 2. Discover this account's inventory (free — BEFORE you propose)

Proposing from memory or the static archetype map hides this account's own custom
presets/styles. So discover the live set first — these are the **only** ids you may
put in the concept table:

```bash
thumbforge list-presets    # built-in + custom archetypes (custom prints its fork base)
thumbforge list-styles     # TEXT / BACKGROUND / RECIPE ids (built-in + custom)
thumbforge list-refs       # face / icon / screen / inspiration refs that exist
```

Full rule (how to consume the output, built-in vs custom, batch format):
`../thumbforge/references/discovery-contract.md`.

If refs are not obvious from the list, run
`pnpm cli refs:contact-sheet --category <category> --out <dir>` or inspect the
relevant `_thumb.png` previews before putting them in a concept. Pick by visible
content — face, logo, UI, style — not by filename/display name alone.

### 3. Analyze in-context → concepts (free, DEFAULT — no consent needed)

You are the analyzer. Do it yourself, in context:

1. **Condense the scenario** to its essence: the hook, the core promise, the few
   beats that actually sell the click. This short version is what the user reviews.
2. **Propose ~4 DIVERSE concepts**, applying the craft rules and avoiding the traps:
   - `../thumbforge/references/thumbnail-craft.md` — layout, text, archetype→preset
     map (reasoning only — pick the real id from step 2), hooks, continuity toolkit.
   - `../thumbforge/references/gotchas.md` — what kills a thumbnail.
   - Concepts should differ in angle/composition, not be four phrasings of one idea.
   - **Every `preset`, style, and ref id you cite must have appeared in step 2's
     lists** (fold custom presets in via their fork base).
3. **Pick references** per the continuity toolkit (face = `character-primary`, brand
   logo = `icon`, previous episode's final = `inspiration`, UI shot = `screen`) from
   the `list-refs` output and visual preview; add assets via **/tf-assets** if
   missing.

Present the concepts as a table so the user can pick/refine before any spend (the
`topic` is shared across the batch, so it's stated once above the table, not per row):

| # | preset | visible_text + text-style | refs | risk | est. cost |
|---|--------|---------------------------|------|------|-----------|

Use `thumbforge cost-estimate` (free) to fill the cost column. Respect the channel's
own wording/voice — ask if unsure; don't impose a house style.

### 4. Generate concepts (PAID — separate stage, per-call consent)

This is its own paid stage. Either hand the chosen concepts to **/tf-generate**, or
run them here under the triple lock. Cost-smart shape:

- **Round 1:** the ~4 concepts at `--quality medium` to compare directions (cheap,
  but text/face legible).
- **Final:** the chosen winner at `--quality high`.

**Batch-first.** The four concepts differ in preset/text/refs, so generate them as
ONE logical Run with `--concepts-file` — not a loop of single `generate` calls.
The CLI may split that Run into review-sized sessions of ≤4 images and prints a
combined `/sessions/batch/<runId>` review URL. One dry-run + one consent covers
the whole batch. Write the concepts (ids from step 2) to an absolute JSON file
per `../thumbforge/references/discovery-contract.md`, then:

```bash
THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge generate \
  --topic "<shared topic>" --concepts-file /abs/path/concepts.json \
  --provider openai --model gpt-image-2 --quality medium \
  --confirm
```

`--out <absDir>` is optional here (ADR 0005) — add it only to also copy the
finals out of `public/generations`.

`provider`/`model`/`quality`/`topic` are global (shared by the batch); per-concept
`preset`/`visibleText`/`textStyle`/`glowColor`/`refs` live in the JSON. Dry-run first
(no `--confirm`), show the plan + `cost-estimate`, wait for the user's yes *this turn*.
For a single concept, a plain `--preset` call is fine.

### 5. Preview grid (ALWAYS, for 2+ images)

When you run the batch **here** (not via /tf-generate, which already does this),
ALWAYS compose a review grid of the finals and open it right after the run — the
user expects one side-by-side preview of the variants every time:

```bash
thumbforge grid <sessionId> --out "$HOME/Downloads/<temat-slug>/grid.png"
```

Use the `sessionId` printed by the paid run. `grid` is **free** (no model call)
and writes one PNG from the server's final images. Skip the grid only for a
**single** image. Surface the grid path when you deliver the session id + finals.

## Fallback — paid `analyze-transcript` (headless / transcript not in context)

Use this only when you genuinely cannot read the transcript into context (headless
automation), or you explicitly want the CLI extractor. It infers one preset's slot
values, so it **requires `--preset`**. Dry-run first (free — shows which slots will
be inferred), then the paid run:

```bash
THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge analyze-transcript \
  --text "<scenario>" --preset <id> --confirm
```

- **Long transcripts are fragile through `--text`** (shell argv: escaping + length).
  Condense before passing — which is exactly why in-context analysis is the default.
- Default extractor is `gemini-2.5-flash` (free-tier — may `429`; pass `--model`).
- This infers slots only; the image is still a separate `generate` run.

## Load-bearing rules

- **Discover before you propose.** Every preset/style/ref id in the concept table
  comes from step 2's `list-*` output, including this account's custom presets/styles
  — never from the static archetype map alone. See `discovery-contract.md`.
- **Visual refs before concepts.** If a category has several plausible refs, inspect
  the thumbnails and skip misleading crops. A named-person ref is not automatically
  a good face ref.
- **Concepts ≠ images.** Generation is always its own paid stage.
- **Each paid stage = its own consent.** analyze→generate is two stages; one yes
  never authorizes the next. One batch generate = one consent for that batch.
- **Batch the round, don't loop.** >1 concept → one `--concepts-file` session, not N
  single `generate` calls.
- **Don't hand-build prompts or reorder slots** — the resolver owns prompt assembly.
- **The headline complements the title, doesn't repeat it** (see craft §8).

## Flags — `analyze-transcript` (confirm with `thumbforge analyze-transcript --help`)

| Flag | Use |
|---|---|
| `--text <scenario>` | the scenario/transcript text (the only input channel) |
| `--preset <id>` | preset whose slots to infer — **required** |
| `--model <id>` | extractor model (default `gemini-2.5-flash`) |
| `--confirm` | spend money (also needs the env) |

`analyze-transcript` has no `--out` and no file/stdin input — only `--text`.

## Errors

See `../thumbforge/references/troubleshooting.md`. `429` → Google free-tier wall on
the default extractor; pass `--model` or use in-context analysis instead. Missing
`--preset` → the fallback command needs one; pick a preset first.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają **`thumbforge`** — cienki klient HTTP. U testera z samą
aplikacją (.dmg, bez repo) `thumbforge` jest wbudowany w apkę (instalacja: ikona w
tray → „Zainstaluj CLI"). W repozytorium (dev) `thumbforge` to launcher do
bezpośredniego CLI — raz wykonaj `pnpm link --global` (albo używaj równoważnego
`pnpm cli <komenda>`).

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `inventory`, `cost-estimate`, `generate`, `reverse`, `analyze-transcript`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `upload-ref`, `grid`.
Komendy `edit`, `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
