# Hooki tytułu i metody konceptu

Katalog dla `tf-titles` i `tf-brainstorm`. Rozpoznaje typ hooka w tytule usera i
podpowiada wbudowany preset oraz styl tekstu, z którymi miniatura gra razem z tym
tytułem. Katalog klasyfikuje tytuł, który podał user; nie wymyśla tytułów i nie
zmienia ich brzmienia.

- Na każdy tytuł jedna linia `typ hooka -> preset + styl tekstu`, wyłącznie z
  wartościami z tabeli poniżej.
- Gdy pasuje kilka typów, wybierz ten, który niesie główną obietnicę tytułu.
- Gdy nie pasuje żaden, powiedz to wprost; nie naciągaj najbliższego typu.
- Preset i styl to punkt startu rozmowy z userem, nie wyrok. Styl dotyczy
  wariantu z napisem; wariant bez napisu zostaje dozwolony. Aktualne presety i
  style konta pokazują `thumbforge list-presets` i `thumbforge list-styles`.

## Typy hooka

| Typ | Po czym rozpoznać w tytule | Preset | Styl tekstu | Dlaczego |
|---|---|---|---|---|
| Lista z liczbą | Liczba na początku albo obietnica policzalnego zbioru: narzędzi, sposobów, aplikacji, błędów. | `icon-holder-grid` | `count-headline` | Duża liczba i siatka ikon pokazują rozmiar zbioru szybciej niż słowa. |
| Pojedynek | Dwie nazwy zestawione spójnikiem „czy”, „kontra” albo „vs”, często z pytaniem o zwycięzcę. | `split-hero` | `heavy-bold` | Dwie karty po bokach twarzy same pokazują starcie, więc wystarczy krótki napis z pytaniem o werdykt. |
| Darmowy zamiennik | Coś za darmo zamiast płatnego odpowiednika albo tańsza droga do tego samego efektu. | `split-before-after` | `sandwich-with-badge` | Strefa płatnego oryginału obok strefy darmowego zamiennika robi porównanie, a badge niesie jedno słowo o cenie. |
| Przemiana | Zmiana stanu w czasie: z gorszego na lepszy, efekt po określonym okresie, stan przed i po. | `split-before-after` | `heavy-bold` | Kontrast dwóch stref obrazu niesie obietnicę zmiany bez czytania. |
| Instrukcja | Słowo „jak” na początku, poradnik, konfiguracja, instalacja albo obietnica, że widz zrobi to sam. | `screen-show` | `sandwich-with-badge` | Widz chce zobaczyć ekran, na którym to zrobi, a badge mieści jedno słowo działania. |
| Trik w telefonie | Funkcja, ustawienie albo skrót w telefonie lub w aplikacji mobilnej. | `phone-hold` | `led-banner` | Telefon w dłoni z ekranem aplikacji od razu mówi, że chodzi o urządzenie widza. |
| Premiera | Nazwa produktu z nowym numerem wersji, premiera, aktualizacja albo debiut usługi. | `icon-holder-single` | `chunky-3d` | Jedno duże logo daje rozpoznanie marki w pół sekundy, a przestrzenny napis podkreśla wagę wydarzenia. |
| Reakcja na wiadomość | Świeże wydarzenie z branży, zaskakująca decyzja firmy albo coś, co właśnie się stało. | `reaction-shocked` | `sandwich` | Wyrazista mina w ramie napisu góra-dół sprzedaje emocję wydarzenia, zanim widz przeczyta tytuł. |
| Ostrzeżenie | Przeczenie albo tryb rozkazujący, błąd, pułapka, strata, wezwanie do zatrzymania się. | `hero-pointing` | `heavy-bold` | Gest wskazuje konkretną rzecz do uniknięcia, a stawka mieści się w jednym krótkim napisie. |
| Osobisty test | Autor sam coś sprawdził: przez określony czas, za określoną kwotę, na własnym koncie albo sprzęcie. | `hero-chest-up` | `heavy-bold` | Twarz autora niesie wiarygodność próby, a napis podaje stawkę albo skalę, nie wynik. |
| Konkretny wynik | Kwota, procent, liczba godzin albo oszczędność podana jako dowód. | `hero-pointing` | `count-headline` | Gest prowadzi oko od dużej liczby po lewej do twarzy, a cyfry renderują się pewniej niż słowa. |
| Tajemnica | Obietnica czegoś ukrytego, przemilczanego albo nieznanego większości widzów. | `hero-chest-up` | `sandwich` | Mina kogoś, kto wie więcej, i dwuczęściowy napis zostawiają jedno pytanie, na które odpowiada dopiero film. |
| Rozmowa z gościem | Wywiad, rozmowa, wspólny odcinek, rola albo imię gościa obok autora. | `collab-duo` | `chunky-3d` | Dwie twarze obok siebie mówią o rozmowie bez słów; twarz gościa pochodzi wyłącznie z refów usera. |
| Autor i persona | Autor razem z drugą postacią: asystentem, botem, alter ego albo odgrywaną rolą. | `host-plus-persona` | `heavy-bold` | Druga postać obok autora pokazuje relację, o której jest film; persona pochodzi wyłącznie z refów usera. |
| Start od zera | Podstawy, pierwsze kroki, wersja dla początkujących, obietnica prostoty. | `icon-holder-mascot` | `heavy-bold` | Logo narzędzia z przyjazną maskotką obniża próg wejścia i mówi, że będzie prosto. |

