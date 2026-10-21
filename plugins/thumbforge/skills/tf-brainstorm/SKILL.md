---
name: tf-brainstorm
description: >-
  Brainstorm original YouTube thumbnail concepts and turn the chosen one into a
  safe freeform thumbforge custom prompt. Use when inventing a thumbnail from
  scratch — "/tf-brainstorm", "wymyśl thumbnail", "brainstorm miniatury",
  "zrób swobodny prompt", or a topic plus references but no fixed preset.
argument-hint: "[topic/inspiration] [--refs <paths>] [--custom-prompt]"
allowed-tools: Bash, Read
---

# tf-brainstorm

Original concept → Swobodny prompt → handoff to `thumbforge generate
--custom-prompt`. This skill is for ideation and prompt composition first; it
does not spend during the brainstorm. The paid stage is a normal generate call
with dry-run-first, explicit consent, and the triple lock.

## Not for

- Generating directly from an existing preset → `tf-generate`.
- Cloning a competitor's thumbnail → `tf-reverse`.
- Concepts from a transcript → `tf-scenario`.
- A YouTube URL or local media path supplied instead of text → suggest
  `/tf-transcript`; never invoke it automatically.
- Comparing title candidates before choosing a thumbnail direction → `tf-titles`.
- Editing reusable presets/styles → `tf-preset`.
- Listing or adding reference images → `tf-assets`.

## Step 0 — Bootstrap thin-first

