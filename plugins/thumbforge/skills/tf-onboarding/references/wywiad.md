# Wywiad: styl kanału bez miniatur

Wynik: `design.md` gotowy do bezpłatnego `brand:import`.

## Pytania

Format: jedno pytanie na turę, ustalone pomijasz (intake w `../../tf-brainstorm/SKILL.md`, „Step 0.5”). Każde pytanie
ma 2-3 opcje (a, b, c) i linię rekomendacji w formacie sekcji „Pytanie z opcjami i rekomendacją” z `../../tf-brand/SKILL.md`.
Opcje budujesz z danych konta i z tego, co user już powiedział; rekomendację uzasadniasz tym samym.

Profil docelowy ustalił krok 2 `SKILL.md`. Kolejność pytań, każde -> jedno pole design systemu:

1. **Tło** -> `background`: opcje z `thumbforge list-styles --type background`, tylko wpisy `built-in` (import
   przyjmuje wyłącznie tła wbudowane).
2. **Typografia** -> `typography`: `inherit` albo jeden z kierunków `geometric-sans-black`, `condensed-display-bold`,
   `impact-condensed`, `slab-serif-heavy`.
3. **Paleta** -> `palette`: kolory `#RRGGBB` z kolorów marki usera (logo, baner, strona), z jednym mocnym akcentem;
   zasada akcentu: „Akcent palety” w `tf-brand`.
4. **Reguły** -> `rules`: `kind: "prompt"` trafia do promptu generacji, `kind: "note"` zostaje notatką dla człowieka.

Gotowe, gdy każde z czterech pól ma odpowiedź usera albo jego „zdecyduj ty”.

## design.md

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

Pokaż plik userowi do przejrzenia. Gotowe, gdy user zatwierdził treść; zapis robi krok 4 w `SKILL.md`.
