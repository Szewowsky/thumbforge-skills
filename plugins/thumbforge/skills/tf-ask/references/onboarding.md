# Onboarding: profil i styl kanału

Cel: profil kanału z design systemem. Analiza miniatur jest płatna i należy do `tf-brand`; ten plik czyta stan za
darmo i prowadzi wywiad, gdy miniatur brak.

## 1. Stan

```bash
thumbforge profile:list
thumbforge profile:current
```

Razem z `thumbforge inventory` ze Step 0 ustal: docelowy profil (kanał albo seria, id), twarz hosta (`character-primary`
w REFERENCES), własne style i presety (`custom`). Te komendy nie pokazują design systemu; istniejący design wykrywa
dopiero `tf-brand` (dry-run analizy albo import).

Brak profilu (`Brak aktywnego profilu.` albo pusta lista): user zakłada kanał w aplikacji (przełącznik profilu ->
„+ Nowy kanał…”), potem powtórz odczyt. Brak twarzy hosta zgłoś od razu jednym zdaniem (dodaje się ją przez
`tf-assets`); styl kanału od niej nie zależy.
Gotowe, gdy user potwierdził docelowy profil z nazwy i id.

## 2. Miniatury czy wywiad

Zapytaj, czy user ma od 2 do 12 własnych miniatur kanału albo serii (lokalne pliki albo obrazy z historii aplikacji).

- **Są:** przejdź do `tf-brand` w tej rozmowie. Wywołaj skill `tf-brand` (Claude Code: narzędzie Skill; Codex:
  `$tf-brand`) albo przeczytaj `../../tf-brand/SKILL.md` i wykonuj go od „Discovery”. Przekaż `profileId` i listę
  źródeł. Koszt, zgoda i `--overwrite` należą do `tf-brand`. Gotowe, gdy `tf-brand` prowadzi rozmowę.
- **Brak albo jedna:** wywiad (krok 3).

## 3. Wywiad

Format: jedno pytanie na turę, ustalone pomijasz (intake w `../../tf-brainstorm/SKILL.md`, „Step 0.5”). Każde pytanie
ma 2-3 opcje (a, b, c) i linię rekomendacji w formacie sekcji „Pytanie z opcjami i rekomendacją” z `../../tf-brand/SKILL.md`.
Opcje budujesz z danych konta i z tego, co user już powiedział; rekomendację uzasadniasz tym samym.

Kolejność pytań, każde -> jedno pole design systemu:

1. **Zakres** -> docelowy profil: rdzeń kanału albo seria (opcje a i b pytania o zakres z `tf-brand`).
2. **Tło** -> `background`: opcje z `thumbforge list-styles --type background`, tylko wpisy `built-in` (import
   przyjmuje wyłącznie tła wbudowane).
3. **Typografia** -> `typography`: `inherit` albo jeden z kierunków `geometric-sans-black`, `condensed-display-bold`,
   `impact-condensed`, `slab-serif-heavy`.
4. **Paleta** -> `palette`: kolory `#RRGGBB` z kolorów marki usera (logo, baner, strona), z jednym mocnym akcentem;
   zasada akcentu: „Akcent palety” w `tf-brand`.
5. **Reguły** -> `rules`: `kind: "prompt"` trafia do promptu generacji, `kind: "note"` zostaje notatką dla człowieka.

## 4. Wynik wywiadu

Zapisz `design.md` w katalogu uzgodnionym z userem. Import czyta wyłącznie blok po markerze; nagłówek i opis są dla
człowieka. Kształt (wartości przykładowe):

~~~markdown
# Brand design

<!-- thumbforge:brand-design -->
```json
{
  "version": 2,
  "palette": ["#0B0B0F", "#FFD400", "#FFFFFF"],
  "typography": "impact-condensed",
  "background": "dark-gradient-rim",
  "rules": [
    { "text": "One bold yellow keyword per headline.", "kind": "prompt" },
    { "text": "Logo kanału zawsze w lewym górnym rogu.", "kind": "note" }
  ]
}
```
~~~

Pokaż plik userowi do przejrzenia, potem uruchom bezpłatny `thumbforge brand:import` według sekcji „Import
poprawionego design.md” w `../../tf-brand/SKILL.md` (tam `--overwrite` i błędy walidatora).
Gotowe, gdy import zgłosił sukces albo user świadomie odłożył styl.

## 5. Dalej

Pierwsza miniatura -> `tf-generate` albo `tf-brainstorm`, według [mapy](mapa.md). Jedno zdanie, wybór należy do usera.
