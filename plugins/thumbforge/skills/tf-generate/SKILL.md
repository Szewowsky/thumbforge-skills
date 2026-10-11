---
name: tf-generate
description: >-
  Generate YouTube thumbnail candidates with the thumbforge CLI from a topic and
  a preset. Use when the user wants thumbnail images for a video idea —
  "/tf-generate", "zrób miniaturę o…", "wygeneruj thumbnail", or gives a topic
  plus optional reference images and wants candidates.
argument-hint: "[topic] [--preset <id>] [--refs <paths>] [--variants N]"
allowed-tools: Bash, Read
---

# tf-generate

Topic + preset + references → 1..N thumbnails, via `thumbforge generate`. The user
triggers; you operate. The flow is always: discover inputs → pick defaults →
estimate cost → dry-run → get consent → paid run → preview grid → deliver paths.

## Not for

- Cloning/adapting a competitor's thumbnail from a URL or image → `tf-reverse`.
- A thumbnail from a video scenario/transcript → `tf-scenario`.
- Editing an already-generated image by instruction → `tf-edit`.
- Inventing an original concept / freeform prompt → `tf-brainstorm`.
- Comparing title candidates before choosing the generation concept → `tf-titles`.

## Step 0 — Bootstrap thin-first

Run `thumbforge --help` (free). If it fails: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray → Zainstaluj CLI.”
Then follow the shared [Bootstrap thin-first contract](../thumbforge/SKILL.md#step-0--bootstrap-thin-first); do not inspect repo files or guess a machine path before the handshake.

Triple lock for the real run: env `THUMBFORGE_ALLOW_PAID_CALLS=1` (inline, never
`export`) + `--confirm` + dry-run-first. Consent is per-call: never re-run a
`--confirm` command without fresh approval. The running app owns the configured
provider key; do not inspect or source secret/config files. Full rules:
`../thumbforge/references/paid-call-protocol.md`.

## Workflow

1. **Discover before you choose (free).** Discover each dimension you are about to
   pick on the user's behalf — skip only the dimensions the user gave explicitly
   (a named `--preset`, a named style, explicit ref paths). The ids you pass MUST
   have appeared in these lists this session (the CLI does not reject an unknown
   preset — it silently falls back to a generic prompt, so the gate holds here):
   ```bash
   thumbforge list-presets                              # archetype (built-in + custom)
   thumbforge list-styles                               # text/background/recipe ids
   thumbforge list-expressions                          # built-in + custom mina/poza ids
   thumbforge list-refs --category character-primary    # the host's face
   thumbforge list-refs --category character-secondary  # guest/persona (collab-duo / host-plus-persona)
   thumbforge list-refs --category icon
   ```
   `list-refs` prints `/references/<category>/<id>.png` paths — pass those to
   `--refs`. Two-subject presets need one `character-primary` (host, first) + one
   `character-secondary` (guest/persona, second). Full rule (built-in vs custom, how
   to consume the output): `../thumbforge/references/discovery-contract.md`.
   When multiple refs in a category could fit, use `thumbforge list-refs` as the
   thin-client index, then inspect the relevant `_thumb.png` previews before
   picking. In repo/dev only, you may also run
   `pnpm cli refs:contact-sheet --category <category> --out <dir>`. Do not choose a
   face/icon/screen solely because the id or display name sounds right.
   Jeśli temat, headline albo prompt wymienia markę lub logo, `list-refs
   --category icon` jest obowiązkowe. Gdy pasujący ref istnieje, podepnij go do
   slotu icon/ref; gdy nie istnieje, powiedz to userowi przed opisaniem marki
   słowami.
   **Bramka discovery:** before you build any template, verify aloud that you have
   (a) discovered live preset/style/ref ids, (b) read and applied
   `../thumbforge/references/thumbnail-craft.md`, and (c) read and applied
   `../thumbforge/references/gotchas.md`. PRZED budową template
   przeczytaj+zastosuj `../thumbforge/references/thumbnail-craft.md` +
   `../thumbforge/references/gotchas.md`; if you cannot name the layout/text
   choice those docs imply, stay in discovery.
   **Profil i dziedziczenie:** bez `--profile` cienki klient używa aktywnego
   profilu aplikacji; gdy user wskazał id, przekaż je jawnie przez `--profile`.
   Powiedz przed planem: `Dziedziczę z profilu <id lub aktywny>: design system,
   scalar overrides oraz lekcje`. Po dry-runie nazwij konkretne cue widoczne w
   resolved prompt: paletę/typografię/tło/reguły oraz lekcje. Nadpisania jednego
   runu rób flagami `--text-style`, `--text-color`, `--background-style` i
   `--glow-color`; inny profil wybieraj przez `--profile`, nie przez zmianę
   zapisanych ustawień.
2. **Pick defaults.** Choose a preset that fits the topic (see
   `../thumbforge/references/presets-catalog.md`) and explain the design reason in
   craft terms: text-left/face-right or justified exception, one clear headline,
   no important element in the timestamp corner, and no clutter beyond the Rule of
   3 unless the preset explicitly needs it. Pick `--text-style` (and any background
   / recipe direction) from the `list-styles` output of step 1, not from memory —
   that is how this account's custom styles get used.
   **Headline gate:** jeden koncept ma jeden headline. Dodatkowe linie wolno
   dodać tylko wtedy, gdy odkryty styl tekstu definiuje je jako jeden układ
   (np. sandwich lub badge), nigdy jako drugi komunikat.
   **Ekspresja (mina/poza):** default = the preset's own mina (GUI „Domyślna") —
   omit `--expression` unless the user asks for a mood. Override with a built-in
   brick id from `list-expressions` (e.g. `skeptical`, `thinking-hand-on-chin`) or
   a `custom-expression-*` id you created/saw this session. A brick = face
   fragment (mina) + optional pose fragment (poza); the pose applies only on
   presets that opt in (`allowsExpressionPose`) — elsewhere only the mina lands.
   **Model i jakość:** domyślnie model z Ustawień aplikacji. Bez `--model`
   i `--provider` cienki klient bierze go z Ustawień, a dry-run drukuje
   `model: <dostawca>/<model> (<jakość>, źródło: ustawienia aplikacji)`; dev CLI
   drukuje `plan: <dostawca>/<model> @ <jakość>`. Na prośbę usera (np. „na Nano
   Bananie”) weź inny model z katalogu `thumbforge inventory`, np.
   `--model gemini-nano-banana-2.1` bez `--provider`: dostawcę CLI bierze z katalogu,
   a dry-run pokazuje `źródło: flaga`. Inventory to katalog modeli klienta, nie
   dowód dostępu konta. Jakość to jeden z tierów wybranego modelu w katalogu.
   Drabinka `gemini-nano-banana-2.1`:
   - `low` - 1K, myślenie minimal: najtańsze szybkie szkice.
   - `medium` - 1K, myślenie medium: domyślna jakość, ustawienie zalecane przez Google.
   - `high` - 1K, myślenie high: lepsze trzymanie się promptu.
   - `xhigh` - 2K, myślenie high: ostrzejszy obraz i RAW 2K.
   - `max` - 4K, myślenie high: RAW 4K, najdroższy tier.
   When the catalog lists them, `gpt-image-2.5-sunburst` and
   `gpt-image-2.5-flare` are explicit choices with `low`, `medium`, `high`,
   `xhigh`, `max`, and `auto`. A beta54 app may not list Flare, so do not
   promise or pass it there.
   **Quality gate:** jeśli user podał już model i jakość, zachowaj je bez ponownego
   pytania. W innym przypadku zanim wycenisz albo zbudujesz dry-run, zapytaj o jakość zgodną
   z katalogiem wybranego modelu. Dla GPT Image 2.5 dostępne są `low`, `medium`,
   `high`, `xhigh`, `max`, `auto`; `auto` ma wyłącznie orientacyjny max-output
   estimate i nie jest gwarantowanym limitem. Rekomenduj jawny `--quality`;
   CLI nie wybiera jakości po cichu.
   Dla Image 2 zachowaj prezentację: `a) medium - testy/porównania (rekomendowane),
   b) low - odradzane: niemiarodajne, c) high - finał`.
   **ILE OBRAZÓW — mapowanie liczby (load-bearing):** >1 koncept/wariant ⇒ ZAWSZE jedna batch-sesja, nigdy pętla runów.
   User chce N kandydatów
   JEDNEGO konceptu („zrób 4 miniatury", „batch 4 sztuk") ⇒ `--variants N` w
   JEDNYM runie — jedna sesja `0/N ready`. N RÓŻNYCH konceptów (inne
   presety/teksty/refy) ⇒ `--concepts-file`. `--variants 1` TYLKO gdy user nie
   podał żadnej liczby. NIGDY nie tłumacz „N miniatur" na N osobnych runów
   `generate` — to daje N sesji `0/1` w historii, N consentów i N szans na
   fail w połowie. Confirm real values with `thumbforge generate --help` and
   `thumbforge inventory`. State the choices to the user; don't over-ask.
   **Duo gate:** gdy wybrany preset ma `face_ref` + `guest_face_ref`, zatrzymaj
   budowę komendy i zapytaj: „Kto ma być po lewej, kto po prawej? Kto ma być
   wyższy/główny?”. Dopiero po odpowiedzi przypisz osoby pozycyjnie przez
   powtarzalne `--set-slot`; nie polegaj na kategorii primary/secondary:
   ```bash
   --set-slot face_ref=/references/<kategoria>/<osoba-lewa>.png \
   --set-slot guest_face_ref=/references/<kategoria>/<osoba-prawa>.png
   ```
   `face_ref` jest pierwszym refem i stoi po LEWEJ, `guest_face_ref` jest drugim
   i stoi po PRAWEJ. Preferencję wzrostu/głównej osoby zapisz jako krótkie,
   jawne ograniczenie kompozycji w `--topic` (np. „LEFT person visibly taller
   than RIGHT person”), a potem potwierdź jego obecność w resolved prompt dry-runu.
   **Tło: profil czy oryginał (presety z reverse):** a custom preset saved from
   a competitor analysis (tf-reverse) carries the source background as its own
   custom style, but at generation time the active profile's background (and
   palette / typography) replaces it; unset profile properties keep the
   source's. Default = profile; say so in the plan line. When the user wants
   the ORIGINAL background for this run, read the preset's
   `defaultBackgroundStyle` id from `thumbforge preset:show <presetId>` and pass
   it explicitly with `--background-style <id>` - that choice is per run, kept
   for retry, and never edits the saved preset. A `⚠` / `ostrzeżenie` line in
   the dry-run plan about a STYLE sentence mixing background with an object
   means the profile cannot replace that background: fix the preset with
   `/tf-preset` (`preset:edit --style-file`) before paying.
