# Zmiany z beta53.1 i beta54

Paczka skilli 0.1.26, kanał beta54-preview. Pełen zestaw funkcji wymaga aplikacji beta54.

## Beta54 - GPT Image 2.5 Sunburst

- Nowy model do generowania i edycji miniatur, dostępny również przez CLI i skille.
- Jakości low, medium, high, xhigh, max i auto. Domyślna jakość Sunburst to high;
  dotychczasowy wybór modelu użytkownika pozostaje zachowany.
- Rozliczenie wykorzystuje dane usage po generacji. Estymata przed wywołaniem
  i koszt wyliczony z tokenów są rozróżnione; auto ma wyłącznie orientacyjną wycenę.
- Edycje faktycznie używają wybranej jakości. Wyższe jakości mają ochronę przed
  automatycznym mnożeniem płatnych prób, a pilot ma dłuższy timeout wywołania generacji.
- Menu jakości CLI korzysta z katalogu wybranego modelu. Skille zachowują wcześniej
  podany model i jakość, zamiast pytać o nie ponownie.

## Beta53.1 - reverse i pełny prompt

- Odtwarzanie kompozycji mniej zależy od geometrii wbudowanego archetypu; poprawiono
  przenoszenie układu, typografii, kolorów i nośnika napisu z analizy.
- Można zapisać wybrane elementy analizy: tło, styl napisu, minę lub cały preset,
  a także użyć kompozycji jednorazowo bez dodawania jej do biblioteki.
- Edytowalny prompt uwzględnia pełne ustawienia używane do generacji. Usunięto
  ciche obcinanie kompozycji i poprawiono ostrzeżenia o konflikcie ze stylem marki.
- `tf-reverse` korzysta z analizy w rozmowie i importuje ją do aplikacji, bez
  dodatkowego wywołania analyzera aplikacji. `tf-reverse-auto` osobno uruchamia
  analyzer aplikacji po jawnej zgodzie. Generacja obrazu pozostaje płatnym etapem.

## Prywatny instalator

Przekazywany indywidualnie wariant beta54 PRIVATE jest przeznaczony na Maca z Apple
Silicon. Nie wymaga aktywacji i ma wyłączony automatyczny updater. Własne klucze API
nadal są potrzebne. Ta gałąź nie publikuje instalatora ani feedu aplikacji.
