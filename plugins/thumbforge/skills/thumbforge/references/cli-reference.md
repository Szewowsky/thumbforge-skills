# thumbforge CLI — command map

**The authoritative flag reference is `thumbforge <command> --help`** — it is
generated from code and never drifts. This file is a thin map (command → purpose
→ where to get flags). Do not memorize flag tables here; run `--help` when you
need exact flags.

Run the initial handshake from any directory: `thumbforge --help`. Use `pnpm cli`
only for commands marked repo/dev-only and only after the shared manifest check.

| Command | Paid? | Needs `--out`? | Purpose | Flags |
|---|---|---|---|---|
| `list-models` | no | no | repo/dev-only image models + pricing (thin: `inventory`) | `--help` |
| `list-presets` | no | no | built-in + custom presets | `--help` |
| `list-styles` | no | no | text / background / recipe styles (built-in + custom) | `--help` (`--type text\|background\|recipe`) |
| `list-expressions` | no | no | built-in + custom expression bricks and preset defaults | `--help` |
| `list-refs` | no | no | reference images on disk | `--help` (`--category`) |
| `inventory` | no | no | one-shot overview: presets + styles + models + refs | `--help` |
| `list-sessions` | no | no | past generation sessions | `--help` |
| `cost-estimate` | no | no | estimate batch cost (no provider call; cost is preset-independent) | `--help` (`--count`, `--model`, `--quality`, `--provider`) |
| `generate` | **yes** | opt (export) | generate thumbnails (single or batch) | `--help` (`--visible-text`, `--text-style`, `--text-color`, `--glow-color`, `--background-style`, `--expression`, `--concepts-file`) |
| `grid` | no | yes (`--out`) | session grid or Grid Runu | `--help` (`<sessionId>` / `--batch`) |
| `reverse` | **yes** | no | analyze a competitor thumbnail → preset | `--help` (`--url`/`--file`, `--context`, `--apply`) |
| `analyze-transcript` | **yes** | no | infer slot values from a scenario | `--help` (`--text`, `--preset`) |
| `analyze-titles` | **yes** | no | turn 1-3 title candidates into thumbnail concepts | `--help` (`--title`, `--titles-file`, `--context`) |
| `eval` | **yes** | yes (real run) | golden-set eval | `--help` |
| `retry` | **yes** | yes (real run) | re-run a session | `--help` (`--session`) |
| `edit` | **yes** | yes (real run) | instruction-edit an image | `--help` (`--session`, `--image`) |
| `config-set` | no | no | store an encrypted API key | `--help` (`--provider`, `--key`) |
| `upload-ref` | no | no | add a reference image | `--help` (`--file`, `--category`, `--name`) |
| `refs:rethumb` | no | no | rebuild reference `_thumb.png` previews | `--help` (`--category`) |
| `refs:contact-sheet` | no | yes (`--out`) | labeled visual sheet for reference selection | `--help` (`--category`, `--out`) |
| `preset:slots` | no | no | a preset's slots (built-in or custom) | `--help` |
| `preset:show` | no | no | a preset's 6 spec blocks; `--block` emits one raw block | `--help` (`--block`) |
| `preset:create` | no | no | fork a built-in/custom into a custom preset | `--help` (`--from`, `--name`, `--*-style`, `--default-expression`, `--glow-color`, `--*-file`) |
| `preset:edit` | no | no | edit a custom preset (name / styles / blocks) | `--help` (`--name`, `--*-style`, `--default-expression`, `--glow-color`, `--*-file`) |
| `preset:preview` | no | no | replace a custom preset grid cover | `--help` (`--from`) |
| `preset:delete` | no | no | soft-delete a custom preset | `--help` |
| `style:create` | no | no | author a text/background style | `--help` (`--type`, `--from`, `--sentence`, …) |
| `style:edit` | no | no | edit a custom style (full-input merge) | `--help` |
| `style:delete` | no | no | soft-delete a custom style | `--help` |
| `expression:create` | no | no | author a custom expression (mina/poza) | `--help` (`--label`, `--face-fragment`, `--pose-fragment`) |
| `expression:edit` | no | no | edit a custom expression | `--help` |
| `expression:delete` | no | no | soft-delete a custom expression | `--help` |