3. **Estimate cost (free).**
   ```bash
   thumbforge cost-estimate --count <variants> --model <model> --quality <q>
   ```
   `cost-estimate` nie czyta Ustawień (bez `--model` liczy domyślny model
   dostawcy): podaj `--model` modelu, którego użyje Run; model z Ustawień
   pokazuje darmowy dry-run (krok 4).
4. **Dry-run (free).** Run `generate` WITHOUT `--confirm` to surface the resolved
   prompt + plan.
   **Slug odcinka:** przed dry-runem zaproponuj 2-4 słowa z roboczego tytułu odcinka
   (ASCII, małe litery, myślniki, max 30 znaków, np. `codex-sdk`) i pokaż slug
   w podsumowaniu dry-runu przed płatnym wywołaniem, żeby user mógł go zmienić
   jednym słowem. Katalog to `$HOME/Downloads/<slug>`: każda komenda odkładająca PNG
   dostaje `--out "$HOME/Downloads/<slug>" --out-name <slug>`, a
   kolejne rundy odcinka używają tego samego sluga i katalogu (numeracja idzie
   dalej, bez podkatalogów rund).
   ```bash
   thumbforge generate --preset <id> --topic "<topic>" \
     [--profile <id>] [--visible-text "<headline>"] [--refs <p1,p2>] [--variants N] --quality <q> \
     --out "$HOME/Downloads/<slug>" --out-name <slug>
   ```
   **Wierność dry-runu:** resolved prompt i wycena pochodzą z procesu aplikacji.
   Paid run zachowuje argumenty ostatniego planu bajt w bajt i dodaje tylko
   inline env oraz `--confirm`; zmiana profilu, refów lub override wymaga nowego
   dry-runu i zgody.
   The dry-run also prints a **pre-flight checklist** (key / secret / `--out`) —
   resolve any `⚠` before asking for consent. Show the user the plan + the cost
   estimate, then **wait for explicit consent**.
