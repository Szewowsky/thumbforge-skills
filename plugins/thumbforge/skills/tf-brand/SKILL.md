---
name: tf-brand
description: >-
  Derives a reusable Thumbforge brand design system from 2-12 local thumbnails
  or generation-history images. Use when the user wants to analyze a channel or
  series visual identity, extract recurring palette, typography and background
  treatment, or import a reviewed design.md into a profile.
argument-hint: "<2-12 thumbnail paths or history image ids> [target profile]"
allowed-tools: Bash, Read
---

# tf-brand

Miniatury kanału lub serii -> analiza wspólnych cech -> design system zapisany
w profilu. Operuj przez cienki klient `thumbforge`. Analiza jest płatna, import
wcześniej przygotowanego `design.md` jest bezpłatny.

## NOT for

- Analiza pojedynczej miniatury. Design wymaga powtarzalnego wzorca.
- Kopiowanie źródeł do biblioteki referencji.
- Generowanie miniatur po analizie.

## Step 0 - Bootstrap

Najpierw uruchom bezpłatne `thumbforge --help` oraz `thumbforge inventory`.
Jeśli launcher nie odpowiada, poproś o uruchomienie aplikacji z Findera/tray.
Ten handshake kończy bootstrap - skill działa w dowolnym katalogu bez repozytorium.

## Discovery

Najpierw uruchom bezpłatne komendy:

```bash
thumbforge profile:list
thumbforge profile:current
thumbforge inventory
thumbforge brand:analyze --help
thumbforge brand:import --help
```

Ustal docelowy `profileId`. Gdy użytkownik nie wskazał profilu, zaproponuj profil
aktywny, ale nazwij go i pokaż jego id. Bez jawnego wyboru modelu pozwól CLI użyć
domyślnego; dry-run wypisze jego id i providera.

Zbierz od 2 do 12 unikalnych źródeł:

- lokalny PNG/JPEG/WebP przekazuj przez powtarzalne
  `--file "/absolutna/ścieżka.png"`;
- istniejący obraz z historii przekazuj in-place przez powtarzalne
  `--image <image-id>`;
- oba rodzaje można mieszać w jednym wywołaniu.

Nie kopiuj ani nie przenoś źródeł do `references`. Cienki klient czyta bajty
`--file` lokalnie, a serwer rozwiązuje `--image` po id historii.

Jeśli po deduplikacji jest mniej niż 2 wejścia, zatrzymaj się z komunikatem:
„Brand wymaga od 2 do 12 unikalnych miniatur. Dodaj jeszcze co najmniej jedno
źródło.” Przy więcej niż 12 poproś o wybór maksymalnie 12.

## Pytanie z opcjami i rekomendacją

Przed propozycją zadaj jedno pytanie o zakres systemu i pokaż trzy jawne opcje:

- a) rdzeń kanału - wzorce wspólne dla całej marki;
- b) konkretna seria - wzorce odróżniające cykl od kanału;
- c) eksperyment - analiza do przeglądu bez zastępowania istniejącego designu.

Dodaj linię `Rekomendacja: <a|b|c>`, uzasadnioną źródłami i wybranym profilem.
Nie wybieraj za usera, jeśli odpowiedź zmienia profil docelowy albo wymaga
`--overwrite`; zaczekaj na wybór a/b/c.

## Propozycja

Przed dry-runem pokaż jedną konkretną propozycję:

- profil docelowy: nazwa i id;
- enumerowana lista źródeł bez kopiowania plików;
- model i provider wypisane przez dry-run;
- plan `N vision + 1 synteza`, czyli `N+1` calli;
- informacja, czy istniejący design wymaga świadomego `--overwrite`.

Jeśli CLI zgłosi `Brak klucza providera`, żaden płatny call nie zaszedł. Podaj
provider i model, poproś o skonfigurowanie klucza w Ustawieniach aplikacji,
a potem ponów ten sam dry-run.

Jeśli po analizie użytkownik chce przejść do testowej generacji, przed handoffem
do `tf-generate` zapytaj: „Jaka jakość? a) medium - testy/porównania
(rekomendowane), b) low - odradzane, bo wynik jest niemiarodajny, c) high -
finał”. Rekomenduj `a`. Ten wybór trafia do późniejszego `generate --quality`;
`brand:analyze` nie ma jakości obrazu.

