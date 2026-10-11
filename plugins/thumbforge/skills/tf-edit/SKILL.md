---
name: tf-edit
description: >-
  Instruction-edit an already generated thumbforge image from chat. Use when the
  user points at an existing session/image and asks to fix it with text —
  "/tf-edit", "popraw tę miniaturę", "zmień minę", "przyciemnij tło", or similar.
  Instruction-only in v1: no mask or region painting.
disable-model-invocation: true
argument-hint: "--session <id> --image <imageId> --instruction <text>"
allowed-tools: Bash, Read
---

# tf-edit

Instruction-only correction of an existing image. In product terms this is the
thumbforge edit flow. On the packaged app it runs through `thumbforge edit`
(thin client → running app → new version in app userData); in repo/dev,
the local launcher reaches the same edit command. Tylko jawne `/tf-edit` usera
uruchamia ten flow; agent z własnej inicjatywy regeneruje obraz ze świeżym
promptem przepisanym według feedbacku. Po wywołaniu usera flow jest zawsze:
resolve target → craft identity-safe instruction →
dry-run with cost → get consent → paid edit → inspect result → optionally
iterate or set final in the UI.

## Not for

- A new thumbnail from a topic → `tf-generate`.
- Cloning a competitor's thumbnail → `tf-reverse`.
- Planning from a scenario/transcript → `tf-scenario`.
- Mask/region painting — out of scope in this instruction-only v1.

## Step 0 — Bootstrap thin-first