Run `thumbforge --help` (free). If it fails: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray → Zainstaluj CLI.”
Then follow the shared [Bootstrap thin-first contract](../thumbforge/SKILL.md#step-0--bootstrap-thin-first); do not inspect repo files or guess a machine path before the handshake.

Read and apply these guardrails before proposing concepts:

- `../thumbforge/references/paid-call-protocol.md`
- `../thumbforge/references/discovery-contract.md`
- `../thumbforge/references/thumbnail-craft.md`
- `../thumbforge/references/gotchas.md`

Triple lock for the later real run: env `THUMBFORGE_ALLOW_PAID_CALLS=1`
(inline, never `export`) + `--confirm` + dry-run-first. Consent is per-call:
never re-run a `--confirm` command without fresh approval.

## Step 0.5 — Intake (interview)

Silently list what the user's message already settled, then ask ONLY about the
gaps — one question per turn, formatted as `❓ **question**` followed by
`➡️ Rekomenduję: <your concrete recommendation>`. A user who supplied a full
brief sees zero questions. Never re-ask anything already answered.

Question order (skip any that is settled):

1. **Tytuł filmu?** Two candidate titles are welcome — comment on which title
   plays best with which thumbnail type (a strong emotional title pairs with a
   thumbnail that does not repeat its words). Tytuł filmu tylko od usera: bez
   tytułu albo przy „zdecyduj ty” pracujesz na samym temacie.
2. **Masz transkrypt/scenariusz albo link do filmu?** Script text in hand →
   suggest `/tf-scenario`. A YouTube URL or local media file → suggest
   `/tf-transcript`. Suggestion + stop; never invoke either automatically.
3. **Masz wstępny pomysł/kierunek, czy mam pokminić od zera?** A vague seed
   ("coś z wykresem") is round-one input, not a commitment.
4. **Wzorujesz się na czymś?** A competitor thumbnail to clone → `/tf-reverse`
   + stop. A loose visual inspiration (an image to look at) stays here: borrow
   its grammar (scale, gaze direction, one hero object), never its exact layout
   or copy; do not persist it as a reference without need.
5. **Jakie assety gramy?** Show the real `list-refs` inventory (faces, icons)
   instead of asking in the void; ask whether the user has a screenshot/logo to
   add — route the upload through `/tf-assets` (free) and come back.
6. **Miniatury z napisami, bez, czy mix w batchu?** (e.g. 2x with text + 2x
   without — a common winning split).
7. **Emocja/mina + ogólność:** should the thumbnail sell the WHOLE film or one
   specific mechanism from it? This one answer saves a full proposal round.

At any question the user may say "nie wiem — zdecyduj ty": decide yourself
(everything except spending consent), note it, and before the dry-run print a
section `Zdecydowałem za ciebie:` listing every decision you took over.

## Workflow

1. **Discover live inputs (free).** Before selecting refs or style cues, discover
   what exists in this account:
   ```bash
   thumbforge list-refs --category character-primary
   thumbforge list-refs --category icon
   thumbforge list-styles
   thumbforge inventory
   ```
   `list-refs` is an index, not visual inspection. If several refs could fit,
   inspect the relevant `_thumb.png` previews. In repo/dev only, a contact sheet
   can help: `pnpm cli refs:contact-sheet --category <category> --out <dir>`.
   Gdy temat lub kierunek wymienia markę/logo, sprawdzenie kategorii `icon` jest
   bramką: istniejący ref trzeba podpiąć; brak refa trzeba jawnie zgłosić userowi
   przed użyciem słownego opisu marki.
   **Profil i dziedziczenie:** ustal aktywny profil widoczny w aplikacji; w
   zweryfikowanym repo/dev potwierdź go przez `pnpm cli profile:current`. Powiedz:
   `Dziedziczę z profilu <id lub aktywny>: design system, scalar overrides oraz
   lekcje`. Ponieważ `--custom-prompt` omija resolver, przepisz wybrane cue marki
   (paleta, typografia, tło i reguły prompt) jawnie do promptu. Jeśli user chce
   wyjątek, nazwij go i zakoduj w custom prompt; nie zmieniaj trwałego profilu.
2. **Diverge w rundach (Diverge before composing).** Before building any prompt,
   present at least
   **3 named directions** in a numbered round: 3-5 proposals by default, or
   5-10 on request. Each has a distinct archetype, mood and composition. Give each a
   one-sentence
   topic-specific rationale, układ, headline, refy, hook, ryzyko oraz osobną
   linię `➡️ Typ/rekomendacja: <opinia skilla>`. Co najmniej jedna wychodzi
   outside the preset catalog i używa Swobodnego
   `--custom-prompt`. Przed pokazaniem odfiltruj kierunki sprzeczne z wybranym w
   intake miksem napisów oraz ogólnością: cały film albo jeden mechanizm.

   Zbieraj werdykt per numer. Pewniaki odkładaj bez zmian, a następną rundą
   uzupełniaj tylko brakujące sloty, aż finalny zestaw będzie kompletny. Numery
   konceptów są stałe: nie używaj ich ponownie ani nie zmieniaj między rundami.
   Przy gridzie nazwij grid, pokaż mapowanie `<grid> v<n> -> koncept <numer>` i
   zachowaj je w kolejnych porównaniach. Niejednoznaczny werdykt wymaga pytania,
   nie zgadywania.

   Jeden płatny run obejmuje maksymalnie 4 koncepty. Większy zestaw podziel na
   osobne batche, każdy z własnym dry-runem i osobną zgodą kosztową. Gdy odpala
   się bramka transferu lokalnych assetów do providera, poproś o drugą, osobną
   zgodę na transfer. Każdy kierunek ma jeden headline; dodatkowa linia jest
   dozwolona tylko jako część jednego układu tekstowego, np. badge lub sandwich.
   Nie buduj jeszcze promptu.
3. **Explore the chosen direction with the user.** Let the user select, combine
   or reject directions. Resolve the chosen direction's key composition and
   message choices before descending into prompt wording.
   **Model i jakość:** domyślnie model z Ustawień aplikacji. Bez `--model`
   i `--provider` cienki klient bierze go z Ustawień, a dry-run drukuje
   `model: <dostawca>/<model> (<jakość>, źródło: ustawienia aplikacji)`; dev CLI
   drukuje `plan: <dostawca>/<model> @ <jakość>`. Na prośbę usera (np. „na Nano
   Bananie”) weź inny model z katalogu `thumbforge inventory`, np.
   `--model gemini-nano-banana-2.1` bez `--provider`: dostawcę CLI bierze z katalogu,
   a dry-run pokazuje `źródło: flaga`. Inventory to katalog modeli klienta, nie
   dowód dostępu konta. Drabinka `gemini-nano-banana-2.1`:
   - `low` - 1K, myślenie minimal: najtańsze szybkie szkice.
   - `medium` - 1K, myślenie medium: domyślna jakość, ustawienie zalecane przez Google.
   - `high` - 1K, myślenie high: lepsze trzymanie się promptu.
   - `xhigh` - 2K, myślenie high: ostrzejszy obraz i RAW 2K.
   - `max` - 4K, myślenie high: RAW 4K, najdroższy tier.
   Jeśli użytkownik nie podał już modelu i jakości, zapytaj o jakość zgodną z
   katalogiem wybranego modelu. Gdy katalog zwraca, zarówno
   `gpt-image-2.5-sunburst`, jak i `gpt-image-2.5-flare` mają `low`, `medium`,
   `high`, `xhigh`, `max`, `auto`; `auto` opisuj jako orientacyjny max outputu
   bez gwarancji. Stara aplikacja może nie obsługiwać Flare, więc potwierdź to
   dry-runem przed płatnym wywołaniem.
4. **Compose the Swobodny prompt.** `--custom-prompt`
   bypasses the preset resolver, so any normally injected safety must be present
   manually:
   - Choose the `<carrier>` archetype by subject count, then run
     `thumbforge lesson:list <carrier> --profile <aktywny>`. Wybierz maksymalnie 5
     lekcji najtrafniejszych dla konceptu i przepisz je verbatim do custom
     promptu. This manual step is required because `--custom-prompt`
     bypasses the resolver, just as it requires manual brand cues.
   - If a face or identity ref is used, include a literal `FACE_LOCK` block that
     says the first reference image is the identity source, preserve exact
     photographic identity, and keep the full head inside the frame.
   - If visible text is present, include safe-zone text rules: central 85%
     safe-zone, at least 8% edge padding, and auto-scale/shrink the headline so
     nothing clips.
   - Keep the prompt specific enough to render: composition, subject, expression,
     background, lighting, text, and what to avoid.
5. **Dry-run the handoff (free).** `generate` always needs a `--preset` carrier — even in
   Swobodny prompt mode the server requires a non-empty preset id to enter generation. The
   carrier's *prompt* is fully replaced by `--custom-prompt`, but the carrier still drives slot
   auto-bind and ref ordering — so pick an archetype matching the concept's subject count (e.g.
   `hero-chest-up` for one person, `collab-duo` for two); refs come from `--refs`.
   **Slug odcinka:** przed dry-runem zaproponuj 2-4 słowa z roboczego tytułu odcinka
   (ASCII, małe litery, myślniki, max 30 znaków, np. `codex-sdk`) i pokaż slug
   w podsumowaniu dry-runu przed płatnym wywołaniem, żeby user mógł go zmienić
   jednym słowem. Katalog to `$HOME/Downloads/<slug>`: każda komenda odkładająca PNG
   dostaje `--out "$HOME/Downloads/<slug>" --out-name <slug>`, a
   kolejne rundy odcinka używają tego samego sluga i katalogu (numeracja idzie
   dalej, bez podkatalogów rund).
   `--model` podaj tylko przy modelu innym niż ten z Ustawień:
   ```bash
   thumbforge generate --preset hero-chest-up --topic "<topic>" \
     --custom-prompt "<freeform prompt>" \
     --refs <face,icon,...> \
     [--profile <id>] [--model <model>] --quality <q> \
     --out "$HOME/Downloads/<slug>" --out-name <slug>
   ```
   Show the resolved plan and cost estimate, then wait for explicit consent.
