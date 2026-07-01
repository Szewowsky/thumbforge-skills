---
name: tf-preset
description: >-
  Author and edit custom thumbnail presets and styles with the thumbforge CLI —
  the headless fork builder. Use when building, forking, or tweaking a reusable
  template or style rather than rendering images —
  "/tf-preset", "stwórz preset", "sforkuj archetyp", "zmień tło lub styl tekstu".
  Free CRUD.
argument-hint: "[create|edit|show a preset or style] [--from <base>] [--block <name>]"
allowed-tools: Bash, Read
---

# tf-preset

Two kinds of object, both **free** to author (no model call, no key, no paid
lock — local file + SQLite writes):

- **Custom style** = a small, standalone, reusable brick. Two types: a
  **background style** (one sentence describing the background/light, injected
  into a preset's `[STYLE]` block) and a **text style** (the headline's look —
  colours, stroke, font, position, prompt fragment). Each gets its own id and
  shows up in `list-styles`.
- **Fork-preset** = a **fork of a built-in archetype**: same slots, same
  parameters, same locked blocks — you change the name, the default styles, and
  the three editable blocks `[COMPOSITION]` / `[ELEMENTS]` / `[STYLE]`.

A style is the LEGO brick; a Fork-preset is the model that snaps a background
style + a text style + the frozen face/composition logic together. Build a brick
once, reuse it across presets and across generations.

## Not for

- Generating thumbnails → `tf-generate`.
- Cloning a competitor's thumbnail into a preset → `tf-reverse` (then refine here).
- Turning a scenario into concepts → `tf-scenario`.
- Listing or adding reference images → `tf-assets`.

## Step 0 — Bootstrap

```bash
cd "/Users/robert/Windsurf Projekty/thumbforge"
thumbforge --help            # CLI reachable? (free)
```

No `THUMBFORGE_SECRET`, no `THUMBFORGE_ALLOW_PAID_CALLS`, no `--confirm` — every
command here costs nothing. If you reach for a paid invocation you are in the
wrong skill (generation lives in **tf-generate**; see Routing in the `thumbforge`
umbrella).

The authoritative flags are always `pnpm cli <command> --help`. `docs/cli.md`
(§"Custom presets" / §"Custom styles") is the human overview. Deep mechanics and
the validator rules live in [references/preset-authoring.md](references/preset-authoring.md).

## Workflow — inspect first (free, always)

Discover the dimension before you pick it (see
`../thumbforge/references/discovery-contract.md`):

```bash
thumbforge list-presets               # built-in archetypes + this account's customs
thumbforge list-styles                # background / text / recipe styles (built-in + custom)
pnpm cli preset:slots hero-pointing   # repo/dev-only: slot detail; thin fallback is preset:show
thumbforge preset:show hero-pointing  # the 6 spec blocks: EDITABLE vs FROZEN, with bodies
```

`preset:show` is the companion to `preset:slots`: slots list inputs, `show` lists
the prompt blocks. Read it before forking so you know what you are changing.

## Workflow — author a style (the brick)

A background style is just a sentence:

```bash
thumbforge style:create --type background --name "Teal studio" \
  --sentence "Dark cinematic teal studio gradient with soft rim light and restrained cyan accents."
```

A text style is best seeded from a built-in (`heavy-bold`, `sandwich`,
`chunky-3d`, `sandwich-with-badge`, `count-headline`), then tweaked (the
SafeZoneGuardian auto-injects the edge-padding / central-85% / auto-scale phrases
— never drop them):

```bash
thumbforge style:create --type text --from heavy-bold --name "Teal heavy" --color "#0AC6AA"
```

Edit or remove later: `thumbforge style:edit <custom-id> …` (full-input merge +
re-validate) / `thumbforge style:delete <custom-id>` (soft-delete). After creating
a style, run `thumbforge list-styles` and copy its exact id — you will wire it into
the fork by id next.

## Workflow — fork a preset (PRIMARY path: style-level, no block edits)

Most forks only change the name + default styles. Safe, covers most needs:

```bash
thumbforge preset:create --from screen-show --name "SaaS Screen Roast" \
  --background-style <bg-style-id> --text-style <text-style-id> \
  --text-color "#FFFFFF" --glow-color "#0AC6AA"
```

**The validator does NOT check that a style id exists** — it will happily store a
dead `--background-style`/`--text-style` id and you get a silently broken preset.
So **verify every style id against `thumbforge list-styles` BEFORE `preset:create`**.
`--from` accepts a built-in id OR an existing custom id (you can fork a fork).
`--background-style none` (or `''`) clears it; `--text-style ''` clears the text
style. `--glow-color "#RRGGBB"` bakes a default brand tint into the fork; a
generation-time `--glow-color` still overrides it for that one run.

## Workflow — edit a block (ADVANCED path: composition / elements / style)