Run `thumbforge --help` (free). If it fails: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray → Zainstaluj CLI.”
Then follow the shared [Bootstrap thin-first contract](../thumbforge/SKILL.md#step-0--bootstrap-thin-first); do not inspect repo files or guess a machine path before the handshake.

`thumbforge edit --help` is the thin client's flag contract. Run it to discover
the flags this client accepts, then run `thumbforge inventory` to see the
client model catalog. Inventory alone does
not prove account access or edit support in an older app. The edit dry-run is
the live capability check: it refuses an older app before showing a positive
plan or sending a POST. Documentation recommendation: Sunburst for precise
edits, Flare for fast daily iterations.

Triple lock for the real run: env `THUMBFORGE_ALLOW_PAID_CALLS=1` (inline, never
`export`) + `--confirm` + dry-run-first. Consent is per-call; never re-run a paid
edit without fresh approval. The running app owns the configured provider key;
do not inspect or source secret/config files. Full rules:
`../thumbforge/references/paid-call-protocol.md`.

## Workflow

1. **Resolve the target (free).** If the user gave a session id and image id, use
   them. If not, use the app's History view and ask one concise clarification
   before spending. `pnpm cli list-sessions` is available only in verified
   repo/dev mode.
   The target must be a specific session + image version. Do not guess from a
   vague "the last one" if several recent sessions could match.
2. **Reattach face/reference context when needed (free).** If the edit touches a
   person, list candidate refs and choose the same face/role when obvious:
   ```bash
   thumbforge list-refs --category character-primary
   thumbforge list-refs --category character-secondary
   ```
   Pass selected refs through `--refs <path1,path2>`. Preserve the original
   ref order for two-person images: host/primary first, guest/persona second.
   This keeps the FACE_LOCK / FACE_LOCK_DUO positional contract intact.
3. **Craft the instruction.** Keep the user's requested change first, then append
   guardrails when relevant:
   - preserve facial identity exactly from the attached face ref / FACE_LOCK;
   - preserve existing composition and do not swap subjects;
   - keep all text inside the central 85% safe-zone with enough edge padding;
   - do not crop headline letters or cover the timestamp corner.
   Read `references/gotchas.md` when the edit involves text,
   cropping, faces, or the timestamp corner.
4. **Dry-run (free).** Run without `--confirm` and show the plan + cost:
   ```bash
   thumbforge edit \
     --session <sessionId> \
     --image <imageId> \
     --instruction "<instruction with FACE_LOCK + central 85% safe-zone guardrails>" \
     [--provider <provider>] [--model <model>] [--quality <tier>] \
     [--refs <ref1,ref2>] \
     [--guide <annotation-doc.json>]
   ```
   Dry-run must print `edit plan`, `koszt`, and the
   `THUMBFORGE_ALLOW_PAID_CALLS=1` reminder.
   The default target is the selected image's saved target, with the session as
   the fallback for legacy NULL metadata. An override applies to this edit only;
   the new version records it and the session remains unchanged.
   **Model edycji:** bez `--model` edycja idzie zapisanym celem obrazu (model
   i jakość źródła; wycofane ID przechodzą na następcę). Override tylko na prośbę
   usera i tylko na cel, który przyjmie dry-run: model obrazu źródłowego albo
   Sunburst lub Flare. Obraz z `gemini-nano-banana-2.1` edytujesz tym modelem,
   z jakością z jego drabinki `low`..`max`; obrazu z OpenAI nie przełączysz na 2.1.
   **Slug odcinka:** przed dry-runem zaproponuj 2-4 słowa z roboczego tytułu odcinka
   (ASCII, małe litery, myślniki, max 30 znaków, np. `codex-sdk`) i pokaż slug
   w podsumowaniu dry-runu przed płatnym wywołaniem, żeby user mógł go zmienić
   jednym słowem. Katalog to `$HOME/Downloads/<slug>`: każda komenda odkładająca PNG
   dostaje `--out "$HOME/Downloads/<slug>" --out-name <slug>`, a
   kolejne rundy odcinka używają tego samego sluga i katalogu (numeracja idzie
   dalej, bez podkatalogów rund). Edycja obrazu z odcinka bierze slug jego
   generacji, więc kopia ląduje jako kolejny `<slug>-<n>.png`.
   If it cannot resolve the session or cost, stop and fix that before asking for
   consent.
5. **Paid edit (only after consent).** The thin client uses the editor guide-ref
   instruction flow, so the real path needs an annotation-doc JSON (`--guide`)
   plus an absolute export directory (`--out`: polityka eksportu, nie zamek
   kosztu, ADR 0005). No binary mask is used here.
   ```bash
   THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge edit \
     --session <sessionId> \
     --image <imageId> \
     --instruction "<final instruction>" \
     [--provider <provider>] [--model <model>] [--quality <tier>] \
     [--refs <ref1,ref2>] \
     --guide <annotation-doc.json> \
     --out "$HOME/Downloads/<slug>" --out-name <slug> \
     --confirm
   ```
6. **Verify and deliver.** Open the output/session in the UI. If the result
   preserves identity/text and is the desired version, tell the user the session,
   image/version, and next action. If not, explain the failure mode and dry-run a
   revised instruction before asking for another paid consent.

## Load-bearing rules

- Do not use this skill for mask or region painting. That is a future workflow.
- Do not edit preset slot order, ref sorting, text-style fragments, finalizer
  policy, or storage paths while operating this skill.
- Do not hand-wave identity. For face edits, include FACE_LOCK language and
  reattach the relevant face ref with `--refs` when available.
- Text edits must restate the safe-zone: central 85%, edge padding, auto-scale /
  shrink if needed.
- Suspicious outputs should not be auto-promoted. Use the session UI to inspect
  and set final only after the user accepts the result.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają domyślnie **`thumbforge`** — cienki klient HTTP.
`pnpm cli <komenda>` wolno użyć tylko w dev-mode wykrytym wspólnym kontraktem po
manifeście `package.json` z `name === "thumbforge"` w cwd.

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `inventory`, `cost-estimate`, `edit`, `generate`, `reverse`, `analyze-transcript`, `preset:create`,
`preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`,
`upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `retry`, `eval`, `list-models`, `refs:contact-sheet`,
`refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete` są
**repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