Notes:
- Stale names that DON'T exist: `list`, `cost`. Use `list-presets`/`list-models`/
  `list-refs`/`list-sessions` and `cost-estimate`.
- Paid commands (`generate`, `reverse`, `analyze-transcript`, `analyze-titles`, `eval`, `retry`,
  `edit`) need the triple lock — see `paid-call-protocol.md`.
- `--out` is **optional** for `generate` only in the verified **dev CLI** (export policy, ADR
  0005): omit it and the images still land in `public/generations`; pass it to
  ALSO copy the finals there. In **thin-client mode** (installed launcher → running
  app) `--out` is **REQUIRED** for `generate` — the CLI can't reach the app's
  userData, so omitting it errors `--out <absDir> jest wymagany`. It also stays
  **required** for the real run of `retry`, `edit`, and `eval`. `reverse` and
  `analyze-transcript` have no `--out`.
- `list-refs` prints `/references/<category>/<id>.png` paths — feed those to
  `--refs`.
- `refs:rethumb` is free + local: it rebuilds display thumbnails only and never
  rewrites the original reference PNG paths stored by sessions.
- `refs:contact-sheet` is free + local: it composes existing `_thumb.png` previews
  into a labeled PNG (`id` + display name) so agents choose refs by visible
  content, not filenames.
- **Headline text:** `generate --visible-text "..."` now bakes the headline. With
  no `--text-style` it defaults to the preset's text style (or `heavy-bold`);
  `--text-style none` keeps a clean text-less base. `--text-color` is `#RRGGBB`.
- **Brand glow:** `--glow-color <#RRGGBB>` tints the `[STYLE]` background, rim
  light and accents toward a brand hue (e.g. `--glow-color #14B8A6` = teal glow).
  Additive over the preset background (biases palette, never replaces look); hex
  only, non-hex silently dropped like `--text-color`. On `preset:create` /
  `preset:edit`, the same flag stores the fork's default glow; on `generate`, it
  is a one-run override.
- `grid` is free and server-composed (no provider): use `<sessionId>` for one
  session or `--batch <batchId>` for the whole Run. Arbitrary `--images` is a
  repo/dev-only legacy surface.
- **Styles:** `list-styles` shows built-in + this account's custom text/background/
  recipe styles. `generate` has `--text-style`, `--text-color`, `--glow-color`, and
  `--background-style` (single-concept); for **batch** set the same per-concept in
  `--concepts-file` (`textStyle`/`textColor`/`glowColor`/`slotValues.background_style`).
  A **recipe** must still be decomposed into bg + text + colors by hand (no `--recipe`).
- **Batch:** `generate --concepts-file <abs.json>` runs many concepts (≤4, ≤16
  images) as one logical Run. The CLI splits >4 images into review-sized
  sessions and prints `/sessions/batch/<runId>`; prefer it over looping single
  `generate` calls. Per concept: `preset`/`visibleText`/`textStyle`/`textColor`/
  `glowColor`/`refs`/`slotValues`/`quantity`; `provider`/`model`/`quality`/
  `topic` may be per concept; the top-level `--topic` remains a fallback.
- **Discovery:** before proposing, list the dimension you're about to pick — or run
  `inventory` for all of them at once. See `discovery-contract.md`.
- **Expressions (mina/poza):** `list-expressions` shows built-in and custom ids,
  labels, pose markers and preset defaults. `generate --expression <id>` overrides the
  preset's default expression for one run (per-concept `expression` in a
  `--concepts-file`). Unknown ids fail before a paid call. A brick's pose fragment
  lands only on presets that opt into poses. Custom preset defaults use
  `preset:create|edit --default-expression <id|none>`.
- **Custom presets/styles/expressions (free):** `preset:*` / `style:*` /
  `expression:*` are file/SQLite CRUD —
  no model call, no `--out`, no paid lock. A custom preset is a FORK of a built-in
  (name + default styles + the editable `[COMPOSITION]`/`[ELEMENTS]`/`[STYLE]`
  blocks; slots + locks frozen). Edit a block by starting from `preset:show <id>
  --block <name>`. Full workflow → **tf-preset**.
