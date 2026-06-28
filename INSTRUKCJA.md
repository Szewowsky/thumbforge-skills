# Thumbforge — jak zacząć (beta) 🎬

Generator miniatur YouTube. Apka działa **lokalnie na Twoim Macu**, a Ty sterujesz nią
z czatu w Claude Code. Twoje klucze i obrazki zostają u Ciebie na dysku.

## Czego potrzebujesz
- Mac z procesorem Apple (M1/M2/M3/…)
- **Claude Code** (zainstalowany)
- Klucz API **OpenAI** lub **Google** (samo generowanie miniatur jest u nich płatne)

---

## Krok 1 — zainstaluj apkę
1. Pobierz instalator `thumbforge-…-arm64.dmg` z naszego **Discorda** (kanał dla beta-testerów)
2. Otwórz go i **przeciągnij** ikonę *thumbforge* na folder **Applications**
3. Uruchom apkę. Za **pierwszym** razem macOS powie „niezidentyfikowany deweloper" —
   wtedy **prawy klik** na ikonie → **Otwórz** → jeszcze raz **Otwórz**
   (to normalne dla bety; zwykły dwuklik za 1. razem nie zadziała)

Apka chowa się w **pasku menu** (ikona „tf" u góry ekranu) i działa w tle.

## Krok 2 — wpisz klucz API
W apce: **Ustawienia** → wpisz klucz **OpenAI** albo **Google** (obok jest link
„skąd wziąć klucz") → **Zapisz**. Klucz jest szyfrowany na Twoim dysku.

## Krok 3 — CLI (instaluje się sam)
Apka sama podłącza komendę `thumbforge` w terminalu. Sprawdź:
```
thumbforge --help
```
Jak coś wypisze — gotowe. Jak „command not found" — kliknij ikonę **tf** w pasku menu →
**„Zainstaluj CLI"**.

## Krok 4 — zainstaluj skille w Claude Code
W terminalu:
```
claude plugin marketplace add Szewowsky/thumbforge-skills
claude plugin install thumbforge@thumbforge-skills
```
(W oknie Claude Code te same komendy działają jako `/plugin marketplace add …` i `/plugin install …`.)
Zrestartuj Claude Code. Powinieneś zobaczyć `/tf-generate` i spółkę po wpisaniu `/tf`.

## Krok 5 — rób miniatury 🎨
**Ważne: apka musi być uruchomiona** (siedzieć w pasku menu) — CLI z nią rozmawia.

W Claude Code (w dowolnym projekcie) napisz po prostu:
> „zrób miniaturę o [Twój temat]"

albo `/tf-generate`. Claude:
1. pokaże **plan i koszt** (za darmo, to dry-run),
2. dopiero po Twoim **potwierdzeniu** wygeneruje obrazek (to jedyny płatny moment — u OpenAI/Google).

Gotowe miniatury lądują na dysku.

---

## Co potrafią skille
| Komenda | Do czego |
|---------|----------|
| `/tf-generate` | miniatura z tematu |
| `/tf-reverse` | skopiuj/zaadaptuj cudzą miniaturę (z linku/obrazka) |
| `/tf-scenario` | miniatury ze scenariusza/transkryptu filmu |
| `/tf-brainstorm` | wymyśl oryginalny koncept od zera (swobodny prompt) |
| `/tf-preset` | własne szablony i style (za darmo) |
| `/tf-assets` | dodaj swoje referencje: twarz, ikony, logo (za darmo) |

## Aktualizacja skilli (gdy wyjdzie nowsza wersja)
```
claude plugin marketplace update thumbforge-skills
claude plugin update thumbforge@thumbforge-skills
```
…i restart Claude Code.

## Coś nie działa?
- **„Nie znaleziono serwera"** przy komendzie → apka nie jest uruchomiona. Odpal ją z Aplikacji.
- **`thumbforge` nie działa w terminalu** → ikona tf w pasku menu → „Zainstaluj CLI".
- **Generowanie nie rusza** → sprawdź klucz API w Ustawieniach apki.

Pytania/feedback: «WSTAW LINK DO DISCORDA» (zaproszenie do kanału beta).
