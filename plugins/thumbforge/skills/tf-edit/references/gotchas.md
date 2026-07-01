# tf-edit gotchas

Use the smallest instruction that accomplishes the user request, then add only
the safety constraints needed for the current image.

## Identity

- For face edits, preserve facial identity exactly from the attached face
  reference or existing image.
- Reattach available face refs with `--refs` when the edit changes a person.
- Two-person images keep primary/host first and secondary/guest second. Do not
  swap subjects.
- Avoid describing facial hair, age, or other identity traits from memory; let
  the reference image carry identity.

## Text

- Keep all readable text inside the central 85% safe-zone.
- Restate edge padding and shrink/auto-scale when the request changes headline
  size, placement, or wording.
- Do not cover the bottom-right timestamp corner.
- Non-ASCII text is risky; use the existing rendered text when possible and
  inspect at final quality before accepting.

## Composition

- Preserve the existing composition unless the user explicitly asks to change it.
- Do not turn an instruction edit into a new thumbnail concept.
- This skill is instruction-only. Do not use mask, region-painting, or
  region-from-description flows here.
