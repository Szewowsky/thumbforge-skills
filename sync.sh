#!/usr/bin/env bash
# Re-kopiuje 6 skilli z repo thumbforge do tego marketplace, żeby nie driftowały.
# Źródło prawdy = .claude/skills/ w repo thumbforge; ten plugin to tylko opakowanie do dystrybucji.
# Użycie: ./sync.sh [/ścieżka/do/repo/thumbforge]
set -euo pipefail

SRC="${1:-/Users/robert/Windsurf Projekty/thumbforge}/.claude/skills"
DEST="$(cd "$(dirname "$0")" && pwd)/plugins/thumbforge/skills"
SKILLS=(tf-generate tf-reverse tf-scenario tf-preset tf-assets thumbforge)

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
