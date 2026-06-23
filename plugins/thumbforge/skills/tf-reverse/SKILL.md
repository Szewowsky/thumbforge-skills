---
name: tf-reverse
description: >-
  Clone or adapt a competitor's YouTube thumbnail into Robert's own style with
  the thumbforge reverse analyzer. Use when Robert points at someone else's
  thumbnail or video and wants the same template for his topic — "/tf-reverse",
  "sklonuj ten thumbnail", "zrób preset z tego filmu", "podrób tę miniaturę",
  "zaadaptuj ten układ do mojego tematu", typically with a YouTube URL or an
  image. You operate the CLI: dry-run the analysis, show the plan, and only run
  the paid vision analysis after Robert's explicit per-call consent; the analyzed
  template is saved as a reusable custom preset. NOT for generating from a plain
  topic with an existing preset (use tf-generate), and NOT for inferring a
  thumbnail from a video scenario/transcript (use tf-scenario). Prefer this skill
  whenever the source is a specific existing thumbnail Robert wants to reproduce.
argument-hint: "<youtube-url-or-image> [--context <my topic>]"
allowed-tools: Bash
---

# tf-reverse

A competitor thumbnail (URL or image) → vision analysis → a reusable custom
preset → optionally a generation on it. Via `thumbforge reverse`. The user triggers;
you operate.

## Step 0 — Bootstrap (paid skill)

```bash
cd "/Users/robert/Windsurf Projekty/thumbforge"
thumbforge --help            # CLI reachable? (free)
```

Triple lock for the real run: env `THUMBFORGE_ALLOW_PAID_CALLS=1` (inline, never
`export`) + `--confirm` + dry-run-first. Consent is per-call. `THUMBFORGE_SECRET`
**auto-loads** from `.env.local` (allowlist — ADR 0005); you no longer source it.
Full rules: `../thumbforge/references/paid-call-protocol.md`.

## Workflow

1. **Dry-run (free, no vision call).** Shows the plan without spending:
   ```bash
   thumbforge reverse --url "<youtube-url>" --context "<your video's topic>"
   ```
   For a local image use `--file <path>` instead of `--url`. The dry-run prints
   selected-model key warnings and the analyzer availability list (`✓` key OK,
   `⚠` missing key, `⚠` free-tier risk) before any paid call. Default to
   `claude-opus-4-8-thinking`; use `--model <id>` only when the user asks or the
   availability list makes a better fallback obvious.
2. **Discover analyzers + account inventory (free, optional but useful).**
   ```bash
   thumbforge inventory
   ```
   Inventory repeats analyzer availability next to presets/styles/models/refs, so
   you can propose a concrete analyzer without guessing which keys decrypt.
3. **Paid analysis — ONE invocation (only after consent).** `--apply` saves the
   analyzed template as a custom preset in the same call and prints the matching
   `generate` command / `presetId`. There is no separate "apply later" step — pass
   the source, context, and `--apply` together:
   ```bash
   THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge reverse \
     --url "<youtube-url>" \
     --context "<your video's topic>" \
     --model claude-opus-4-8-thinking \
     --apply \
     --confirm
   ```
4. **Deliver.** Report the new `presetId` + a one-line summary (template, icons
   adapted). No JSON dump.
5. **Optional chain → refine or generate.** The `presetId` from `reverse --apply`
   is a custom preset (a Reverse-preset). Two follow-ups:
   - **Refine it first (free) → `/tf-preset`** with `preset:edit <presetId>` —
     rename, swap the text/background style, or tweak an editable block (start from
     `preset:show <presetId> --block <name>`). No spend.
   - **Generate on it (paid) → `/tf-generate`** with `--preset <presetId>` (the
     preset id comes from this `reverse --apply` run, so that dimension is already
     chosen). The discovery gate still applies to the OTHER dimensions of the
     generate stage — `list-refs` for the face/icons that fill the new preset's
     slots, plus visual `_thumb.png` inspection when several refs could fit;
     `list-styles` if overriding text/background (see
     `../thumbforge/references/discovery-contract.md`). That is a **separate paid
     stage** — its own dry-run and its own consent. One approval here does not
     authorize the generation. That stage **auto-composes a preview grid** of the
     variants and opens it (tf-generate step 6), so the clone → your-variants →
     side-by-side-grid loop is already covered there — no separate grid step here.

## Flags (confirm with `thumbforge reverse --help`)

| Flag | Use |
|---|---|
| `--url <url>` | source thumbnail / video URL |
| `--file <path>` | local source image (instead of `--url`) |
| `--context <text>` | **topic of the user's (your) video** — see P0 below |
| `--model <id>` | analyzer override (default `claude-opus-4-8-thinking`; dry-run shows availability) |
| `--apply` | save the analyzed template as a custom preset (do it in the paid call) |
| `--confirm` | spend money (also needs the env) |

`reverse` has no `--out` — it produces a preset, not an image.

## Load-bearing rules

- **P0 — `--context` is the user's topic, never the source title.** The point is to
  reuse the competitor's *layout* for *the user's* subject. Passing the source's
  title makes a clone of their video, not an adaptation of yours.
- **Free-tier wall.** `gemini-2.5-flash` is cheaper but the Google key is
  free-tier (~20 req/min → 429). Dry-run/inventory mark it with `⚠` even when
  the key decrypts. The default Anthropic analyzer has no wall — prefer it unless
  the user asks for Flash.
- **Key preflight before spend.** If dry-run says `⚠ brak klucza` or
  `THUMBFORGE_SECRET`, fix that before asking for paid consent. Missing key and
  wrong secret are distinct failures; don't collapse them into "add a key".
- The analyzer + resolver own the template/icon logic; don't hand-edit prompts.
- **A clone still has to be a good thumbnail.** Sanity-check the adapted template
  against `../thumbforge/references/thumbnail-craft.md` (text-left/face-right,
  legible headline) and `../thumbforge/references/gotchas.md` (no text in the
  timestamp corner, non-ASCII text risk) — copying a competitor's layout doesn't
  exempt it from the universal rules.
- **Reverse presets still need real refs.** When generating from the saved preset,
  inspect candidate reference thumbnails before choosing faces/icons/screens. Do
  not trust a name if the preview shows the wrong crop or object.

## Errors

See `../thumbforge/references/troubleshooting.md`. `429` → quota/free-tier wall,
switch to the default analyzer or wait for quota. A truncated/`no valid JSON`
analysis is a known reasoning-model failure mode fixed by raising the shared
reasoning/output token budget (`max_tokens` for Anthropic, `max_output_tokens` +
`reasoning` for OpenAI); if it recurs, report the echoed `status`,
`incomplete_details.reason`, and `response head` rather than retrying blindly
(each retry is paid).

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają **`thumbforge`** — cienki klient HTTP. U testera z samą
aplikacją (.dmg, bez repo) `thumbforge` jest wbudowany w apkę (instalacja: ikona w
tray → „Zainstaluj CLI"). W repozytorium (dev) `thumbforge` to launcher do
bezpośredniego CLI — raz wykonaj `pnpm link --global` (albo używaj równoważnego
`pnpm cli <komenda>`).

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `inventory`, `cost-estimate`, `generate`, `reverse`, `analyze-transcript`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `upload-ref`, `grid`.
Komendy `edit`, `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
