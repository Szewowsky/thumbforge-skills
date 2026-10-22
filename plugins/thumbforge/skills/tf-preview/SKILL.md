---
name: tf-preview
description: >-
  Shows a thumbforge session image in a YouTube feed mockup and walks a yes/no
  checklist of six thumbnail traits, free and without saving. Use when the user
  wants to see a thumbnail in the feed - "pokaż w feedzie", "podgląd w feedzie",
  "checklista miniatury", "/tf-preview".
argument-hint: "<sessionId> [--title <tytuł filmu>] [--image <id>] [--theme light]"
allowed-tools: Bash, Read
---

# tf-preview

Obraz sesji Thumbforge -> makieta feedu YouTube (`thumbforge preview`) -> checklista 6 cech `tak`/`nie`.
Całość jest darmowa: `preview` nie woła modelu, a checklista to ocena w rozmowie, bez punktacji i bez zapisu.

## NOT for

- Nowa miniatura albo regeneracja z poprawionym promptem -> `tf-generate`.
- Nowy kierunek od zera albo swobodny prompt -> `tf-brainstorm`.
- Wybór tytułu spośród kandydatów usera -> `tf-titles`.
- Edycja istniejącego obrazu instrukcją wyłącznie na jawną prośbę usera -> `/tf-edit`; ten skill jej nie proponuje.
- Makieta dowolnego pliku PNG spoza sesji Thumbforge: `preview` przyjmuje tylko obrazy sesji.

## Step 0 - Bootstrap thin-first

Uruchom `thumbforge --help` (bezpłatne). Jeśli zawiedzie: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray -> Zainstaluj CLI.”
Następnie zastosuj wspólny [kontrakt Bootstrap thin-first](../thumbforge/SKILL.md#step-0--bootstrap-thin-first); przed handshake nie czytaj plików repo ani nie zgaduj ścieżki maszyny.

Bez `THUMBFORGE_ALLOW_PAID_CALLS`, `--confirm` i dry-runu: `preview` nic nie kosztuje.

## Przepływ

1. **Wejście.** `sessionId` weź z rozmowy (linia mapy `... sesja <id>` po płatnej generacji) albo od usera
   (adres `/sessions/<id>` w aplikacji). Cienki klient nie ma komendy listy sesji: gdy id brakuje, zapytaj o nie
   jednym pytaniem i nie zgaduj „ostatniej sesji”. Tytuł filmu bierz wyłącznie od usera (wpisany albo wybrany
   spośród jego tytułów); nie wymyślaj go i nie poprawiaj. Bez tytułu pomiń `--title`: makieta pokaże temat sesji
   jako tekst zastępczy, CLI dopisze linię `uwaga: bez --title ...`, a ty powiedz to userowi jednym zdaniem.
2. **Render (darmowy).**
   ```bash
   thumbforge preview <sessionId> --title "<tytuł użytkownika>" --out "$HOME/Downloads/<slug>"
   ```
   `sessionId` i `--out` są wymagane. `<slug>` to Slug odcinka z wcześniejszej generacji; gdy go nie znasz,
   zaproponuj 2-4 słowa z tytułu (ASCII, małe litery, myślniki, max 30 znaków). Pozostałe flagi tylko z prośby
   albo danych usera: `--image <id>` dla innego obrazu sesji (domyślnie pierwszy finalny), `--theme light` dla
   jasnego feedu (domyślnie `dark`), `--avatar "<plik albo link>"` wyłącznie ze zdjęcia albo linku kanału od usera,
   nigdy zgadywany. Pełna lista flag: `thumbforge preview --help`. W dev-mode wykrytym wspólnym kontraktem ta sama
   komenda idzie jako `pnpm cli preview` z tymi samymi flagami.
3. **Pokaż makietę.** CLI drukuje `podgląd feedu (obraz <id>, motyw <motyw>) → <plik>`. Otwórz ten PNG narzędziem
   Read i podaj userowi ścieżkę. Makieta pokazuje miniaturę w trzech kafelkach: Strona główna, Następne, Telefon.
   Błąd CLI (np. brak sesji albo gotowego obrazu) przekaż słowo w słowo i poproś o inne `sessionId` albo `--image`.
4. **Checklista 6 cech.** Każda cecha dostaje `tak` albo `nie` i jedno zdanie uzasadnienia; bez punktów, sumy
   i oceny liczbowej. Nic nie zapisuj (żadnego `lesson:add`). Cztery cechy oceniasz sam z makiety:
   - **czytelna w małym rozmiarze** - napis i główny obiekt da się odczytać w kafelku Następne (najmniejsza
     miniatura), a nic ważnego nie leży pod czasem trwania w prawym dolnym rogu;
   - **informuje** - od razu widać, o czym jest film;
   - **zachęca** - jest powód do kliknięcia: emocja, kontrast albo pytanie, na które odpowiada dopiero film;
   - **uzupełnia tytuł** - napis dokłada coś do tytułu i go nie powtarza; przy tekście zastępczym zamiast tytułu
     powiedz, że tej cechy nie da się ocenić.
   Dwie cechy wymagają wiedzy spoza makiety, więc zapytaj o nie usera w tej samej wiadomości:
   - **nie oszukuje** - czy film dowozi to, co obiecuje miniatura?
   - **spójna z kanałem** - czy pasuje do pozostałych miniatur kanału albo serii?
5. **Przy `nie`.** Jedno zdanie, dlaczego, i jeden sugerowany krok: regeneracja z poprawionym promptem przez
   `tf-generate` (ten sam preset, poprawiony napis, temat albo refy) albo `tf-brainstorm` (nowy kierunek).
   Z własnej inicjatywy nie proponuj edycji istniejącego obrazu. Regeneracja to osobny płatny etap z dry-runem i
   zgodą w tamtym skillu; ten skill niczego nie generuje. Po nowej generacji wróć do kroku 2 z nowym `sessionId`.
6. **Ograniczenie.** Makieta działa tylko na obrazach sesji Thumbforge. Przy dowolnym pliku PNG (cudza miniatura,
   eksport z innego programu) powiedz wprost, że `preview` go nie przyjmie; nie składaj makiety ręcznie.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają domyślnie **`thumbforge`** - cienki klient HTTP.
`pnpm cli <komenda>` wolno użyć tylko w dev-mode wykrytym wspólnym kontraktem po
manifeście `package.json` z `name === "thumbforge"` w cwd.

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `list-expressions`, `inventory`, `cost-estimate`, `edit`, `generate`, `resume`, `retry-image`, `reverse`, `reverse:contract`, `reverse:import`, `analyze-transcript`, `analyze-titles`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `expression:create`, `expression:edit`, `expression:delete`, `upload-ref`, `rename-ref`, `move-ref`, `delete-ref`, `grid`, `preview`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) - cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)”.
