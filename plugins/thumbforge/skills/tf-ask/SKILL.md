---
name: tf-ask
description: >-
  Skill map for thumbforge. Use when the user asks how the app or its skills
  work.
argument-hint: "[pytanie o aplikację albo skill]"
allowed-tools: Bash, Read
---

# tf-ask

Mapa: potrzeba -> skill albo dokument. Sama niczego nie konfiguruje i jest darmowa; płatny krok zaczyna się dopiero
w skillu docelowym, pod jego protokołem.

Zanim powiesz, co skill robi, albo doradzisz pominięcie kroku, przeczytaj jego `SKILL.md`: streszczenia w Routingu
służą orientacji.

## NOT for

- Zadanie z jasną intencją: idź prosto do skilla, np. miniatura z tematu -> `tf-generate`, klon cudzej -> `tf-reverse`.
- Ustawienie profilu i stylu kanału -> `tf-onboarding`.
- Pomysł na jedną konkretną miniaturę -> `tf-brainstorm`.

## Step 0 - Bootstrap thin-first

Uruchom `thumbforge --help` (bezpłatne). Jeśli zawiedzie: „Uruchom aplikację Thumbforge; CLI instaluje się samo, a w razie potrzeby użyj tray -> Zainstaluj CLI.”
Następnie zastosuj wspólny [kontrakt Bootstrap thin-first](../thumbforge/SKILL.md#step-0--bootstrap-thin-first).
Stan konta (licencja, presety, style, modele, referencje) czytasz przez `thumbforge inventory`. Które komendy ma
cienki klient, a które są repo/dev-only, mówi [sekcja routera](../thumbforge/SKILL.md#cienki-klient-tester-i-tryb-dev).
Bez działającej aplikacji odpowiadasz z plików skilli i dodajesz komunikat o uruchomieniu aplikacji.

## Źródła prawdy

| Pytanie | Źródło |
|---|---|
| Która potrzeba -> który skill | [Routing routera](../thumbforge/SKILL.md#routing) |
| Dwa skille pasują | `description` i „NOT for” w `../<skill>/SKILL.md` obu kandydatów |
| Co skill dostaje na wejściu | `argument-hint` w jego `SKILL.md` |
| Skill płatny czy darmowy | `../<skill>/SKILL.md`: zamek `THUMBFORGE_ALLOW_PAID_CALLS=1` w treści = płatny krok pod zgodą usera, brak = darmowy |
| Komenda: płatna czy darmowa, cel, skill | kolumna „Paid?” w [Command catalog](../thumbforge/SKILL.md#command-catalog); flagi: `thumbforge <komenda> --help` |
| Skład pakietu, instalacja, aktualizacja | katalogi skilli obok `tf-ask` (`../`); README paczki: https://github.com/Szewowsky/thumbforge-skills |
| Błąd komendy albo aplikacji | [troubleshooting](../thumbforge/references/troubleshooting.md) |

## Kroki

1. Nazwij potrzebę jednym zdaniem: co ma powstać albo co ma się zmienić.
2. Dopasuj ją do linii Routingu. Przy dwóch kandydatach przeczytaj ich „NOT for”; przy braku dopasowania powiedz
   wprost, że pakiet tego nie robi.
3. Pytanie o samą aplikację (klucze, profile, licencja, modele): stan z `thumbforge inventory`; klucze ustawia się
   w Ustawieniach aplikacji, profile w przełączniku profilu w panelu bocznym. Pytanie z konkretnym zadaniem: przejdź
   do skilla docelowego w tej rozmowie po odpowiedzi z kroku 5; skille wywoływane ręcznie (Routing) tylko proponujesz.
4. Ustal [Stan onboardingu](#stan-onboardingu).
5. Odpowiedz: skill (`/tf-…`), jedno zdanie dlaczego, płatny czy darmowy, czego potrzebuje na wejściu. Zakończ
   według wyniku reguły: **nieukończony** -> jedno zdanie z propozycją `/tf-onboarding` (profil i styl kanału),
   wybór należy do usera; **nieodczytany** -> komunikat albo cytat błędu i zdanie, że stanu profilu nie odczytano;
   **ukończony** -> bez dopisku.
   Gotowe, gdy ostatnia linia wskazuje skill, miejsce w dokumentacji, propozycję `/tf-onboarding` albo nieodczytany
   stan.

## Stan onboardingu

Jedyna definicja tej reguły; router i `tf-onboarding` stosują ją przez link. Komendy są darmowe i niczego nie
zapisują. Wynik daje fraza w połączonym wyjściu (stdout + stderr); kod wyjścia nie jest ani wynikiem, ani awarią.

1. `thumbforge profile:current`
   - `Brak aktywnego profilu.` (stdout, kod 0) -> **nieukończony**.
   - `kanał <id> <nazwa>` albo `seria <id> <nazwa> parent=<id rodzica>` (stdout, kod 0) -> krok 2.
2. `thumbforge brand:analyze --file sonda-a.png --file sonda-b.png`, bez `--confirm`: dry-run, plików nie czyta,
   więc nazwy nie muszą istnieć.
   - `ma już design system` (stderr, kod 1) -> **ukończony**.
   - `DRY-RUN - brand:analyze` (stdout, kod 0) -> profil bez własnego designu: kanał **nieukończony**, seria krok 3.
3. Seria: ta sama komenda z `--profile <id rodzica>`. Seria dziedziczy design kanału: `ma już design system`
   -> **ukończony**, `DRY-RUN - brand:analyze` -> **nieukończony**.

**Ukończony = profil istnieje ORAZ (sonda profilu ALBO, dla serii, sonda rodzica) zwraca `ma już design system`.**
Gdy nie jest ukończony, rozstrzyga wyjście komend:

- **nieodczytany**: któraś komenda nie wydrukowała żadnej z fraz kroków 1-3, więc stanu nie znamy. Przykłady:
  aplikacja wyłączona (`Thumbforge się uruchamia`), błąd przed kontrolą designu (`Analyzer … jest niedostępny`,
  `Brak aktywnej Licencji`, `Nie znaleziono profilu.`). Design mógł już istnieć; regułę powtarzasz po usunięciu
  przyczyny.
- **nieukończony**: w pozostałych przypadkach, czyli brak profilu albo `DRY-RUN - brand:analyze` u kanału i, dla
  serii, u rodzica.