6. **Paid run only after consent.**
   ```bash
   THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge generate --preset hero-chest-up --topic "<topic>" \
     --custom-prompt "<freeform prompt>" \
     --refs <face,icon,...> \
     [--profile <id>] [--model <model>] --quality <q> \
     --out "$HOME/Downloads/<slug>" --out-name <slug> \
     --confirm
   ```
   Kopie lądują jako `<slug>-<n>.png`, a CLI wypisuje przy każdym obrazie linię
   `<plik> -> koncept <k>, <preset>, wariant <w>, sesja <id>`.
7. **Grid for 2+ images (free).** Grid rundy to `<slug>-grid-<n>.png` obok kopii.
   ```bash
   thumbforge grid <sessionId> --out "$HOME/Downloads/<slug>" --out-name <slug>
   ```
8. **Werdykt i poprawka.** Pokaż mapowanie grida z kroku Diverge i zbierz
   feedback per obraz/numer; niejednoznaczne wskazanie wyjaśnij. Sklasyfikuj
   każdą uwagę jako jednorazową, która trafia tylko do promptu regeneracji, albo
   powtarzalną, która jest kandydatem na lekcję.

   Przed regeneracją powiedz wprost, że świeża generacja nie zachowa układu
   piksel w piksel. Zwycięzców nie dotykaj. Dla każdego wskazanego konceptu
   przepisz pełny prompt według feedbacku i regeneruj tylko ten koncept, przez
   nowy dry-run i zgodę z kroków 5-6. To domyślna ścieżka poprawek: nie sugeruj
   ani nie uruchamiaj edycji regionów lub instruction-edit z własnej inicjatywy.
   Edycja istniejącego obrazu zaczyna się tylko od jawnego `/tf-edit` usera.

   Przed każdym zapisem lekcji ponownie uruchom
   `thumbforge lesson:list <carrier> --profile <aktywny>`. Duplikat pomiń, a
   sprzeczność przedstaw jako propozycję
   `thumbforge lesson:edit <id> --text "<jedna linia>"`. Nową powtarzalną lekcję
   zapisuj w jednej linii dopiero po potwierdzeniu usera:
   `thumbforge lesson:add <carrier> --profile <aktywny> --text "<jedna linia>"`.
   Na końcu pokaż gridy porównawcze i poproś o finalny wybór.
