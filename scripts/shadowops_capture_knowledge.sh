#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${1:-$HOME/shadowops-knowledge}"
INBOX="$REPO/inbox"
mkdir -p "$INBOX"

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/--+/-/g'
}

read -r -p "Titel: " TITLE
[ -n "${TITLE:-}" ] || { echo "FEHLER: Titel fehlt"; exit 1; }
read -r -p "Typ [learn]: " TYPE
TYPE="${TYPE:-learn}"
read -r -p "Service [openclaw-bot]: " SERVICE
SERVICE="${SERVICE:-openclaw-bot}"
read -r -p "Severity [low]: " SEVERITY
SEVERITY="${SEVERITY:-low}"
read -r -p "Owner [Schattenmacher]: " OWNER
OWNER="${OWNER:-Schattenmacher}"
read -r -p "Tags (kommagetrennt) [knowledge]: " TAGS
TAGS="${TAGS:-knowledge}"
read -r -p "Kontext: " CONTEXT
read -r -p "Was ist passiert?: " WHAT
read -r -p "Reproduktion: " REPRO
read -r -p "Vermutete Ursache: " ROOT
read -r -p "Lösung / Maßnahme: " FIX
read -r -p "Nachweis: " PROOF
read -r -p "Auswirkung: " IMPACT
read -r -p "Nächster Schritt: " NEXT

DATE_NOW="$(date +%F)"
TIME_NOW="$(date +%H:%M)"
SLUG="$(slugify "$TITLE")"
FILE="$INBOX/${DATE_NOW}_${SLUG}.md"

TAGS_JSON="$(printf '%s' "$TAGS" | awk -F',' '
BEGIN { printf "[" }
{
  for (i=1; i<=NF; i++) {
    gsub(/^[ \t]+|[ \t]+$/, "", $i)
    if ($i != "") {
      if (printed++) printf ", "
      printf "\"" $i "\""
    }
  }
}
END { printf "]" }
')"

cat > "$FILE" <<MD
---
title: "$TITLE"
date: "$DATE_NOW"
time: "$TIME_NOW"
status: "draft"
discussion_status: "open"
type: "$TYPE"
service: "$SERVICE"
severity: "$SEVERITY"
owner: "$OWNER"
contributors: []
reviewers: []
gatekeeper: ""
tags: $TAGS_JSON
confidence_level: "low"
verified: false
verified_at: ""
verified_by: ""
promoted_to: ""
review_notes: ""
disputed_points: []
training_value: "low"
export_to_dataset: false
dataset_status: "none"
source_links: []
---

# Kontext
$CONTEXT

# Was ist passiert?
$WHAT

# Reproduktion
$REPRO

# Vermutete Ursache
$ROOT

# Lösung / Maßnahme
$FIX

# Nachweis
$PROOF

# Auswirkung
$IMPACT

# Nächster Schritt
$NEXT
MD

echo "$FILE"