5. **Paid run (only after consent).** The secret auto-loads — just run:
   ```bash
   THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge generate \
    --preset <id> --topic "<topic>" \
    [--profile <id>] [--visible-text "<headline>"] [--refs <p1,p2>] [--variants N] \
     --quality <q> \
     --out "$HOME/Downloads/<slug>" --out-name <slug> \
     --confirm
   ```
   `--out` is an **export policy, not a lock** (ADR 0005): default it to an
   absolute `$HOME/Downloads/<slug>` so the user always knows where the PNGs
   are (override on request). The thin client requires `--out`; only verified
   repo/dev mode may omit it and rely on its separate dev storage. The cost lock
   stays `--confirm` + `ALLOW=1`. Z `--out-name <slug>` kopie lądują płasko jako
   `<slug>-1.png`, `<slug>-2.png`; następna runda numeruje od największego numeru
   w katalogu + 1 i niczego nie nadpisuje. Przy każdym obrazie CLI wypisuje linię
   `<plik> -> koncept <k>, <preset>, wariant <w>, sesja <id>`.
6. **Preview grid (ALWAYS, for 2+ images).** After a successful paid run that
   produced **two or more** images, ALWAYS compose a review grid and open it — the
   user expects a single side-by-side preview every time, not just on request.
   For one session use its `sessionId`:
   ```bash
   thumbforge grid <sessionId> --out "$HOME/Downloads/<slug>" --out-name <slug>
   ```
   Use the `sessionId` printed by the paid run. `grid` is **free** (no model call)
   and uses the server's final images for that session. Skip the grid only for a
   **single** image (a 1-up grid is pointless). Grid rundy ląduje obok kopii jako
   `<slug>-grid-<n>.png` z osobnym licznikiem, więc nowa runda nie nadpisuje
   podglądu poprzedniej. Surface the grid path in the delivery alongside the
   individual finals.
   A `--concepts-file` Run planning **more than 4 images** splits into several
   sessions (≤4 images each) and prints one `batchId`. Compose exactly one **Grid
   Runu** from all final images:
   ```bash
   thumbforge grid --batch <batchId> --out "$HOME/Downloads/<slug>" --out-name <slug>
   ```
   **Grid Runu dla batcha >4 = jedno `grid --batch`, nigdy grid per sessionId; 4 obrazy = ładne 2×2.**