9. **Optional — turn a winning concept into a reusable template.** A Swobodny
   prompt is one-shot; the resolver does not save it as a preset. If the brainstormed
   thumbnail works and the user wants to reuse the layout, hand off to **/tf-reverse
   `--file <the generated PNG>`** — it analyzes the *rendered* image into a custom
   preset (Reverse-preset). That is the route to "my own template": brainstorm →
   generate → reverse → reusable preset. `tf-reverse` uses the conversation model
   plus free JSON import, never adds the rendered source to the reference library,
   and chooses generation refs only in the later generation stage.

## Existing template vs original concept

This skill is for **original** concepts (Swobodny prompt). If the user instead wants
to build on an **existing** template, that is just a normal preset run — route to
**/tf-generate `--preset <id>`** (optionally after brainstorming which preset fits).
Use Swobodny prompt only when no preset captures the idea.

## Load-bearing rules

- `--custom-prompt` is Swobodny prompt mode: the resolver does not add
  FACE_LOCK, expression fragments, or text safe-zone phrases for you. Re-inject
  FACE_LOCK and safe-zone text whenever refs/faces/text are part of the concept.
- `--custom-prompt` still needs a `--preset <archetype>` carrier — the server rejects a
  generate with an empty preset id ("Podaj --preset"). The carrier's prompt is overridden by
  `--custom-prompt`; choose it by subject count (single-subject archetype, or `collab-duo` for
  two).
- Jakość jest świadomym wyborem z katalogu modelu. Dla Image 2.5 `auto` jest
  orientacyjnym max outputu bez gwarantowanego pułapu; jeśli user podał model i
  jakość, zachowaj je bez ponownego pytania. CLI bez `--quality` nie wybiera po cichu.
- Grupuj do 4 konceptów lub wariantów w jednym batchu/sesji/gridzie zamiast
  powtarzać pojedyncze płatne runy. Większy zestaw dziel zgodnie z bramkami z
  kroku Diverge.
- Routing poprawek prowadzi do świeżej regeneracji z przepisanym promptem;
  `/tf-edit` pozostaje wyłącznie flow wywoływanym jawnie przez usera.
- Do not copy an exact competitor thumbnail. If the user wants to adapt a source
  thumbnail, route to **/tf-reverse** first; use this only for original concepts.
- No extra machinery here: this skill is prose plus the shared guardrail docs.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają domyślnie **`thumbforge`** — cienki klient HTTP.
`pnpm cli <komenda>` wolno użyć tylko w dev-mode wykrytym wspólnym kontraktem po
manifeście `package.json` z `name === "thumbforge"` w cwd.

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `list-expressions`, `inventory`, `cost-estimate`, `edit`, `generate`, `reverse`, `analyze-transcript`, `analyze-titles`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `expression:create`, `expression:edit`, `expression:delete`, `lesson:list`, `lesson:add`, `lesson:edit`, `upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
