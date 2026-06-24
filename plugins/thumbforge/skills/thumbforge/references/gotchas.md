# Thumbnail gotchas (universal)

The mistakes that quietly tank a thumbnail. Pair with `thumbnail-craft.md` (the
"do this") — this file is the "not this".

> **These skills are production software for any user.** Only universal,
> generalizable knowledge belongs here. A given channel's taste — preferred
> spelling/slang, brand voice, which expressions fit its persona, the language of
> the text — is the **user's input**, not a global rule. Respect or ask for it;
> never hard-code one creator's preference as if it applied to everyone.

## Layout

- **Nothing important in the bottom-right corner.** YouTube paints the duration
  timestamp there, and it's the lowest-attention quadrant. Keep text and key
  subjects out of it.
- **Text never on the right.** We read left-to-right and the phone thumb covers the
  right side. Text goes left or center.
- **Don't cram 4–5 elements.** Past three core elements, CTR drops (see Rule of 3 in
  `thumbnail-craft.md`). More stuff ≠ more clicks.

## Authenticity

- **No clickbait mismatch.** If the thumbnail/title promises something the video
  doesn't deliver in the first seconds, you buy a click and lose the retention —
  a bad trade on YouTube.

## Series

- **Vary thumbnails across a series.** A reusable template is good; identical-looking
  episodes are not — they blur together in the feed and cannibalize each other.
- **Don't ship a YouTube auto-suggested frame** as the thumbnail. A designed
  thumbnail beats a random video still almost every time.

## gpt-image-2 prompt traps (resolver-level — know them even though the resolver owns the prompt)

These are baked into how the presets prompt the model; they explain *why* certain
phrasings are avoided, and matter if you ever extend the resolver:

- **No CGI / hype keywords** — `8K`, `ultra-realistic`, `hyperrealistic`,
  `studio-quality render`, `cinematic premium portrait`. They push the model toward
  a plastic AI-render look and **destroy facial identity**.
- **No NEGATIVE prompt block.** Listing "no X, no Y" tends to *amplify* drift. Frame
  desired traits positively (preserve / maintain), not as prohibitions.
- **Don't describe facial hair (or other identity features) in words** — "neat
  mustache", "clean-shaven" all trigger drift. Let the face reference carry identity.
- **No `fire` / `flames` / `fire glow`** — reads as kitschy. Use `warm orange glow`
  or `subtle neon glow` instead.

## Expression — the over-exaggeration trap

Exaggerated shock (open mouth, wide eyes, jaw dropped, gasping) is **polarizing**.
It can lift CTR on some entertainment content and *erode trust/retention* on others
(expert, technical, premium-brand audiences often read it as cheap). Treat it as a
**deliberate, audience-specific choice**, not a default — which is exactly why
`reaction-shocked` is a niche preset, not the go-to. Match expression intensity to
the channel; ask the user if unsure.

## Non-ASCII text (diacritics, accents, CJK)

gpt-image-2 reliably mangles characters outside ASCII — Polish `Ą/Ę/Ł/Ż/Ś`, accented
Latin, CJK. Mitigation:

- Keep the headline **short** (fewer characters = fewer chances to fail).
- Judge text at **`medium` or higher**, never at `low`.
- If the model still garbles it, fix the text in the **post-gen editor** rather than
  burning regenerations.
- Numbers, currency symbols, and `=`/`→` render dependably — lean on them for hooks.

## Icons / logos

- An icon grid of **real brands needs real logo references** (category `icon`).
  Without them the model invents wrong, off-brand logos.
- If you want **generic / suggested** icons (e.g. "many tools" without naming any),
  that's fine and often better — but make it explicit that the tiles are generic;
  don't reference real companies you don't have logos for.
- Never let the model improvise a recognizable real brand from memory.

## Quality tiers (cost vs signal)

- `low` — layout exploration only; text and faces are unreliable, don't judge final
  quality here.
- `medium` — the sweet spot to compare concepts (text legible, face faithful).
- `high` — ship quality; spend it on the chosen winner, not the whole batch.

Estimate before you spend: `pnpm cli cost-estimate` is free.

## Text styles

- Five built-in text styles: `heavy-bold`, `sandwich`, `chunky-3d`,
  `sandwich-with-badge`, `count-headline`. `list-styles` is the live list.
- `count-headline` is the OG `icon-holder-grid` layout — a giant accent numeral
  plus a white headline, fed as a pipe-split `--visible-text "6 | ZA DARMO"`
  (segment 0 = numeral, segment 1 = headline). `icon-holder-grid` defaults to it
  with accent colour `#FFB700`; other presets default to their own style.
- With `--visible-text` present, the CLI bakes the preset's `defaultTextStyle`
  unless you pass `--text-style`. `--text-style none` suppresses text.
