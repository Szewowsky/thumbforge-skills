---
name: tf-ask
description: >-
  Skill map and channel onboarding for thumbforge. Use when the user asks how
  the app and its skills work, or is starting out without a channel profile or
  style.
argument-hint: "[pytanie o aplikację albo „jak zacząć”]"
allowed-tools: Bash, Read
---

# tf-ask

Dwie gałęzie: **mapa** (potrzeba -> skill albo dokument) i **onboarding** (profil i styl kanału). Ten skill jest
darmowy; płatny krok zaczyna się dopiero w skillu docelowym, pod jego protokołem.

## NOT for

- Zadanie z jasną intencją: idź prosto do skilla, np. miniatura z tematu -> `tf-generate`, klon cudzej -> `tf-reverse`.
- Analiza miniatur, gdy user ma już 2-12 plików i chce design systemu -> `tf-brand` bez onboardingu.
- Pomysł na jedną konkretną miniaturę -> `tf-brainstorm`.

## Step 0 - Bootstrap thin-first

Uruchom `thumbforge --help` (bezpłatne). Jeśli zawiedzie: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray -> Zainstaluj CLI.”
Następnie zastosuj wspólny [kontrakt Bootstrap thin-first](../thumbforge/SKILL.md#step-0--bootstrap-thin-first).
Stan konta (licencja, presety, style, modele, referencje) czytasz przez `thumbforge inventory`; obie gałęzie z niego
korzystają. Które komendy ma cienki klient, a które są repo/dev-only, mówi
[sekcja routera](../thumbforge/SKILL.md#cienki-klient-tester-i-tryb-dev).

Bez działającej aplikacji mapa odpowiada z plików skilli i dodaje komunikat o uruchomieniu aplikacji, a onboarding
czeka z komunikatem, aż user uruchomi aplikację, bo stan konta czytają tylko komendy CLI.

## Rozgałęzienie

- Co aplikacja umie, którego skilla użyć, czym różnią się dwa skille -> **mapa**: wykonaj
  [references/mapa.md](references/mapa.md).
- Jak zacząć, nowy kanał, profil bez stylu -> **onboarding**: wykonaj
  [references/onboarding.md](references/onboarding.md).
- Pytanie pasuje do obu albo do żadnej: jedno pytanie a/b z rekomendacją, potem jedna gałąź.

Gotowe, gdy mapa skończyła się wskazaniem skilla albo miejsca w dokumentacji, a onboarding przekazał rozmowę do
`tf-brand`, zakończył się udanym `brand:import` albo user świadomie odłożył styl.