7. **Deliver.** Report the session id, UI path (`/history` / `/sessions/<id>`),
   exported PNG dir, the preview-grid path (step 6), and a one-line summary (preset,
   model, quality, variants, cost). Z linii mapy CLI pokaż tabelę plik -> koncept,
   preset, wariant, sesja. No JSON dumps.

## Flags (confirm with `thumbforge generate --help`)

| Flag | Use |
|---|---|
| `--preset <id>` | preset archetype (`list-presets`) |
| `--topic <t>` | the video topic (quote it) |
| `--visible-text <text>` | headline baked on the thumbnail (defaults to the preset's text style) |
| `--text-style <id>` | `<id>` from `thumbforge list-styles --type text` (built-in + custom); `none` keeps a text-less base |
| `--text-color <hex>` | headline color `#RRGGBB` (default `#FFFFFF`) |
| `--glow-color <hex>` | brand glow / rim-light color `#RRGGBB` — tints background, rim light & accents (e.g. teal `#14B8A6`); hex only, non-hex dropped |
| `--background-style <id>` | background style id from `thumbforge list-styles --type background` (built-in + custom), or a reverse preset's own `defaultBackgroundStyle` from `preset:show` to force the source background for this run; replaces the preset's default background sentence and wins over the profile background |
| `--expression <id>` | expression brick z `list-expressions`: mina + opcjonalna poza; nadpisuje default presetu; w `--concepts-file` = pole `expression` per koncept |
| `--set-slot <name=value>` | jawne wiązanie slotu; powtarzaj dla `face_ref` i `guest_face_ref`, aby ustawić lewą/prawą osobę niezależnie od kategorii refa |
| `--refs <p1,p2>` | comma-separated reference paths (order matters — see below) |
| `--provider openai\|google` | zwykle pomiń: `--model` wyznacza dostawcę z katalogu, a bez obu flag działa model z Ustawień |
| `--model <id>` | model z katalogu `inventory` (np. `gemini-nano-banana-2.1`); domyślnie model z Ustawień aplikacji |
| `--quality <tier>` | jakość z katalogu `inventory`; Sunburst/Flare: low / medium / high / xhigh / max / auto when listed; 2.1: low..max |
| `--profile <id>` | jawny profil marki; bez flagi thin używa aktywnego profilu aplikacji |
| `--variants <n>` | images per preset (default 1) |
| `--concepts-file <abs.json>` | batch mode: one logical Run with per-concept preset/text/refs/glow/quantity; >4 images split into ≤4-image sessions |
| `--out <absDir>` | required thin-client export dir (`$HOME/Downloads/<slug>`); optional only in verified repo/dev mode |
| `--out-name <slug>` | Slug odcinka: kopie `<slug>-<n>.png`, numeracja ciągła między rundami; bez `--out` tylko ostrzeżenie i brak kopii |
| `--confirm` | spend money (also needs the env) |

## Load-bearing rules

- **Ref ordering is positional.** For `collab-duo` and `host-plus-persona`, the
  host is `character-primary` and must be the FIRST character-role ref in
  `--refs`; the guest/persona is `character-secondary` and goes second. The
  resolver clusters refs by role and preserves order within the character bucket,
  so don't interleave other character refs between them and don't pass the guest
  as `character-primary` — either way the model swaps host and guest.
- **Duo świadomie nadpisuje role.** Gdy user poda strony, przekaż oba refy przez
  `--set-slot face_ref=<LEWA> --set-slot guest_face_ref=<PRAWA>`. Sloty, nie
  etykiety primary/secondary, wyznaczają wtedy `refPaths[0]` i `refPaths[1]`;
  nie zmieniaj kolejności presetowych slotów ani globalnej listy `--refs`.
- **Visual ref choice.** `list-refs` is discovery, not eyesight. Run
  `refs:contact-sheet` or inspect ambiguous `_thumb.png` previews before selecting
  refs, especially face slots where a named person might be a torso/hoodie crop
  rather than a usable face.
- **NO_TEXT_GUARD.** If the user wants text on the thumbnail, pass `--visible-text`.
  An empty visible text triggers a guard in the resolver — that's intended.
- **Expression ids come from `list-expressions`.** Dev i thin CLI odrzucają
  nieznane id przed płatnym callem; nadal wybieraj wyłącznie id odkryte w tej
  sesji, aby plan pokazał właściwy label i status pozy.
- **`--out`** must be absolute — it is an export copy, not a cost lock (ADR 0005).
  In the **dev CLI** it is optional: the CLI writes the canonical session files to
  `public/generations`, so history and previews work whether or not `--out` is
  passed. In **thin-client mode** (the installed `thumbforge` launcher driving the
  running desktop app) `--out` is **REQUIRED** — the CLI can't write into the app's
  userData, so it needs an export dir or `generate` errors `--out <absDir> jest
  wymagany`. Either way, default it to `$HOME/Downloads/<slug>` with
  `--out-name <slug>` for a tidy hand-off so the run never fails on a missing `--out`.
- **Batch mode — variants ≠ concepts.** N kandydatów JEDNEGO konceptu ⇒
  `--variants N` w jednym runie (jedna sesja, bez JSON-a). N RÓŻNYCH konceptów
  dla jednego filmu ⇒ `--concepts-file <abs.json>` (jeden logiczny Run, jeden
  dry-run, jeden consent). NIGDY pętla pojedynczych runów `generate` — tworzy
  niepowiązane sesje `0/1` i zaśmieca historię. The discovery gate + JSON
  format live in `../thumbforge/references/discovery-contract.md`.
- Don't reorder slots, don't hand-build prompts — the CLI resolver owns that.

## Errors

See `../thumbforge/references/troubleshooting.md`. If a path in `--refs` 404s,
re-run `list-refs` for the current paths. `command not found` means a stale name
— it's `cost-estimate`/`list-presets`, never `cost`/`list`.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają **`thumbforge`** — cienki klient HTTP i domyślną
powierzchnię. `pnpm cli <komenda>` wolno użyć tylko w dev-mode wykrytym wspólnym
kontraktem po manifeście `package.json` z `name === "thumbforge"` w cwd.

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `list-expressions`, `inventory`, `cost-estimate`, `edit`, `generate`, `resume`, `retry-image`, `reverse`, `reverse:contract`, `reverse:import`, `analyze-transcript`, `analyze-titles`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `expression:create`, `expression:edit`, `expression:delete`, `upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
