---
name: thumbforge
description: >-
  Entry point and router for the thumbforge thumbnail CLI. Use when the user
  wants to drive thumbforge from chat, needs the command catalog, preset list,
  or a bootstrap check before a thumbnail task — generating, cloning, editing,
  or planning thumbnails. Routes to a task skill (see Routing).
argument-hint: "[what you want to do with thumbforge]"
allowed-tools: Bash, Read
---

# thumbforge (umbrella)

The user triggers, you operate. The installed `thumbforge` command is the default;
this skill is the operator's manual: how to drive it safely, pick defaults,
dry-run, and never burn a paid call without the user's explicit say-so. For a
concrete task, route to a task skill (see Routing). Use this skill directly for
bootstrap checks, the command catalog, or the shared paid-call protocol.

## Step 0 — Bootstrap thin-first

1. Always start with `thumbforge --help` (free). Before this handshake, do not
   inspect repo files, environment files, config, references, or machine paths.
2. If it fails, tell the user: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray → Zainstaluj CLI.” Do not guess a repo path.
3. After the handshake, dev mode is allowed only when this deterministic check
   succeeds in the current working directory:
   ```bash
   node -e 'const p=require(process.cwd()+"/package.json");process.exit(p.name==="thumbforge"?0:1)' 2>/dev/null
   ```
   Success means repo/dev commands may use `pnpm cli`; failure means stay on the
   thin `thumbforge` surface. A directory name or the presence of `.env.local`
   is not evidence of dev mode.

The authoritative flag reference is always `thumbforge <command> --help`
(generated from code, never drifts). Confirm flags there rather than trusting
any example in a skill.

Before naming a model or quality, run `thumbforge inventory` to see the thin
client's model catalog. Inventory alone does
not prove account access or edit support in an older app. For edit flags, run
`thumbforge edit --help`: that output is the thin client's flag contract. The
edit dry-run is the live capability check and refuses an older app before a
positive plan or POST. Documentation recommendation: Sunburst for precise
edits, Flare for fast daily iterations.

## Paid-call protocol (triple lock)

Paid commands (`generate`, `reverse`, `eval`, `retry`, `analyze-transcript`, `analyze-titles`,
`edit`) are dry-run by default. To actually spend money you need **all three**:
env `THUMBFORGE_ALLOW_PAID_CALLS=1` + flag `--confirm` + the dry-run-default being
overridden. The discipline that keeps this safe:

1. **The app owns keys.** The thin CLI inherits configured provider/analyzer keys
   from the running app. Never inspect or source secret/config files. In verified
   repo/dev mode, the direct CLI owns its separate dev configuration.
2. **Dry-run first.** Run the command WITHOUT `--confirm`, show the user the plan +
   estimated cost (`cost-estimate` for generate) + proponowany Slug odcinka, and wait.
3. **Consent is per-call, not per-session.** Only after the user says yes in this
   turn, run the paid command. Never re-issue a `--confirm` command without fresh
   consent — not on retry, not after an error, not after Ctrl-C.
4. **Keep `THUMBFORGE_ALLOW_PAID_CALLS=1` inline** on the one command line. Never
   `export` it or persist it — otherwise `--confirm` becomes the only remaining
   lock.
5. **Chained flows = separate consent.** reverse→generate and scenario→generate
   are multiple paid stages; each gets its own dry-run and its own approval.

Full details + examples: `references/paid-call-protocol.md`.

## Discovery gate + batch-first (universal)

These skills run on **any** account, so never assume which presets, styles, or refs
exist — discover them. Two rules, full detail in `references/discovery-contract.md`:

