# Thumbforge - skille 0.1.26 do beta54

Ta gałąź `beta54-preview` zawiera aktualne skille do Thumbforge **beta54 lub nowszego**.
To osobny kanał instalacji. Nie zmienia zwykłego marketplace z gałęzi `main` ani
feedu aktualizacji aplikacji. Repozytorium i ta gałąź są publiczne; to nie prywatny link.

**Najpierw zainstaluj aplikację beta54 otrzymaną od Roberta.** Sama paczka skilli nie
aktualizuje aplikacji. Starszy CLI może nie mieć `reverse:contract` i `reverse:import`,
a starsza aplikacja nie udostępnia Sunburst. Nie kieruj brakujących komend do innego
providera ani płatnego fallbacku.

## Przygotowanie aplikacji

1. Zainstaluj i uruchom Thumbforge. Aplikacja musi działać podczas korzystania ze skilli.
2. Sprawdź `thumbforge --help`. Jeśli CLI nie jest dostępne, użyj menu tray aplikacji
   i akcji „Zainstaluj CLI”.
3. Klucze providerów ustaw w aplikacji. Nie przekazuj ich do czatu ani tej paczki.

## Claude Code

Jeśli masz starszy plugin `thumbforge@thumbforge-skills`, wyłącz go w `/plugin` ->
Installed w używanym projekcie, aby nie ładować jednocześnie dwóch wersji Thumbforge.
Następnie uruchom w Claude Code:

```text
/plugin marketplace add Szewowsky/thumbforge-skills@beta54-preview
/plugin install thumbforge@thumbforge-beta54-preview
/reload-plugins
```

Jeżeli Twoja wersja nie ma `/reload-plugins`, uruchom nową sesję.
W `/plugin` sprawdź wersję **0.1.26** i źródło **thumbforge-beta54-preview**.
Przykładowe wejście: `/thumbforge:tf-generate`.

Aktualizacja tego kanału w terminalu:

```bash
claude plugin marketplace update thumbforge-beta54-preview
claude plugin update thumbforge@thumbforge-beta54-preview
```

Claude Code może aktualizować pluginy automatycznie, jeśli włączysz tę opcję dla
marketplace. Marketplace dodany z `@beta54-preview` śledzi tę gałąź, nie `main`.

## Codex

Pobierz [ZIP tej gałęzi](https://github.com/Szewowsky/thumbforge-skills/archive/refs/heads/beta54-preview.zip)
i rozpakuj go. Skopiuj wszystkie 11 folderów z `plugins/thumbforge/skills/` do
`.agents/skills/` w swoim projekcie. Zachowaj ich nazwy i zawartość podfolderów
`thumbforge/references`, ponieważ skille odwołują się do nich wzajemnie.
Zastąp wcześniejsze wersje tych samych skilli; pozostałe skille zostaw nietknięte.
Uruchom nową sesję Codexa. Możesz wywołać `$thumbforge` albo `$tf-generate`.

Jeśli poprzednia instalacja używa symlinków, zaktualizuj ich cele na nową paczkę
zamiast zostawiać odsyłacze do starego cache. Nie zamieniaj symlinków w przypadkowe
częściowe kopie i nie mieszaj wersji poszczególnych skilli.

## Co jest w paczce

11 skilli: `thumbforge`, `tf-generate`, `tf-reverse`, `tf-reverse-auto`, `tf-scenario`,
`tf-titles`, `tf-brand`, `tf-brainstorm`, `tf-edit`, `tf-preset`, `tf-assets`.

- Generowanie i edycja miniatur, katalog modeli i jakości, plan kosztów przed wywołaniem.
- Reverse analizowany w rozmowie oraz osobny jawny analyzer aplikacji.
- Praca z presetami, stylami, minami, referencjami i profilami marki.

Generacja nadal wymaga świadomej zgody na płatne wywołanie. Analiza w rozmowie
wykorzystuje plan/budżet CC lub Codexa; nie jest obietnicą braku kosztu rozmowy.

Zmiany z prywatnych wersji beta53.1 i beta54: [CHANGELOG.md](CHANGELOG.md).
