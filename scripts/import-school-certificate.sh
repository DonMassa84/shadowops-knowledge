#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -ge 3 ]] || { echo "Usage: $0 SOURCE_FILE GRADE YEAR [TYPE]" >&2; exit 2; }
SRC="$1"; GRADE="$2"; YEAR="$3"; TYPE="${4:-certificate}"
[[ -f "$SRC" ]] || { echo "Datei fehlt: $SRC" >&2; exit 1; }
[[ "$GRADE" =~ ^([1-9]|10)$ ]] || { echo "GRADE muss 1-10 sein" >&2; exit 1; }
ROOT="${VAULT_ROOT:-$HOME/ShadowOpsVault}/records/education/school"
printf -v G2 '%02d' "$GRADE"
EXT="${SRC##*.}"; EXT="${EXT,,}"
NAME="${YEAR}_school_grade-${G2}_${TYPE}.${EXT}"
DEST="$ROOT/grade-${G2}/$NAME"
mkdir -p "$(dirname "$DEST")" "$ROOT/checksums" "$ROOT/manifests"
cp -n -- "$SRC" "$DEST"
SHA="$(sha256sum "$DEST" | awk '{print $1}')"
printf '%s  %s\n' "$SHA" "$DEST" >> "$ROOT/checksums/SHA256SUMS.txt"
cat > "$ROOT/manifests/${YEAR}_grade-${G2}_${TYPE}.json" <<JSON
{
  "record_id": "${YEAR}-grade-${G2}-${TYPE}",
  "grade": ${GRADE},
  "school_year": "${YEAR}",
  "document_type": "${TYPE}",
  "status": "ARCHIVED",
  "private_path": "${DEST}",
  "sha256": "${SHA}",
  "source": "manual-import",
  "verified_at": "$(date --iso-8601=seconds)"
}
JSON
chmod go-rwx "$DEST" "$ROOT/manifests/${YEAR}_grade-${G2}_${TYPE}.json" "$ROOT/checksums/SHA256SUMS.txt"
echo "ARCHIVED: $DEST"
echo "SHA256:   $SHA"
