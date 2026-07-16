---
name: tf-titles
description: >-
  Analyzes 1–3 candidate video titles with the thumbforge CLI and turns the
  result into thumbnail concept handoffs. Use when the user asks which title
  should drive a thumbnail or wants title-to-thumbnail proposals —
  "/tf-titles", "porównaj tytuły", "z tych tytułów zaproponuj miniaturę".
allowed-tools: Bash, Read
---

# tf-titles

Title candidates → paid analysis → user choice → generation or further
divergence. The analysis never generates an image. Treat a later generation as
a separate paid stage with its own dry-run and consent.

## Not for

- One settled title/topic that is ready for a preset run → `tf-generate`.
- Open-ended visual ideation without title comparison → `tf-brainstorm`.
- Concepts derived from a script or transcript → `tf-scenario`.
- Adapting a competitor thumbnail → `tf-reverse`.

## Step 0 — Bootstrap thin-first

Run `thumbforge --help` (free). If it fails: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray → Zainstaluj CLI.”
Then follow the shared [Bootstrap thin-first contract](../thumbforge/SKILL.md#step-0--bootstrap-thin-first); do not inspect repo files or guess a machine path before the handshake.

Read and apply `../thumbforge/references/paid-call-protocol.md`. The real
analysis requires all three locks: dry-run first, fresh user consent, then inline
`THUMBFORGE_ALLOW_PAID_CALLS=1` plus `--confirm`. Never inspect or source
secret/config files, and never repeat a confirmed call without fresh consent.

## Workflow

1. **Collect the input.** Accept 1–3 title candidates and optional video context.
   Use repeated `--title`; when the user points to a JSON array or one-title-per-line
   file, use `--titles-file <absolute-path>`. Ask only for genuinely missing
   context; do not invent a fourth candidate.
2. **Run the free dry-run.** Keep the chosen model stable between dry-run and the
   real call.
   ```bash
   thumbforge analyze-titles \
     --title "<candidate 1>" \
     --title "<candidate 2>" \
     --context "<optional context>"
   ```
   Show the normalized titles, available ref categories, analyzer model and
   estimated cost. The absence of `--confirm` is the first lock.
3. **Request consent for this analysis.** State the exact estimated cost and
   command scope. Existing consent for image generation or another analyzer call
   does not carry over.
4. **Run the paid analysis once, only after consent.** Reuse the exact dry-run
   arguments and add both remaining locks:
   ```bash
   THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge analyze-titles \
     --title "<candidate 1>" \
     --title "<candidate 2>" \
     --context "<optional context>" \
     --confirm
   ```
5. **Present every proposal for selection.** For each proposal show the
   recommended title, preset, topic, visible text, directive, slot values, ref
   hints and rationale. Preserve returned ids and fields; do not silently rewrite
   analyzer output. Ask the user which proposal to continue with.
6. **Handoff only after the user chooses.** If the proposal is ready, save its
   returned `szkic concepts-file` as an absolute JSON path and hand it to
   `tf-generate`; start with a free `thumbforge generate --concepts-file <path>`
   dry-run. If the user wants broader visual exploration, hand the selected title,
   context and proposal rationale to `tf-brainstorm`. Do not generate or brainstorm
   all proposals automatically.

## Load-bearing rules

- `analyze-titles` accepts 1–3 candidates; one `--title` flag per candidate keeps
  shell quoting explicit.
- Analysis consent and generation consent are separate paid decisions.
- The returned preset/ref hints are proposals, not proof that a specific ref id
  exists. The receiving skill must run its normal discovery gates.
- Keep chat output readable: summarize fields in a numbered list instead of
  dumping transport JSON.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają domyślnie **`thumbforge`** — cienki klient HTTP.
`pnpm cli <komenda>` wolno użyć tylko w dev-mode wykrytym wspólnym kontraktem po
manifeście `package.json` z `name === "thumbforge"` w cwd.

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `list-expressions`, `inventory`, `cost-estimate`, `edit`, `generate`, `reverse`, `analyze-transcript`, `analyze-titles`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)”.
