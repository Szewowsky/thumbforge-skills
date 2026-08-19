#!/usr/bin/env bash
# Re-kopiuje 9 skilli z repo thumbforge do tego marketplace, żeby nie driftowały.
# Źródło prawdy = .claude/skills/ w repo thumbforge; ten plugin to tylko opakowanie do dystrybucji.
# Użycie: ./sync.sh [/ścieżka/do/repo/thumbforge]   (domyślnie: siblingowe ../thumbforge)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-$HERE/../thumbforge}/.claude/skills"
DEST="$(cd "$(dirname "$0")" && pwd)/plugins/thumbforge/skills"
# Lista jest ZAMKNIĘTA i pilnowana niżej. tf-brand celowo poza paczką: brand:analyze
# i brand:import nie mają endpointu HTTP, więc cienki klient ich nie zna i skill
# padłby u kupującego. Dodaj go tu dopiero po wystawieniu brand:* w cienkim kliencie
# (.scratch/brand-thin-client/spec.md).
SKILLS=(tf-generate tf-reverse tf-scenario tf-titles tf-preset tf-assets tf-brainstorm tf-edit thumbforge)

[ -d "$SRC" ] || { echo "Brak źródła: $SRC" >&2; exit 1; }

for s in "${SKILLS[@]}"; do
  [ -d "$SRC/$s" ] || { echo "Brak skilla w źródle: $s" >&2; exit 1; }
  rm -rf "${DEST:?}/$s"
  cp -R "$SRC/$s" "$DEST/$s"
  echo "synced: $s"
done

# Strażnik cross-referencji: tf-* linkują ../thumbforge/references/* — musi się rozwiązywać.
test -f "$DEST/tf-generate/../thumbforge/references/paid-call-protocol.md" \
  || { echo "ZŁAMANY cross-ref ../thumbforge/references/" >&2; exit 1; }
echo "OK — cross-ref ../thumbforge/references/ rozwiązuje się."

# Strażnik kompletności: żaden katalog w paczce nie może być spoza listy (i odwrotnie).
# Osierocony katalog = skill, który został po zmianie listy i mimo to trafi do kupującego.
found=$(find "$DEST" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | tr '\n' ' ')
want=$(printf '%s\n' "${SKILLS[@]}" | sort | tr '\n' ' ')
[ "$found" = "$want" ] || {
  echo "ROZJAZD paczki:" >&2
  echo "  w paczce: $found" >&2
  echo "  na liście: $want" >&2
  exit 1
}
echo "OK - paczka zawiera dokładnie ${#SKILLS[@]} skilli z listy."

# Cache Claude Code jest per-wersja: bez bumpu użytkownik z zainstalowaną paczką NIE dostanie
# tych zmian przez `plugin update` (beta.50: sync bez bumpu nie dotarł do nikogo).
echo
echo "PAMIĘTAJ: bump \"version\" w plugins/thumbforge/.claude-plugin/plugin.json,"
echo "inaczej te zmiany nie dotrą do nikogo, kto ma paczkę już zainstalowaną."