You **cannot write a block from scratch** — the validator pins the `{slot:NAME}`
token order, the `{*_block}` tokens and the safe-zone phrases, and rejects a
block that drops any of them. Always **start from the base bytes**:

```bash
thumbforge preset:show screen-show --block composition > /tmp/composition.txt
# edit /tmp/composition.txt — keep every {slot:…} / {*_block} token and every
# safe-zone phrase; change only the prose around them
thumbforge preset:create --from screen-show --name "SaaS Screen Roast" \
  --composition-file /tmp/composition.txt
# (--elements-file / --style-file for the other two editable blocks)
```

If `preset:create` prints a validation error list, the edit dropped a guardrail —
fix the block, do not work around it. `[FACE LOCK]` / `[PRESERVE]` /
`[EXPRESSION]` are frozen (byte-equal to the base) and have no `--*-file` flag.

## Workflow — edit / delete a preset

```bash
thumbforge preset:edit <custom-id> --name "Nowa nazwa" --text-color "#0AC6AA" \
  --glow-color "#0AC6AA"
pnpm cli preset:preview <custom-id> --from "/ABS/path/to/cover.png"  # repo/dev-only
pnpm cli preset:delete <custom-id>   # repo/dev-only soft-delete; old sessions still resolve on retry
```

`preset:edit` takes the same style/block flags as `preset:create` (patch
semantics, minus `--from`); `preset:preview` swaps the visible grid cover from a
local PNG/JPEG/WebP; only custom ids are editable — fork a built-in first.

## Workflow — validate the fork (free dry-run)

After building a fork, sanity-check what the real run would send — no spend:

```bash
thumbforge list-refs --category character-primary
thumbforge list-refs --category icon
thumbforge generate --preset <custom-id> --topic "Temat filmu" --refs "$FACE,$ICON"
```

Without `--confirm` this is a free dry-run that prints the resolved plan,
including the custom styles you wired in. To actually render images, hand off to
**/tf-generate** with `--preset <custom-id>` — that is a separate **paid** stage
with its own dry-run and its own consent.

Before filling `$FACE`/`$ICON`, use `thumbforge list-refs` as the thin-client
index and inspect ambiguous `_thumb.png` previews. In repo/dev only, you may run
`pnpm cli refs:contact-sheet --category <category> --out <dir>`. A validation dry-run should use refs whose
visible content matches the slot, not merely ids that sound right.

## Chain with tf-reverse (both directions)

- **reverse → here.** `tf-reverse` saves an analyzed competitor template as a
  **Reverse-preset** (a custom preset). Refine it here before generating:
  `thumbforge preset:edit <presetId> …` (rename, swap styles, adjust an editable
  block via `preset:show --block`).
- **here → reverse.** If the ask is "make a preset from this competitor
  thumbnail", that needs vision analysis — route to **/tf-reverse** first, then
  come back here to refine.

## Load-bearing rules

- **Slots + `spec.parameters` are frozen 1:1** to the base (the refPaths /
  host-guest order; see the project `CLAUDE.md` §1). You cannot add, remove, or
  reorder slots.
- **Refs are bound at generation time** (`generate --set-slot`), never baked into
  `preset:create`. A Fork-preset stores a template, not specific images.
- **Choose validation refs visually.** If the fork needs a face/icon/screen in the
  dry-run, inspect thumbnails for ambiguous candidates first; misleading crops make
  the preset look broken even when the template is fine.
- **`[FACE LOCK]` / `[PRESERVE]` / `[EXPRESSION]` stay byte-equal** to the base;
  only `[COMPOSITION]` / `[ELEMENTS]` / `[STYLE]` are editable, always from base
  bytes via `preset:show --block`.
- The resolver + validator own prompt assembly — never hand-concatenate blocks.
- **Authoring tip:** a fork still has to be a good thumbnail — sanity-check
  against `../thumbforge/references/thumbnail-craft.md` and
  `../thumbforge/references/gotchas.md`.

## Errors

See `../thumbforge/references/troubleshooting.md`. Quick hits: a validator error
list from `preset:create`/`preset:edit` means an editable block dropped a
`{slot:…}` token or a safe-zone phrase — re-pull the base with `preset:show
--block` and re-apply your change. A fork that generates a blank background
usually points at a `--background-style` id that does not exist — re-check
`thumbforge list-styles`.

## Reference docs

Load on demand:

- [references/preset-authoring.md](references/preset-authoring.md) — fork model,
  editable vs frozen blocks, validator rules in plain language, style anatomy,
  worked starter recipes.
- `../thumbforge/references/discovery-contract.md` — discover-before-propose.
- `../thumbforge/references/thumbnail-craft.md` — universal design craft.
- `../thumbforge/references/gotchas.md` — pitfalls that tank a thumbnail.
- `../thumbforge/references/troubleshooting.md` — common errors and fixes.

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
