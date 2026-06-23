# Preset authoring — fork model, validator rules, style anatomy, recipes

Deep reference for `tf-preset`. The CLI command surface is in `docs/cli.md`
(§"Custom presets" / §"Custom styles") and `pnpm cli <command> --help`; this doc
is the *why* and the *gotchas*.

## The fork model

A **custom preset** is any preset outside the built-in archetypes, stored in the
`custom_presets` table. It has one of two origins:

- **Fork-preset** — built by forking a built-in archetype with `preset:create
  --from <built-in|custom>`, then changing the name, the default styles, and the
  three editable blocks. This is what `tf-preset` produces.
- **Reverse-preset** — derived from vision analysis of a competitor's thumbnail
  by `tf-reverse`.

Both are structurally identical; only their provenance differs. A Reverse-preset
is editable here too (it is just a custom preset). A Fork-preset can itself be
forked (`preset:create --from <custom-id>`).

A fork copies the base's **slots** and **`spec.parameters`** byte-for-byte
(frozen — the refPaths / host-guest ordering invariant), and keeps the locked
prompt blocks byte-equal. You only ever change four things: the **name**, the
**default background style**, the **default text style + colour**, and the
**three editable blocks**.

## Editable vs frozen blocks

A preset's `spec.positive` is six blocks, in this fixed order:

| Block | Editable? | What it holds |
|---|---|---|
| `[FACE LOCK]` | **frozen** | identity preservation — byte-equal to base |
| `[COMPOSITION]` | editable | layout, framing, subject placement |
| `[ELEMENTS]` | editable | the slot tokens placed in the scene |
| `[EXPRESSION]` | **frozen** | facial expression — byte-equal to base |
| `[STYLE]` | editable | look, lighting, `{background_style_block}` |
| `[PRESERVE]` | **frozen** | anti-drift constraints — byte-equal to base |

Inspect any preset's blocks with `pnpm cli preset:show <id>`. Pull one editable
block's raw bytes with `pnpm cli preset:show <id> --block composition` (also
`elements` / `style`, and `face-lock` / `expression` / `preserve` for reading).

## Validator rules (plain language)

Every `preset:create` / `preset:edit` runs the same validator as the web fork
builder. It rejects a draft (and prints the full error list) when an editable
block:

1. **Reorders or drops a `{slot:NAME}` token.** The token order must match the
   base — the resolver wires "FIRST reference on the LEFT" to it.
2. **Drops a `{*_block}` token** (e.g. `{background_style_block}` in `[STYLE]`,
   `{text_style_block}` in `[COMPOSITION]`). These are injection points the
   resolver fills.
3. **Drops a safe-zone phrase** carried by the base block — the edge-padding
   percentage, the "central 85%" enforcement, and the auto-scale hint. They keep
   text legible at thumbnail scale.

And it also rejects a draft when a **frozen** block (`[FACE LOCK]` /
`[EXPRESSION]` / `[PRESERVE]`) differs from the base by even one byte.

The practical consequence: **never write a block from scratch.** Start from
`preset:show --block`, change only the prose *around* the tokens and phrases, feed
it back via `--composition-file` / `--elements-file` / `--style-file`. An
un-edited block round-trips byte-equal, so you can safely pull → edit a little →
re-fork.

> The validator does **not** check that a `--background-style` / `--text-style`
> id actually exists. A typo'd or deleted style id is stored as-is and the preset
> silently loses that style at generation. Always confirm style ids against
> `pnpm cli list-styles` before wiring them in.

## Style anatomy

- **Background style** (`style:create --type background`) is a single
  `--sentence`. It is injected where `{background_style_block}` sits in `[STYLE]`.
  Keep it a concrete scene/light description, not a list of adjectives.
- **Text style** (`style:create --type text`) carries: `--color` /
  `--stroke-color` (`#RRGGBB`), `--stroke-width` (1–12), `--font-family-var`,
  `--font-weight`, `--position-spec`, `--guard-suffix`, and a `--prompt-fragment`
  token template using `{value}` / `{color}` / `{position}`. Seed from a built-in
  (`--from heavy-bold`) and tweak rather than authoring a fragment from zero. The
  SafeZoneGuardian auto-injects the edge-padding / central-85% / auto-scale
  phrases on every write — do not fight them.

A **recipe** style is a saved bundle of (background + text + colours); the CLI
has no `--recipe` flag, so decompose a recipe into its parts by hand when forking.

## Brand colour

When a fork should carry a brand hue, set it on the text style (`--color`) and/or
as a saved background-tinting default on the fork (`preset:create` /
`preset:edit --glow-color "#RRGGBB"`). Hex only; the validator rejects non-hex
defaults. A later `generate --glow-color "#RRGGBB"` is still a one-run override
over the fork default.

## Starter recipes (worked patterns)

Five small, reusable forks. Build the styles first, confirm their ids with
`pnpm cli list-styles`, then fork. Validate each with a free `generate` dry-run;
real rendering is a separate paid step in **tf-generate**.

1. **SaaS Screen Roast** — base `screen-show`. For "reviewing a landing page /
   SaaS tool". Cool dark studio background, strong legible text, screen as a flat
   panel with the host on one side and a short headline band on top.
2. **Tool Duel** — base `icon-holder-grid`. For comparing two-plus tools. Icons
   as peer objects (no single dominant icon), high-contrast tech-editorial look;
   bind the icon refs at generation with repeated `--set-slot`.
3. **Host + Persona Explainer** — base `host-plus-persona`. Host plus a
   persona/product as the second subject. Keep the host first and the persona
   second (no swap); host left/centre, persona an equal subject, no random props.
4. **Case Study** — base `collab-duo`. For "built this with X" case studies. A
   large readable screen panel, warm accent background without one dominating
   colour blob. (Use a `duo-screen` custom base only if `pnpm cli list-presets`
   shows it — it is not a built-in.)
5. **Clean Hero Pointing** — base `hero-pointing`. Fast single-subject thumbnails
   pointing at one icon/object. Minimal background, strong rim light, low clutter;
   bind the accent object explicitly with `--set-slot accent_object=…` at
   generation.

Each recipe is a *style change plus optionally one editable-block tweak* — never a
slot change. If a recipe seems to need a new slot, it needs a different base
archetype, not a slot edit.
