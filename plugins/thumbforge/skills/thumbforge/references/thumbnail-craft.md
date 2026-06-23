# Thumbnail craft (universal)

Battle-tested design knowledge for high-CTR YouTube thumbnails, distilled from
eye-tracking research and production iteration. It is **universal** — it works for
any creator, any niche, any language. Channel-specific taste (brand voice, exact
wording, preferred expressions) is the user's input, not a rule here.

**How thumbforge applies it:** the CLI `generate` does **not** take a raw prompt —
the resolver (`src/lib/presets.ts`) builds the prompt from the **preset**. So you
steer the design through four levers, not free text:

- `--preset` — the composition archetype (see §5)
- `--visible-text` — the headline baked into the image (see §3)
- `--refs` — which reference images fill the preset's slots (see §7)
- `--quality` — `low` to explore, `medium` to judge, `high` to ship (see gotchas)

Read this before choosing a preset/text for a concept. The pitfalls that *kill* a
thumbnail live in `gotchas.md` — read both.

## 1. Layout: where the eye goes

Eye-tracking on thumbnails is lopsided. Attention by quadrant:

```
┌───────────────────┬───────────────────┐
│  41%  top-left    │   20% top-right   │
├───────────────────┼───────────────────┤
│  25%  bottom-left │   14% bottom-right│
└───────────────────┴───────────────────┘
```

**~66% of first attention lands on the LEFT.** Two consequences:

- **Text left or center, face/subject right.** This is the dominant, reliable
  layout. The viewer reads the hook, then meets the face.
- **Mobile reality:** most views are on phones, where the thumb covers the
  **right** side — so the critical message must survive on the left.

Dominant schema: **headline (top-left) + a supporting element (bottom-left:
logo / object / screenshot) + face (right).** If you have no supporting element,
fall back to: **headline (center-left) + face (right).**

## 2. Rule of 3 — less is more

A viewer decodes a thumbnail in under a second. Every extra element lengthens that
and lowers CTR. Aim for **at most three core visual elements**:

1. a focal image (an expressive face),
2. text (a short phrase),
3. one context element (object, icon, logo, or screenshot).

Adding a 4th/5th element reads as clutter. When in doubt, remove.

## 3. Text

The thumbnail headline is a *complement* to the title, not a repeat of it — they
together form one promise (see §8). Make it instantly legible:

- **Heavy bold sans** (Impact / Bebas / Anton / Montserrat Black). Thin fonts smear
  at the ~320px feed size.
- **White letters + thick black outline (4–8px)** or a strong drop shadow. Never
  raw text straight on the photo — it disappears against busy areas.
- **Big:** letters ≈ 20–27% of frame height. Use the space.
- **Short:** 3–5 words (~20 characters) per line. Long copy can't be read at scale.
- **Color contrast with the background** — pick the opposite of whatever sits
  behind the text.

Test it: shrink the thumbnail to a tiny size while you work. If the text isn't
readable small, it's too small or too long.

Non-ASCII text (Polish `Ą/Ę/Ł`, accents, CJK) is a known gpt-image-2 weakness —
keep it short and see `gotchas.md` for mitigation.

## 4. Expression

A clear, expressive face is one of the strongest attention magnets. Keep it
**readable and intentional**; tune intensity to the audience and brand. A confident
or knowing look reads as authority; a bigger reaction reads as drama. Neither is
universally "right" — choose per video. The over-exaggeration trap is in
`gotchas.md`.

## 5. Archetype → preset map

Pick the preset whose composition matches the story you're telling.

| Archetype | thumbforge preset | Use it for |
|---|---|---|
| Hero shot (chest-up, ~45% face, shoulders in frame — not extreme close-up) | `hero-chest-up` | one product/tool, a launch, a single clear claim |
| Hero + gesture (finger points at the left text/object) | `hero-pointing` | high energy, "look at this", directing the eye left |
| Icon holder (person + 2–8 app/tool icons) | `icon-holder-single` / `icon-holder-grid` / `icon-holder-mascot` | comparisons, round-ups, ecosystems, "N tools" |
| Screen show (person presenting a UI/screen) | `screen-show` | demos, tutorials, "how to use X" — needs a real `screen` ref |
| Reaction close-up (face dominant, sandwich text top+bottom) | `reaction-shocked` | news/reaction — but see the expression caveat in `gotchas.md` |
| Split before/after (two zones, old vs new) | `split-before-after` | transformations, comparisons, "this → that" |
| Two people side by side | `collab-duo` / `host-plus-persona` | collabs, host + guest/persona (ref order is load-bearing) |

Run `pnpm cli list-presets` for the live list (custom presets included).

## 6. Hooks that pull clicks

The image should promise something worth a click. Reliable patterns:

- **Number / money hook** — a big number or amount on the left (e.g. a count, a
  result), face on the right, supporting icons between. Concrete and curiosity-
  driving; digits also render more reliably than words.
- **Curiosity / mystery** — a blurred or partially hidden element the viewer wants
  resolved.
- **Before / after** — a visible contrast that implies a payoff.

## 7. References & series continuity

The preset declares slots; `--refs` fills them. Typical mapping:

- **face / character** → the host's face (category `character-primary`)
- **icon** → a brand logo or app icon (category `icon`)
- **style inspiration** → a layout/mood cue (category `inspiration`) — this slot is
  cross-preset and explicitly **NOT for facial identity**, so it won't override the
  face ref.
- **screen** → a UI/dashboard screenshot (category `screen`), required for a
  convincing `screen-show`.

**Series-continuity toolkit.** For an episodic series, keep the look consistent:

1. Upload the **previous episode's final thumbnail** as an `inspiration` ref
   (`pnpm cli upload-ref --category inspiration`). It carries palette, layout, and
   motif without touching identity.
2. Upload the **brand logo** as an `icon` ref.
3. Pass face + logo + prev-final together; the resolver places them.

For pixel-tight continuity, `tf-reverse` can clone the previous thumbnail into a
reusable custom preset.

**A/B within a series:** a template is fine, but the thumbnails **must differ** per
episode (mood, lighting, composition). Identical-looking episodes blur together in
the feed. Generating ~4 distinct concepts per round is a healthy default.

## 8. The promise triangle: thumbnail → title → intro

Design in this order, and make all three say the same thing:

1. **Thumbnail** — the visual promise.
2. **Title** — the verbal promise (complements the thumbnail, doesn't duplicate it).
3. **Intro** — extends the same promise in the first seconds.

A mismatch between thumbnail/title and the actual video is clickbait — it spikes
clicks but tanks retention, which YouTube punishes.

## Photographic vocabulary (quality, not CGI)

These read as *real photography* and help identity survive: `unretouched DSLR
photograph`, `natural photo`, `85mm lens`, `shallow depth of field`, `rim light`
(separates subject from a dark background), `cinematic color grading`. The resolver
already weaves the right ones in per preset — you rarely set these by hand, but know
why they're there. The keywords that *break* faces are in `gotchas.md`.
