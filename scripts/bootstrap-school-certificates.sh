#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="${REPO_DIR:-$HOME/shadowops-knowledge}"
REPO_FULL="${REPO_FULL:-DonMassa84/shadowops-knowledge}"
VAULT_ROOT="${VAULT_ROOT:-$HOME/ShadowOpsVault}"
SCHOOL_ROOT="$VAULT_ROOT/records/education/school"
PUBLIC_ROOT="$REPO_DIR/infrastructure/records/school-certificates"

log(){ printf '\n[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
fail(){ printf '\nERROR: %s\n' "$*" >&2; exit 1; }

log "01/09 Preflight"
command -v git >/dev/null || fail "git fehlt"
if [[ ! -d "$REPO_DIR/.git" ]]; then
  command -v gh >/dev/null || fail "Repo fehlt und gh CLI ist nicht installiert"
  gh auth status >/dev/null 2>&1 || fail "GitHub CLI ist nicht authentifiziert: gh auth login"
  mkdir -p "$(dirname "$REPO_DIR")"
  gh repo clone "$REPO_FULL" "$REPO_DIR"
fi

git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null || fail "Kein Git-Repository: $REPO_DIR"

log "02/09 Privaten Vault anlegen"
umask 077
mkdir -p "$SCHOOL_ROOT"/{source-inbox,manifests,checksums,recommendations}
for n in $(seq -w 1 10); do mkdir -p "$SCHOOL_ROOT/grade-$n"; done
chmod -R go-rwx "$VAULT_ROOT"

cat > "$SCHOOL_ROOT/README.md" <<'MD'
# Private School Certificates Vault

PRIVATE — nicht in öffentliche Repositories committen.

Struktur:
- grade-01 … grade-10: verifizierte Schulzeugnisse
- recommendations: Empfehlungsschreiben
- source-inbox: neu geborgene, noch ungeprüfte Dateien
- manifests: private Metadaten
- checksums: SHA-256-Listen

Workflow: recover -> verify -> normalize filename -> checksum -> archive.
MD

log "03/09 GitHub-Infrastruktur anlegen"
mkdir -p "$PUBLIC_ROOT" "$REPO_DIR/scripts" "$REPO_DIR/.github/workflows"

cat > "$PUBLIC_ROOT/README.md" <<'MD'
# School Certificates Infrastructure

Globale Infrastruktur für Schulzeugnisse und Bildungsnachweise.

## Sicherheitsgrenze

Dieses Repository ist öffentlich. Originalzeugnisse, Scans, PDFs, Bilder, Noten, Geburtsdaten, Adressen, Unterschriften und andere personenbezogene Daten dürfen hier **nicht** gespeichert werden.

GitHub enthält ausschließlich:
- Verzeichnis- und Namenskonventionen
- Schemas und öffentliche Status-Manifeste
- Import-/Archivierungs-Skripte
- CI-Regeln gegen versehentliche Veröffentlichung

Die Originale liegen im privaten Vault:

```text
~/ShadowOpsVault/records/education/school/
├── grade-01/
├── grade-02/
├── grade-03/
├── grade-04/
├── grade-05/
├── grade-06/
├── grade-07/
├── grade-08/
├── grade-09/
├── grade-10/
├── recommendations/
├── source-inbox/
├── manifests/
└── checksums/
```

## Namenskonvention

```text
YYYY[-MM-DD]_school_grade-XX_document-type[_page-NN].ext
```

## Status

- `MISSING` – noch nicht geborgen
- `CANDIDATE` – Kandidat gefunden, Inhalt nicht verifiziert
- `VERIFIED` – Klassenstufe/Jahr am Original bestätigt
- `ARCHIVED` – normalisiert und Prüfsumme erzeugt

## Klasse 1–9

Der öffentliche Status enthält keine Noten, Schulen, Lehrer, Geburtsdaten oder Dokumentinhalte. Die tatsächliche Zuordnung erfolgt ausschließlich anhand der Originaldokumente im privaten Vault.
MD

cat > "$PUBLIC_ROOT/manifest.public.json" <<'JSON'
{
  "schema_version": 1,
  "record_family": "school-certificates",
  "privacy": "public-metadata-only",
  "grades": [
    {"grade": 1, "status": "MISSING"},
    {"grade": 2, "status": "MISSING"},
    {"grade": 3, "status": "MISSING"},
    {"grade": 4, "status": "MISSING"},
    {"grade": 5, "status": "MISSING"},
    {"grade": 6, "status": "MISSING"},
    {"grade": 7, "status": "MISSING"},
    {"grade": 8, "status": "MISSING"},
    {"grade": 9, "status": "MISSING"}
  ]
}
JSON

cat > "$PUBLIC_ROOT/private-manifest.schema.json" <<'JSON'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Private School Certificate Record",
  "type": "object",
  "required": ["record_id", "grade", "status", "private_path"],
  "properties": {
    "record_id": {"type": "string"},
    "grade": {"type": "integer", "minimum": 1, "maximum": 13},
    "school_year": {"type": ["string", "null"]},
    "document_type": {"type": "string"},
    "status": {"enum": ["MISSING", "CANDIDATE", "VERIFIED", "ARCHIVED"]},
    "private_path": {"type": "string"},
    "sha256": {"type": ["string", "null"], "pattern": "^[a-f0-9]{64}$"},
    "source": {"type": ["string", "null"]},
    "verified_at": {"type": ["string", "null"]}
  },
  "additionalProperties": true
}
JSON