## Dry-run

Zbuduj jedno wywołanie z wszystkimi źródłami. Dla plików:

```bash
thumbforge brand:analyze \
  --profile "<profile-id>" \
  --file "/absolute/a.png" \
  --file "/absolute/b.png" \
  --model "<model-id>"
```

Dla historii lub wejścia mieszanego użyj tego samego polecenia, zastępując lub
uzupełniając flagi:

```bash
thumbforge brand:analyze \
  --profile "<profile-id>" \
  --image <image-id-1> \
  --image <image-id-2> \
  --file "/absolute/optional.png" \
  --model "<model-id>"
```

Brak `--confirm` oznacza dry-run. Pokaż użytkownikowi dokładnie wypisane przez
CLI: liczbę vision, jedną syntezę, łączną liczbę calli i szacowany koszt.

**Wierność dry-runu:** execute zachowuje profil, źródła, model oraz zaakceptowane
`--overwrite` dokładnie z ostatniego dry-runu. Dodaje wyłącznie inline env i
`--confirm`. Każda inna zmiana unieważnia plan, budżet i zgodę.

Gdy CLI zgłosi istniejący design, nie dodawaj `--overwrite` samodzielnie.
Poproś o osobną zgodę na zastąpienie, dodaj flagę i ponów dry-run. Flaga ma
pozostać także w późniejszym execute.

## Zgoda

Po udanym dry-runie zapytaj wprost: „Czy zgadzasz się na dokładnie N analiz
vision i 1 syntezę dla profilu <id>, za szacowany koszt <kwota>?”. Zaczekaj na
jednoznaczną odpowiedź. Zgoda na wcześniejszą analizę, import lub generację nie
przenosi się na ten call.

## Execute

Dopiero po zgodzie uruchom dokładnie argumenty z ostatniego dry-runu i dodaj dwa
pozostałe zamki:

```bash
THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge brand:analyze \
  --profile "<profile-id>" \
  --file "/absolute/a.png" \
  --file "/absolute/b.png" \
  --model "<model-id>" \
  --confirm
```

Jeśli dry-run zawierał `--image` lub zaakceptowane `--overwrite`, zachowaj je
bajt w bajt. Nie wykonuj pętli ani automatycznego retry. Każde ponowienie wymaga
nowego dry-runu i świeżej zgody.

## Wynik i błędy

- Pełny sukces: podaj profil oraz `Użyto N/N analiz` i poinformuj, że design
  został zapisany. Wskaż `thumbforge profile:current` jako kontrolę profilu.
- Częściowa porażka przy co najmniej 2 sukcesach: design jest zapisany. Podaj
  `Użyto X/N analiz` oraz każdą linię `Pominięto <źródło>: <błąd>`. Nie ukrywaj,
  że synteza powstała z mniejszego zbioru.
- Mniej niż 2 udane analizy: synteza i zapis nie zachodzą. Powtórz komunikat CLI
  `Synteza wymaga co najmniej 2 udanych analiz` i listę porażek. Nie ponawiaj
  płatnej komendy bez nowego dry-runu i zgody.
- Brak klucza: nie próbuj execute. Wskaż provider/model, poproś o konfigurację i
  potwierdź naprawę przez ponowienie tego samego dry-runu.

## Import poprawionego design.md

Import jest osobnym, bezpłatnym zapisem po świadomym przejrzeniu pliku:

```bash
thumbforge brand:import "/absolute/design.md" --profile "<profile-id>"
```

Jeśli profil ma już design, `--overwrite` dodaj wyłącznie po jawnej zgodzie na
zastąpienie:

```bash
thumbforge brand:import "/absolute/design.md" \
  --profile "<profile-id>" \
  --overwrite
```

Przy złym imporcie pokaż dokładny błąd walidatora. Plik musi mieć dokładnie jeden
marker machine-readable, blok `json`, wersję 1 lub 2, kolory `#RRGGBB`, dozwolone enumy
typografii i tła oraz reguły bez placeholderów. W v2 reguła ma `text` i
`kind=prompt|note`. Popraw plik i ponów wyłącznie
bezpłatny `brand:import`; błąd importu nie uzasadnia nowej płatnej analizy.
