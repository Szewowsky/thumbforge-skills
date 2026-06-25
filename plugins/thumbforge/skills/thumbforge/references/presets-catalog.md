# Preset catalog (built-in archetypes)

The live, authoritative list (including this account's custom presets from reverse
analyses) is `pnpm cli list-presets`. **Run it** rather than trusting this
snapshot — custom presets come and go, and ids must match exactly. This file is
an orientation map for picking a built-in archetype.

There are **11 built-in** archetypes.

| id | name | use it for |
|---|---|---|
| `hero-pointing` | Hero Pointing | host pointing at the subject; high-energy single-person hero shot |
| `hero-chest-up` | Hero Chest-up | chest-up portrait of the host reacting to the topic |
| `icon-holder-grid` | Icon Holder Grid | a grid of tool/app icons (comparisons, roundups) |
| `icon-holder-mascot` | Icon Holder + Mascot | a primary icon/logo plus a mascot character |
| `icon-holder-single` | Icon Holder Single | one dominant icon/logo as the focal point |
| `reaction-shocked` | Reaction Close-up | shocked/expressive face close-up reaction |
| `screen-show` | Screen Show | host presenting a screen / UI / dashboard |
| `split-before-after` | Split Before/After | a before↔after split composition |
| `collab-duo` | Collab Duo | two hosts side by side (see ordering rule) |
| `split-hero` | Split Hero | centered face with two large glowing icon cards; uses `split-warm-cool` |
| `host-plus-persona` | Host + Persona | the host plus a persona/character (see ordering rule) |

> **`icon-holder-grid` ships a built-in headline style.** Its `defaultTextStyle`
> is `count-headline` (giant accent numeral + white headline, format
> `"LICZBA | NAGŁÓWEK"`, e.g. `"6 | ZA DARMO"`) and `defaultTextColor` is
> `#FFB700` (the numeral's accent — the headline is always white). Pass
> `--visible-text "6 | ZA DARMO"` and the preset bakes that layout; override the
> numeral colour with `--text-color` (e.g. brand teal `#0AC6AA`).

> **`split-hero` ships the warm/cool background.** Its `defaultBackgroundStyle`
> is `split-warm-cool`: deep charcoal base with a warm amber glow zone on the
> left and a cool cyan glow zone on the right, vertical rim split through the
> focal axis, side halos, and dark bands reserved for optional text. It needs one
> face ref and exactly two icon refs (left card, right card).

## Slots and references

Each preset declares slots (e.g. a face/character slot, an icon slot, a
style-inspiration slot). The CLI resolver binds the `--refs` you pass to those
slots in order. You don't manage slots by hand — pick a preset, pass the relevant
refs, and let the resolver place them.

To see a preset's slots, run `pnpm cli list-presets` (and, if you need detail,
the project's `src/lib/presets.ts` is the source). `list-refs --category <c>`
surfaces the available reference images and their categories (e.g.
`character-primary` is the host's face, `icon` is logos/app icons).

## Two-subject presets — ref ordering is load-bearing

`collab-duo` and `host-plus-persona` have **two** subject slots. The order of
`--refs` decides who goes where:

- **first `--refs` path = host, second = guest/persona.**

The resolver wires "FIRST reference on the LEFT" copy to this order. If you
reorder the refs, the model swaps host and guest. Never sort refs "to tidy up" —
pass them host-first.

`split-hero` is also order-sensitive: pass `--refs` as face first, then the left
icon, then the right icon. The prompt anchors FIRST=face, SECOND=left card,
THIRD=right card.