## Metody konceptu

Metoda to sposób, w jaki koncept zdobywa kliknięcie. Każdy kierunek brainstormu
nosi dokładnie jedną z czterech metod.

- **hak**
  - Reguła: obraz zostawia otwarte dokładnie jedno pytanie, na które odpowiada
    dopiero film; pokazuje stawkę albo moment tuż przed rozwiązaniem, nigdy samo
    rozwiązanie.
  - Kiedy: tytuł obiecuje wynik, sekret albo zwrot akcji, a temat da się streścić
    jednym napięciem.
- **widoczność**
  - Reguła: jeden dominujący element czytelny w najmniejszym rozmiarze feedu:
    duża twarz albo duży obiekt, mocny kontrast z tłem, najwyżej trzy elementy.
  - Kiedy: temat jest prosty i znany, a o kliknięciu decyduje to, czy miniatura
    wybije się w zatłoczonym feedzie, zwłaszcza na telefonie.
- **pomost**
  - Reguła: łączy nowy albo abstrakcyjny temat z czymś, co widz już rozpoznaje,
    wyłącznie przez logo lub markę z referencji usera w kategorii `icon`
    (sprawdzone przez `list-refs --category icon`); nigdy przez twarze ani
    podobizny znanych osób.
  - Kiedy: temat jest nowy albo trudny do pokazania, a znana marka skraca widzowi
    drogę do zrozumienia. Bez pasującego refa `icon` wybierz inną metodę.
- **spójność**
  - Reguła: trzyma stałe elementy kanału albo serii z aktywnego profilu (paletę,
    typografię, tło, miejsce twarzy) i zmienia tylko treść odcinka.
  - Kiedy: odcinek należy do serii albo kanał ma rozpoznawalny styl, po którym
    stali widzowie znajdują go w feedzie.

## Format konceptu

Każdy koncept podaje sześć pól w tej kolejności, każde w osobnej linii
`<pole>: <treść>`:

- **Twarz/mina:** czyja twarz (ref z `list-refs`) i jaka mina; koncept bez twarzy
  mówi to wprost.
- **Tło:** kolor, światło i scena za podmiotem; przy aktywnym profilu tło z design
  systemu albo nazwany wyjątek.
- **Obiekty:** element kontekstu obok twarzy (logo, ikona, ekran albo przedmiot),
  razem z twarzą i napisem najwyżej trzy elementy; każdy z refem z `list-refs`
  albo z jawnym „brak refa”.
- **Napis:** jeden krótki headline na miniaturze albo „bez napisu”; uzupełnia
  tytuł i nie powtarza jego słów.
- **Obietnica tytułu:** co obiecuje tytuł i czego napis celowo nie powtarza; bez
  tytułu od usera opisz obietnicę tematu, nie wymyślaj tytułu.
- **Pierwsze 30 s:** co film musi pokazać na starcie, żeby dotrzymać obietnicy
  miniatury i tytułu.
