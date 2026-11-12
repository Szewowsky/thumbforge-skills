# Mapa: potrzeba -> skill

## Źródła prawdy

| Pytanie | Źródło |
|---|---|
| Która potrzeba -> który skill | [Routing routera](../../thumbforge/SKILL.md#routing) |
| Dwa skille pasują | `description` i „NOT for” w `../../<skill>/SKILL.md` obu kandydatów |
| Co skill dostaje na wejściu | `argument-hint` w jego `SKILL.md` |
| Skill płatny czy darmowy | `../../<skill>/SKILL.md`: zamek `THUMBFORGE_ALLOW_PAID_CALLS=1` w treści = płatny krok pod zgodą usera, brak = darmowy |
| Komenda: płatna czy darmowa, cel, skill | kolumna „Paid?” w [Command catalog](../../thumbforge/SKILL.md#command-catalog); flagi: `thumbforge <komenda> --help` |
| Skład pakietu, instalacja, aktualizacja | katalogi skilli obok `tf-ask` (`../../`); README paczki: https://github.com/Szewowsky/thumbforge-skills |
| Błąd komendy albo aplikacji | [troubleshooting](../../thumbforge/references/troubleshooting.md) |

## Kroki

1. Nazwij potrzebę jednym zdaniem: co ma powstać albo co ma się zmienić.
2. Dopasuj ją do linii Routingu. Przy dwóch kandydatach przeczytaj ich „NOT for”; przy braku dopasowania powiedz
   wprost, że pakiet tego nie robi.
3. Pytanie o samą aplikację (klucze, profile, licencja, modele): stan z `thumbforge inventory`; klucze ustawia się
   w Ustawieniach aplikacji, profile w przełączniku profilu w panelu bocznym. Pytanie z konkretnym zadaniem: przejdź
   do skilla docelowego w tej rozmowie; skille, które Routing oznacza jako wywoływane ręcznie, tylko proponujesz.
4. Odpowiedz: skill (`/tf-…`), jedno zdanie dlaczego, płatny czy darmowy, czego potrzebuje na wejściu.
   Gotowe, gdy ostatnia linia wskazuje skill albo miejsce w dokumentacji.