log "04/09 Import-Skript installieren"
cat > "$REPO_DIR/scripts/import-school-certificate.sh" <<'SH'
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
SH
chmod +x "$REPO_DIR/scripts/import-school-certificate.sh"

log "05/09 Bootstrap-Skript als Repo-Runbook ablegen"
cp "$0" "$REPO_DIR/scripts/bootstrap-school-certificates.sh" 2>/dev/null || true
chmod +x "$REPO_DIR/scripts/bootstrap-school-certificates.sh" 2>/dev/null || true

log "06/09 Gitignore-Härtung"
GITIGNORE="$REPO_DIR/.gitignore"
touch "$GITIGNORE"
if ! grep -q '^# ShadowOps private records guard$' "$GITIGNORE"; then
cat >> "$GITIGNORE" <<'GI'

# ShadowOps private records guard
/ShadowOpsVault/
/private/
/vault/
/records-private/
/infrastructure/records/school-certificates/private/
infrastructure/records/school-certificates/**/*.pdf
infrastructure/records/school-certificates/**/*.jpg
infrastructure/records/school-certificates/**/*.jpeg
infrastructure/records/school-certificates/**/*.png
infrastructure/records/school-certificates/**/*.tif
infrastructure/records/school-certificates/**/*.tiff
GI
fi

log "07/09 CI-Guard installieren"
cat > "$REPO_DIR/.github/workflows/records-privacy-guard.yml" <<'YAML'
name: Records Privacy Guard

on:
  push:
    paths:
      - 'infrastructure/records/school-certificates/**'
      - 'scripts/import-school-certificate.sh'
      - '.github/workflows/records-privacy-guard.yml'
  pull_request:
    paths:
      - 'infrastructure/records/school-certificates/**'
      - 'scripts/import-school-certificate.sh'
      - '.github/workflows/records-privacy-guard.yml'

permissions:
  contents: read

jobs:
  no-private-records:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Reject certificate binaries in public infrastructure
        shell: bash
        run: |
          set -euo pipefail
          ROOT='infrastructure/records/school-certificates'
          mapfile -t BAD < <(find "$ROOT" -type f \( \
            -iname '*.pdf' -o -iname '*.jpg' -o -iname '*.jpeg' -o \
            -iname '*.png' -o -iname '*.tif' -o -iname '*.tiff' \
          \) -print)
          if ((${#BAD[@]})); then
            printf 'ERROR: private/binary certificate files found in public repo:\n'
            printf ' - %s\n' "${BAD[@]}"
            exit 1
          fi
          echo 'PASS: no certificate binaries committed.'
      - name: Validate public manifest JSON
        run: python -m json.tool infrastructure/records/school-certificates/manifest.public.json >/dev/null
YAML

log "08/09 Lokale Prüfung"
python3 -m json.tool "$PUBLIC_ROOT/manifest.public.json" >/dev/null
python3 -m json.tool "$PUBLIC_ROOT/private-manifest.schema.json" >/dev/null
bash -n "$REPO_DIR/scripts/import-school-certificate.sh"
bash -n "$REPO_DIR/scripts/bootstrap-school-certificates.sh" 2>/dev/null || true

if find "$PUBLIC_ROOT" -type f \( -iname '*.pdf' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.tif' -o -iname '*.tiff' \) | grep -q .; then
  fail "Binäre/private Zeugnisdatei im öffentlichen Infrastrukturpfad gefunden"
fi

log "09/09 Commit + Push"
git -C "$REPO_DIR" pull --ff-only || true
git -C "$REPO_DIR" add \
  .gitignore \
  infrastructure/records/school-certificates \
  scripts/import-school-certificate.sh \
  scripts/bootstrap-school-certificates.sh \
  .github/workflows/records-privacy-guard.yml

if git -C "$REPO_DIR" diff --cached --quiet; then
  echo "Keine Änderungen zu committen."
else
  git -C "$REPO_DIR" diff --cached --name-only
  git -C "$REPO_DIR" commit -m "infra: add global secure school-certificate records system"
  git -C "$REPO_DIR" push origin HEAD
fi

cat <<OUT

============================================================
FERTIG
============================================================
Public control plane:
  $PUBLIC_ROOT

Private originals vault:
  $SCHOOL_ROOT

Import example:
  $REPO_DIR/scripts/import-school-certificate.sh ~/Downloads/zeugnis.jpg 4 1994 certificate

WICHTIG:
  Originalzeugnisse bleiben privat und werden NICHT in das öffentliche Repo gepusht.
============================================================
OUT
