# Thumbforge — skille Claude Code (marketplace)

Pakiet skilli do sterowania **Thumbforge** (generator miniatur YouTube) z poziomu
czatu Claude Code. Skille operują **cienkim klientem CLI** zaszytym w apce — nie
potrzebujesz kopii repozytorium.

## Wymaganie wstępne (zrób to PIERWSZE)

Skille wołają komendę `thumbforge`. Żeby ją mieć:

1. Zainstaluj apkę **Thumbforge** z `.dmg` (przeciągnij do `Applications`) i uruchom ją.
2. Wpisz swoje klucze API (OpenAI / Google) w **Ustawieniach** apki — klucze zostają
   na Twoim dysku (BYOK).
3. Z menu **tray** (ikona „tf" na pasku) wybierz **„Zainstaluj CLI"** — to podłoży
   komendę `thumbforge` w terminalu.
4. Sprawdź: `thumbforge --help` powinno coś wypisać. Apka musi **działać w tle**
   (tray) podczas używania skilli — CLI gada z nią po lokalnym HTTP (handshake
   `port`+`token` w `userData`).

Bez tego skille zgłoszą, że nie znajdują serwera.

## Instalacja skilli

W Claude Code:

```
/plugin marketplace add Szewowsky/thumbforge-skills
/plugin install thumbforge@thumbforge-skills
```

(Do lokalnego testu przed publikacją: `/plugin marketplace add /ścieżka/do/thumbforge-skills`.)

## Co dostajesz (9 skilli)

| Skill | Po co | Płatne? |
|-------|-------|---------|
| `thumbforge` | Router + wspólny protokół płatnych callów + katalog komend | — |
| `tf-generate` | Miniatury z tematu + presetu | tak (po Twojej zgodzie) |
| `tf-reverse` | Sklonuj/zaadaptuj cudzą miniaturę (URL/obraz) | tak |
| `tf-scenario` | Koncepty miniatur ze scenariusza/transkryptu | tak (sama generacja) |
| `tf-titles` | Porównaj 1–3 tytuły i przygotuj koncepty miniatur | tak (po Twojej zgodzie) |
| `tf-brainstorm` | Wymyśl oryginalny koncept od zera (Swobodny prompt) | tak (po Twojej zgodzie) |
| `tf-edit` | Popraw gotową miniaturę instrukcją tekstową | tak (po Twojej zgodzie) |
| `tf-preset` | Autoring presetów i stylów (fork archetypu) | nie (pliki/SQLite) |
| `tf-assets` | Przeglądaj i dodawaj referencje (twarz, ikony, inspiracje) | nie |

**Protokół płatny:** skille zawsze robią dry-run i pokazują plan + koszt, a płatny
call odpalają **dopiero po Twojej jawnej zgodzie** dla każdego wywołania.

## Znana chropowatość bety

Kilka komend deweloperskich (`refs:contact-sheet`, `refs:rethumb`, `preset:preview`,
`list-models`) jest **repo/dev-only** — cienki klient zwraca dla nich czytelny
fail-fast. Skille są tego świadome i kierują Cię na thin-owe odpowiedniki
(`thumbforge inventory` zamiast `list-models` itd.).

## Co nowego w 0.1.10

- `/tf-edit` korzysta z `thumbforge edit` w cienkim kliencie: dry-run i
  negative-lock są darmowe, a realny edit idzie do uruchomionej apki i wymaga
  `--guide <annotation-doc.json>` + `--out <absDir>` + zgody na paid call.

## Utrzymanie (dla autora)

Źródło prawdy skilli to `.claude/skills/` w repo `thumbforge`. Ten marketplace to
opakowanie do dystrybucji. Po zmianie skilli w repo odśwież je tutaj:

```
./sync.sh                       # domyślnie z /Users/robert/Windsurf Projekty/thumbforge
./sync.sh /inna/ścieżka/thumbforge
```

Skrypt re-kopiuje 9 skilli i weryfikuje, że cross-ref `../thumbforge/references/`
się rozwiązuje. Potem commit + push.