1. **Discover before you choose.** Before picking a resource on the user's behalf,
   list that dimension first: archetype → `thumbforge list-presets`; text/background/
   recipe style → `thumbforge list-styles`; expression → `thumbforge list-expressions`;
   refs → `thumbforge list-refs`; model →
   `thumbforge inventory` for all four at once. Every id
   you pass must have appeared in a list this session (built-in **and** the
   account's custom). Skip a dimension only when the user named it explicitly. The
   static catalogs are reasoning, not the id source.
   For refs, the list is only the index: if several candidates could fit, inspect
   their `_thumb.png` previews or a contact sheet before choosing.
2. **Batch, don't loop.** More than one concept → one `thumbforge generate
   --concepts-file <abs.json>` (one logical Run, one consent). The CLI may split
   the Run into review-sized sessions of ≤4 images; never loop single `generate`
   calls yourself (that spawns unrelated duplicate-looking sessions).

Image models and quality tiers come from `thumbforge inventory`, which shows the
client model catalog. Inventory is not proof of account access or support in an
older app. OpenAI `gpt-image-2.5-sunburst` and `gpt-image-2.5-flare` use `low`,
`medium`, `high`, `xhigh`, `max`, and `auto` when the target accepts them; `auto`
is an orientational max-output estimate, not a guaranteed cost ceiling.

**Model i jakość:** domyślnie model z Ustawień aplikacji. Bez `--model`
i `--provider` cienki klient bierze go z Ustawień, a dry-run drukuje
`model: <dostawca>/<model> (<jakość>, źródło: ustawienia aplikacji)`; dev CLI
drukuje `plan: <dostawca>/<model> @ <jakość>`. Na prośbę usera (np. „na Nano
Bananie”) weź inny model z katalogu `thumbforge inventory`, np.
`--model gemini-nano-banana-2.1` bez `--provider`: dostawcę CLI bierze z katalogu,
a dry-run pokazuje `źródło: flaga`. Jakość to jeden z tierów wybranego modelu
w katalogu. Drabinka `gemini-nano-banana-2.1`:
- `low` - 1K, myślenie minimal: najtańsze szybkie szkice.
- `medium` - 1K, myślenie medium: domyślna jakość, ustawienie zalecane przez Google.
- `high` - 1K, myślenie high: lepsze trzymanie się promptu.
- `xhigh` - 2K, myślenie high: ostrzejszy obraz i RAW 2K.
- `max` - 4K, myślenie high: RAW 4K, najdroższy tier.

## Slug odcinka i nazwy plików

**Slug odcinka:** przed dry-runem zaproponuj 2-4 słowa z roboczego tytułu odcinka
(ASCII, małe litery, myślniki, max 30 znaków, np. `codex-sdk`) i pokaż slug
w podsumowaniu dry-runu przed płatnym wywołaniem, żeby user mógł go zmienić
jednym słowem. Katalog to `$HOME/Downloads/<slug>`: każda komenda odkładająca PNG
dostaje `--out "$HOME/Downloads/<slug>" --out-name <slug>`, a
kolejne rundy odcinka używają tego samego sluga i katalogu (numeracja idzie
dalej, bez podkatalogów rund).

1. Komendy odkładające PNG: `generate`, `retry-image`, `edit`, `resume` i `grid`
   w cienkim kliencie; w repo/dev `generate`, `retry`, `edit` i `grid`.
2. Kopie lądują płasko jako `<slug>-1.png`, `<slug>-2.png`; kolejne wywołanie
   numeruje od największego numeru w katalogu + 1 i nigdy nie nadpisuje pliku.
   Grid rundy to `<slug>-grid-<n>.png` z osobnym licznikiem.
3. CLI normalizuje slug (polskie znaki na ASCII, małe litery, myślniki, max 30
   znaków); bez `--out-name` prefiks to 3 pierwsze słowa tematu. `--out-name` bez
   `--out` daje jedno zdanie ostrzeżenia i żadnej kopii (`--out` to polityka
   eksportu, nie zamek kosztu, ADR 0005).
4. Płatne wywołanie wypisuje przy każdym obrazie linię
   `<plik> -> koncept <k>, <preset>, wariant <w>, sesja <id>`: pokaż ją userowi
   jako tabelę plik -> koncept, preset, wariant, sesja.

## UX Rules

1. Reply in Polish (full diacritics ą/ć/ę/ł/ń/ó/ś/ź/ż), no emoji. Technical args
   (`--preset hero-pointing`) stay as-is.
2. No raw JSON dumps in chat. Deliver exported output **paths**, the Run/session
   id needed for follow-up commands, and a one-line summary (preset, model, cost).
3. Pick sane defaults; ask one thing at a time, only when genuinely missing.
4. Don't narrate "running cost-estimate", "calling the model". Show the result.

## Command catalog

Authoritative flags: `thumbforge <cmd> --help`. Map: `references/cli-reference.md`.

| Command | Paid? | Purpose |
|---|---|---|
| `list-models` | no | image models + pricing |
| `list-presets` | no | built-in + custom presets |
| `list-styles` | no | text / background / recipe styles (built-in + custom) |
| `list-expressions` | no | built-in + custom mina/poza bricks and preset defaults |
| `list-refs` | no | reference images on disk (`--category`) |
| `inventory` | no | one-shot overview: presets + styles + models + refs |
| `list-sessions` | no | past generation sessions |
| `cost-estimate` | no | estimate batch cost (no provider call) |
| `grid <sessionId>` / `grid --batch <batchId>` | no | compose a session grid or whole Grid Runu → **tf-generate** |
| `generate` | **yes** | generate thumbnails → **tf-generate** |
| `resume <sessionId>` | no | dokończ pobieranie sesji po timeoucie klienta (thin) |
| `retry-image` | **yes** | ponów jeden nieudany wariant sesji (thin) |
| `fetch-media <mediaPath>` | no | pobierz jeden plik mediów (thin; przy kopii `--no-overwrite`) |
| `reverse` | **yes** | app analyzer, explicit only → **tf-reverse-auto** |
| `reverse:contract` / `reverse:import <file>` | no | analysis contract for a conversation model + free import / selective save of its JSON → **tf-reverse** |
| `analyze-transcript` | **yes** | infer slots from a scenario → **tf-scenario** |
| `analyze-titles` | **yes** | propose thumbnail concepts from title candidates → **tf-titles** |
| `brand:analyze` | **yes** | derive a profile design system from thumbnails → **tf-brand** |
| `brand:import` | no | import a reviewed design.md into a profile → **tf-brand** |
| `profile:list` / `profile:current` | no | discover the target profile → **tf-brand** |
| `eval` | **yes** | golden-set eval (out of core scope) |
| `retry` | **yes** | re-run a session (out of core scope) |
| `edit` | **yes** | instruction-edit an image → **tf-edit** |
| `config-set` | no | store an encrypted key (the user does setup) |
| `upload-ref` | no | add a reference image → **tf-assets** |
| `refs:rethumb` | no | rebuild reference `_thumb.png` previews → **tf-assets** |
| `refs:contact-sheet` | no | labeled visual ref sheet → **tf-assets** |
| `preset:slots` | no | a preset's slots → **tf-preset** |
| `preset:show` | no | a preset's 6 spec blocks (`--block` for raw) → **tf-preset** |
| `preset:create` | no | fork a preset → **tf-preset** |
| `preset:edit` | no | edit a custom preset → **tf-preset** |
| `preset:preview` | no | replace a custom preset grid cover → **tf-preset** |
| `preset:delete` | no | soft-delete a custom preset → **tf-preset** |
| `style:create` | no | author a text/background style → **tf-preset** |
| `style:edit` | no | edit a custom style → **tf-preset** |
| `style:delete` | no | soft-delete a custom style → **tf-preset** |
| `expression:create` | no | author a custom expression (mina/poza) → **tf-preset** |
| `expression:edit` | no | edit a custom expression → **tf-preset** |
| `expression:delete` | no | soft-delete a custom expression → **tf-preset** |

## Routing

- Generate thumbnails from a topic/preset → **`/tf-generate`**.
- Clone/adapt a visible competitor thumbnail → **`/tf-reverse`**. Explicitly request the app analyzer → **`/tf-reverse-auto`**.
- Turn one of the user's YouTube videos or local media files into a transcript →
  suggest **`/tf-transcript`**; it is user-invoked, so never start it automatically.
- Turn a video scenario/transcript into concepts → **`/tf-scenario`**.
- Compare 1–3 title candidates and turn the winner into concepts → **`/tf-titles`**.
- Derive or import a channel/series design system → **`/tf-brand`**.
- Brainstorm original thumbnail concepts / Swobodny prompt → **`/tf-brainstorm`**.
- List or add reference images — face, icons, inspirations → **`/tf-assets`** (free).
- Author or edit a custom preset (fork an archetype, edit a block), a custom
  text/background style, or a custom expression (mina/poza) → **`/tf-preset`**
  (free). Also where a reverse-template preset gets refined before generation.
- Editing an already-generated image by instruction (`edit`) → **`/tf-edit`**.
- Re-running a past session as-is (`retry`) or a golden-set `eval` — these are
  paid but out of the core task-skill set. Handle them only in verified repo/dev
  mode, with the paid-call protocol and the same locks.

**Not for** the actual generation once intent is clear (route above), the Next.js
app, the web UI, or non-thumbforge projects.

## Errors

Common failures and fixes: `references/troubleshooting.md`. Quick hits:
`command not found` → you used a stale name (`list`/`cost` don't exist; use
`list-presets`/`cost-estimate`). `429` → Google free-tier wall (use the default
Anthropic analyzer). Missing provider/analyzer key → configure it in the running
app's Settings; only verified repo/dev mode uses separate dev configuration.

## Reference docs

Load on demand:

- `references/cli-reference.md` — command → purpose → "flags via `--help`".
- `references/discovery-contract.md` — discover-before-propose + batch-first + concepts-file format.
- `references/paid-call-protocol.md` — env + triple lock + dry-run→confirm examples.
- `references/presets-catalog.md` — the built-in archetypes + slots.
- `references/thumbnail-craft.md` — universal design craft: layout, text, archetype→preset map, hooks, series continuity. Read before picking a preset/text.
- `references/gotchas.md` — universal pitfalls that tank a thumbnail (read with craft).
- `references/troubleshooting.md` — common errors and fixes.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają domyślnie **`thumbforge`** — cienki klient HTTP.
`pnpm cli <komenda>` wolno użyć tylko w dev-mode wykrytym wspólnym kontraktem po
manifeście `package.json` z `name === "thumbforge"` w cwd.

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `list-expressions`, `inventory`, `profile:list`, `profile:current`, `brand:analyze`, `brand:import`, `cost-estimate`, `edit`, `generate`, `resume`, `retry-image`, `fetch-media`, `reverse`, `reverse:contract`, `reverse:import`, `analyze-transcript`, `analyze-titles`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `expression:create`, `expression:edit`, `expression:delete`, `upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
