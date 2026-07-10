# Discovery-then-propose contract (universal, all tf-* skills)

The rule that makes thumbforge skills work on **any** account, not just the one
they were written on.

> **These skills are production software for any user.** The set of archetypes
> (presets), text/background/recipe styles, and reference images is **per-account**
> — the built-in globals PLUS whatever this user has forked, reverse-analyzed, or
> uploaded. You do not know that set until you ask. A channel's taste (spelling,
> brand voice, expressions, language) is the **user's input**, never a global rule.

## The rule — discover the dimension before you choose it

Before you propose or pass a resource **on the user's behalf**, discover the live
set for *that* dimension first. This is keyed to what you are about to pick — it is
NOT "run every `list-*` on every turn".

| You are about to choose… | Discover first (free) | Skip the lookup when… |
|---|---|---|
| an archetype / preset | `thumbforge list-presets` | the user named `--preset <id>` |
| a text / background / recipe style | `thumbforge list-styles [--type text\|background\|recipe]` | the user named the style |
| which refs fill the slots | `thumbforge list-refs [--category <c>]`, then visually inspect candidates when the choice is ambiguous | the user gave explicit ref paths |
| a model | `thumbforge inventory` | sticking to the documented default |

**Shortcut:** `thumbforge inventory` (free) prints all four dimensions at once
(presets + styles + models + refs, built-in AND custom) — one call instead of
four. Prefer it when you're about to propose and want the whole account picture
(e.g. tf-scenario's 4 diverse concepts). Use the individual `list-*` when you only
need one dimension.

A pure repo/dev-only `pnpm cli retry <session>` chooses nothing new → no discovery needed.

**The static maps in `thumbnail-craft.md` (§5 archetype→preset) are DESIGN
REASONING** — which composition suits which story. They are NOT the source of
concrete ids. Every id you pass to the CLI must have appeared in a `list-*` result
**this session**. Proposing an id you never saw listed is the exact failure this
contract prevents (and the CLI does not hard-reject an unknown preset — it silently
falls back to a generic prompt, so the gate has to hold here, in the skill).

## Built-in vs custom — both are real, treat them equally

- `list-presets` marks each row `built-in` or `custom`; a custom prints its fork as
  `(fork: <basePresetId>)`. When you reason about a CUSTOM preset, map it onto the
  archetype map via that base — a custom forked from `hero-pointing` plays the
  "hero + gesture" role. Never skip a custom just because it isn't in the static
  catalog; surfacing the user's own customs is the whole point of discovery.
  (Note: `list-presets` does NOT print a preset's slots — for slot detail the
  source is `thumbforge preset:show <id>`.)
- `list-styles` marks `built-in` / `custom` per row, grouped TEXT / BACKGROUND /
  RECIPE. A user's custom styles only appear here — the static 4-style text list is
  reasoning-only.

## How to consume the output (it is human-readable, not JSON)

- `list-presets` → `kind  id  name [ (fork: base) ]`. Build your candidate set from
  the live ids; fold customs in via their base.
- `list-styles` → groups `TEXT` / `BACKGROUND` / `RECIPE`, each `kind  id  name — desc`.
- `list-refs` → `category · count`, then `id  /references/<cat>/<id>.png · name`.
  Pass the printed **path** to `--refs`, never the bare id. Roles, not people:
  `character-primary` = the host (this account's primary on-camera person),
  `character-secondary` = a guest / persona (second subject in two-subject presets).

## Visual ref inspection — names are not enough

`list-refs` is the index, not the final judgment. When a category has several
plausible refs, or when identity/pose matters, inspect the existing
`<id>_thumb.png` images before choosing. In the thin client, inspect candidates
in the app's References library. In verified repo/dev mode, a contact sheet is available:

```bash
pnpm cli refs:contact-sheet --category <category> --out /tmp/thumbforge-ref-sheets
```

Then inspect the written PNG. Do not assume a repo `public/` tree exists for a
tester or buyer.

Choose refs by what is actually visible, not by the filename or display name. A
file named after a person can still be a torso crop, hoodie, logo, or other poor
face-lock input. If the thumbnail does not clearly show the face/asset the slot
needs, skip it and pick a better candidate or ask the user for a new reference.

## How each style dimension is actually applied (generate has no bg/recipe flag)

`generate` only exposes `--text-style`, `--text-color`, `--glow-color`. So:

- **text style** → `--text-style <id>` (single) or `textStyle` (concepts-file).
- **background style** → `--background-style <id>` (single) or
  `slotValues.background_style` (concepts-file). It replaces the preset's default
  background SENTENCE; the preset's separate ASPECT `lighting` hint is independent.
- **recipe** → decompose it by hand into its parts (background_style + text-style +
  colors) and set those; there is no `--recipe` flag.
- **brand glow** → `--glow-color <#RRGGBB>` (single) or `glowColor` (concepts-file);
  both map to `slotValues.background_color` (a tint clause added over the background).
  For a reusable fork, set the default with `preset:create --glow-color` /
  `preset:edit --glow-color` and use generate-time glow only as a one-run override.

## Batch-first generation (one Run, not a loop)

**Najpierw rozróżnij: warianty ≠ koncepty.** N kandydatów JEDNEGO konceptu
(user: „zrób 4 miniatury o X") ⇒ zwykłe `generate --variants N` — jeden run,
jedna sesja `0/N`, ZERO JSON-a. `--concepts-file` jest wyłącznie dla N RÓŻNYCH
konceptów (inne presety/teksty/refy per sztuka).

When you have **more than one** concept/archetype, generate them ALL in a single
`thumbforge generate --concepts-file <abs.json>` — one logical Run, one dry-run,
one consent. The CLI may split a >4-image Run into several review-sized sessions,
then print `/sessions/batch/<runId>` for combined review. Never loop
single-concept `generate` calls: that creates unrelated sessions (the "x2/x4"
duplicate-history problem) — dotyczy też wariantów: N osobnych runów zamiast
`--variants N` to ten sam antywzorzec. Use a single `--preset` call only for
a single concept.

`--concepts-file` takes an **absolute** path to JSON that is either an array or
`{ "concepts": [ … ] }`. Per-concept fields:

```json
{
  "concepts": [
    {
      "preset": "screen-show",
      "visibleText": "5 NARZĘDZI W JEDNYM!",
      "textStyle": "heavy-bold",
      "textColor": "#FFFFFF",
      "glowColor": "#0AC6AA",
      "slotValues": { "background_style": "dark-gradient-rim" },
      "refs": [
        "/references/character-primary/<id>.png",
        "/references/screen/<id>.png"
      ],
      "quantity": 1
    }
  ]
}
```

- `preset` is required. `refs` is an alias for `refPaths` and must be public
  `/references/...` paths (not ids). `glowColor` → `slotValues.background_color`.
- **`provider`, `model`, `quality`, `topic` are NOT per-concept** — they are global,
  taken from the CLI flags and shared across the whole batch. Group concepts that
  share provider/model/quality/topic into one file.
- Limits: at most 4 concepts, 16 total images; `quantity` is clamped to 1..4.
- Per-concept ref auto-bind runs, but only binds slots with a prompt fragment; face
  slots are intentionally left to ref ORDER — so the positional invariant still
  holds: host (`character-primary`) FIRST, guest (`character-secondary`) second in a
  two-subject preset. (See `thumbnail-craft.md` §7 and the per-skill ordering rules.)

## Then — and only then — propose

After the relevant dimension(s) are discovered, present concepts/defaults to the
user, citing the discovered ids (built-in and custom). Then dry-run, get consent,
and run the paid batch under the triple lock (`paid-call-protocol.md`).
