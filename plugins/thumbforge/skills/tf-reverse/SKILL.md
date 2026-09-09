---
name: tf-reverse
description: >-
  Clone or adapt a visible YouTube thumbnail or supplied URL with the conversation model and
  free Thumbforge import. Use when users naturally ask to make a similar thumbnail,
  clone a visible thumbnail, or save its background, title style or expression.
argument-hint: "<youtube-url-or-image> [--context <my topic>] [tylko tło|napis|mina]"
allowed-tools: Bash, Read
---

# tf-reverse

A visible competitor thumbnail → conversation-model analysis → selected parts.
This skill never calls the app analyzer. Its explicit paid counterpart is
`/tf-reverse-auto`.

## Not for

- Generating from a plain topic with an existing preset → `tf-generate`.
- A thumbnail from a video scenario/transcript → `tf-scenario`.
- Refining the analyzed template afterwards → `tf-preset`.

## Step 0 — Bootstrap thin-first

Run `thumbforge --help` (free). If it fails: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray → Zainstaluj CLI.”
Then follow the shared [Bootstrap thin-first contract](../thumbforge/SKILL.md#step-0--bootstrap-thin-first); do not inspect repo files or guess a machine path before the handshake.

Triple lock for the real run: env `THUMBFORGE_ALLOW_PAID_CALLS=1` (inline, never
`export`) + `--confirm` + dry-run-first. Consent is per-call. The running app owns
the configured analyzer keys; do not inspect or source secret/config files. Full
rules: `../thumbforge/references/paid-call-protocol.md`.

## Workflow

1. **Analyze under the app's contract.** The pixels must be genuinely in your
   context (attachment or image content). A URL or filename without pixels is a
   fabrication, not an analysis: ask for the pixels, never fall back to paid.
   This uses the conversation model and is not free of the user's chat budget;
   logos are role-and-colour guidance, never pixel-perfect.
   ```bash
   thumbforge reverse:contract --context "<your video's topic>"
   ```
   That text is the exact prompt the app's analyzer receives - follow it
   verbatim (anti-plagiarism rules, subjects, icon topology, background /
   title / expression fields, JSON shape) and write ONE JSON object to a file,
   e.g. `$HOME/Downloads/<slug>-analysis.json`. Keep the background out of
   `preset_blocks.composition` and `preset_blocks.style`; it belongs to
   `background_style_analysis`. The user's
   topic goes in `--context`, never the source title (P0 below). The JSON is
   transport for import only: never upload or add source pixels to references;
   select face, icon and screen refs later for generation.
2. **Validate (free, no model call).**
   ```bash
   thumbforge reverse:import "$HOME/Downloads/<slug>-analysis.json" --source "chat" --model "<your model name>"
   ```
   Without `--save-*` flags nothing is written: the output names the base
   scaffold, the preset name, which parts are present (tło / napis /
   ekspresja) and `⚠` warnings (a STYLE or COMPOSITION sentence that mixes
   background with an object - the brand cannot replace that background; fix
   the JSON and re-import before any paid render). A rejected JSON prints the exact reason
   (missing brief/prompt, a part without a proposal, a placeholder token); fix
   and re-run - the app never saves half of it.
3. **Staged questions - only the unresolved ones.** Ask at most what the
   user's words left open, one short round:
   - **Parts:** whole composition as a preset, or only tło / napis / mina? A
     plain order ("zapisz tylko tło", "zrób z tego preset") answers this - do
     not ask again.
   - **Brand vs source:** by default the profile's palette and background replace
     the source's at generation time; typography remains `inherit` from the
     analyzed treatment unless the profile has an explicit typography direction.
     Ask only when the user hints at wanting the
     original background ("z tym fioletowym tłem") - the answer becomes an
     explicit `--background-style <id>` in tf-generate, not a change to the
     saved preset.
   - **Name:** preset name / expression name when the user cares; otherwise the
     analyzer's name stands.
   Everything the user already decided is a settled question.
4. **Review, then save (free).** Print the parts summary from validation back in
   one line each (tło: sentence, napis: typography + colour, mina: face
   fragment) and save exactly the selected ones - any subset, all-or-nothing:
   ```bash
   thumbforge reverse:import "$HOME/Downloads/<slug>-analysis.json" \
     --save-preset "<name>" --save-background --save-text --save-expression "<mina>"
   ```
   `--save-background` / `--save-text` create reusable styles visible in the
   pickers; `--save-preset` keeps the preset's own copies; `--save-preset
   --hidden` stores a draft usable for generation that never appears in the
   library. A JSON that carries only a part (just `background_style_analysis`)
   saves that part; asking it for a preset reports why there is no composition.
5. **Deliver.** Report the saved ids (`presetId`, style ids, expression id) +
   a one-line summary (scaffold, icons adapted, parts saved). No JSON dump.
6. **Optional chain → refine or generate.** Refine the preset first (free) with
   `/tf-preset` (`preset:show <presetId>`, `preset:edit <presetId>` - also the
   place to fix a `⚠` STYLE sentence with `--style-file`). Generate on it
   (paid) with `/tf-generate --preset <presetId>`: a **separate paid stage**
   with its own dry-run and consent, its own ref discovery (`list-refs` +
   `_thumb.png` inspection) and its own background choice (profile by
   default, `--background-style <id>` for the source's). A saved expression is
   an ordinary custom expression usable on ANY preset via `--expression <id>`.

## Flags (confirm with `thumbforge reverse --help` / `reverse:import --help`)

| Flag | Use |
|---|---|
| `reverse:contract --context <text>` | the analysis contract for Path B (free) |
| `reverse:import <file>` | validate a JSON analysis; with `--save-preset [name]` / `--hidden` / `--save-background` / `--save-text` / `--save-expression [name]` save those parts (free, atomic); `--source` / `--model` record provenance |

`reverse` and `reverse:import` have no `--out` - they produce presets and
styles, not images.

## Load-bearing rules

- **P0 - `--context` is the user's topic, never the source title.** The point is to
  reuse the competitor's *layout* for *the user's* subject. Passing the source's
  title makes a clone of their video, not an adaptation of yours.
- **One contract.** Follow `reverse:contract` verbatim; the import validates it
  exactly like the app validates its own analyzer. Hand-written
  rules that drift from the contract are the failure mode - print the contract,
  do not recall it from memory.
- **Warnings are the correction path.** A `⚠` from `reverse:import`, the
  preset save or the generate plan means a STYLE or COMPOSITION sentence still
  mixes the background with an object; the sentence is kept for the objects and
  the brand cannot replace that background. Fix the JSON (Path B) before a paid
  render; for a saved STYLE sentence use `preset:edit --style-file`.
- After import, obtain the actual resolved prompt with the free dry-run:
  `thumbforge generate --preset <presetId> --topic "<topic>" --refs <paths> --quality <chosen-quality> --plan-out <abs.json>`.
  Read `concepts[0].resolvedPrompt` from that JSON, retaining its `refPaths`
  order and the chosen profile, style, expression, visible text and quality.
  Copy it into `--custom-prompt` only after preserving FACE_LOCK, safe-zone and
  composition; a raw custom prompt replaces the resolver entirely.
- **A clone still has to be a good thumbnail.** Sanity-check the adapted template
  against `../thumbforge/references/thumbnail-craft.md` (text-left/face-right,
  legible headline) and `../thumbforge/references/gotchas.md` (no text in the
  timestamp corner, non-ASCII text risk) - copying a competitor's layout doesn't
  exempt it from the universal rules.
- **Reverse presets still need real refs.** When generating from the saved preset,
  inspect candidate reference thumbnails before choosing faces/icons/screens. Do
  not trust a name if the preview shows the wrong crop or object.

## Errors

See `../thumbforge/references/troubleshooting.md`. `reverse:import` errors are
validation, not spend: read the reason, fix the JSON, re-run. `--json-out` and
the app analyzer belong to `/tf-reverse-auto`; its saved JSON avoids a second
analysis when parts are saved later: no second analysis.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają domyślnie **`thumbforge`** — cienki klient HTTP.
`pnpm cli <komenda>` wolno użyć tylko w dev-mode wykrytym wspólnym kontraktem po
manifeście `package.json` z `name === "thumbforge"` w cwd.

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `inventory`, `cost-estimate`, `edit`, `generate`, `reverse`, `reverse:contract`, `reverse:import`, `analyze-transcript`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)”.

Przy świeżym teście dev, gdy discovery wskazuje stary sidecar, orchestrator podaje
`THUMBFORGE_SERVER_URL=http://localhost:3000` przed komendą `thumbforge`; nie
przechodź wtedy na `pnpm cli`.
