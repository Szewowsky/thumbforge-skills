---
name: tf-reverse-auto
description: >-
  Use when a user explicitly invokes the auto reverse command to price and run
  the Thumbforge app analyzer. It never triggers from ordinary thumbnail requests.
disable-model-invocation: true
argument-hint: "<youtube-url-or-image> [--context <my topic>]"
allowed-tools: Bash, Read
---

# tf-reverse-auto

Use only after an explicit user invocation: `$tf-reverse-auto` in Codex or
`/tf-reverse-auto` in Claude Code (with the plugin namespace when required).
This is the paid app-analyzer route. Natural requests for a similar thumbnail belong to
`tf-reverse`, which uses the conversation model and free import.

## Not for

- Natural reverse requests → `tf-reverse`; a user may still explicitly invoke this skill for an attached image.
- Generating a thumbnail → `tf-generate`.

## Step 0 - Bootstrap thin-first

Run `thumbforge --help` (free). If it fails: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray → Zainstaluj CLI.” Then follow the shared [Bootstrap thin-first contract](../thumbforge/SKILL.md#step-0--bootstrap-thin-first).

## Plan, then consent

1. Verify the exact surface before proposing it:
   ```bash
   thumbforge reverse --help
   thumbforge inventory
   ```
2. Dry-run the selected source and show the analyzer model, estimate and key
   availability. Default model for this workflow is `gpt-5.6-terra`.
   ```bash
   thumbforge reverse --url "<url>" --context "<topic>" --model gpt-5.6-terra
   ```
3. State separately that this is the app analyzer cost; conversation tokens and
   a later image generation are separate costs. Do not call the model yet.
4. Only after fresh consent run exactly the same command with the triple lock:
   `THUMBFORGE_ALLOW_PAID_CALLS=1`, `--confirm`, and one explicit command. Add
   `--json-out <abs>` when parts may be saved later, so no second analysis is
   needed. Use `--apply` only for a full preset.
5. Save selected background, text style, expression or hidden draft with the
   free `thumbforge reverse:import <file>` path. Its generated prompt base is
   then opened through the full resolved planner; preserve reference order. The
   source remains analysis-only: never add it to the reference library. Choose
   face, icon and screen refs only in the later generation stage.

Full lock rules: `../thumbforge/references/paid-call-protocol.md`.

## Cienki klient (tester)

Use `thumbforge` after the handshake. `reverse`, `reverse:contract` and
`reverse:import` are thin-supported; `pnpm cli` is repo/dev-only.
