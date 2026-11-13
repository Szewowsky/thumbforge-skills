---
name: tf-onboarding
description: >-
  Sets up the thumbforge channel profile and its visual style (design system),
  run once before the first thumbnails. Use when a user is starting out without
  a channel profile or style, or when the onboarding check reports it
  incomplete.
argument-hint: "[kanał albo seria] [2-12 miniatur kanału]"
allowed-tools: Bash, Read
---

# tf-onboarding

Wprowadzenie kanału: profil i jego styl, z których korzystają skille generujące.

- **Profil**: kanał albo seria, do której trafia styl.
- **Styl**: design system profilu (paleta, typografia, tło, reguły).

Prowadzisz rozmowę, nie skrypt: stan -> ustalenia i pytanie -> potwierdzenie -> zapis -> gotowe. Ten skill jest
darmowy; płatna analiza miniatur należy do `tf-brand`.

## NOT for

- Licencja i aktywacja: Ekran klucza w aplikacji; klucze providerów: Ustawienia aplikacji; błędy:
  [troubleshooting](../thumbforge/references/troubleshooting.md).
- Pytanie, jak działa aplikacja albo którego skilla użyć -> `tf-ask`.
- Twarz hosta i inne referencje -> `tf-assets`.

## Step 0 - Bootstrap thin-first

Uruchom `thumbforge --help` (bezpłatne). Jeśli zawiedzie: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray -> Zainstaluj CLI.”
Następnie zastosuj wspólny [kontrakt Bootstrap thin-first](../thumbforge/SKILL.md#step-0--bootstrap-thin-first).
Które komendy ma cienki klient, a które są repo/dev-only, mówi
[sekcja routera](../thumbforge/SKILL.md#cienki-klient-tester-i-tryb-dev).

## Proces

### 1. Stan

Zastosuj [Stan onboardingu](../tf-ask/SKILL.md#stan-onboardingu), potem:

```bash
thumbforge profile:list
thumbforge inventory
```

Wynik reguły:

- **ukończony**: przejdź do kroku 5.
- **nieodczytany**: podaj komunikat albo cytat błędu i zakończ; regułę powtarzasz, gdy user usunie przyczynę.
- **nieukończony** bez profilu: user zakłada kanał w aplikacji (przełącznik profilu -> „+ Nowy kanał…”), potem
  powtórz regułę.

Brak twarzy hosta (`character-primary` w REFERENCES z `inventory`) zgłoś jednym zdaniem: dodaje się ją przez
`tf-assets`, a styl od niej nie zależy.
Gotowe, gdy reguła dała **nieukończony** dla istniejącego profilu i znasz go z nazwy, id oraz rodzaju (kanał czy
seria).

### 2. Ustalenia i pytanie

Pokaż w kilku linijkach: docelowy profil, twarz hosta, własne style i presety (`custom` w `inventory`). Zapytaj
o zakres stylu: a) rdzeń kanału, b) seria (z `profile:list` albo nowa, którą user zakłada w przełączniku profilu ->
„+ Nowa seria…”), z linią `Rekomendacja:` z aktywnego profilu. Zapytaj, czy user ma 2-12 własnych miniatur (lokalne pliki albo obrazy
z historii aplikacji).
Gotowe, gdy user potwierdził profil docelowy z nazwy i id oraz odpowiedział o miniatury.

### 3. Ścieżka

- **Są miniatury (2-12):** Wywołaj skill `tf-brand` (Claude Code: narzędzie Skill; Codex: `$tf-brand`) albo
  przeczytaj i wykonuj `../tf-brand/SKILL.md` od „Discovery”. Przekaż `profileId`, zakres z kroku 2 i źródła. Koszt, zgoda
  i `--overwrite` należą do `tf-brand`. Gotowe, gdy `tf-brand` prowadzi rozmowę; ten skill kończy się tutaj.
- **Brak albo jedna:** przeprowadź wywiad według [references/wywiad.md](references/wywiad.md).
  Gotowe, gdy user przejrzał i zatwierdził `design.md`.

### 4. Zapis

Uruchom bezpłatny `thumbforge brand:import` według sekcji „Import poprawionego design.md” w `../tf-brand/SKILL.md`
(tam `--overwrite` i błędy walidatora).
Gotowe, gdy CLI wypisało `Zaimportowano design system profilu <id>.` albo user świadomie odłożył styl.

### 5. Gotowe

Powiedz, który profil ma styl, i wskaż pierwszą miniaturę: `tf-generate` (temat i preset) albo `tf-brainstorm`
(koncept od zera). Jedno zdanie, wybór należy do usera.
