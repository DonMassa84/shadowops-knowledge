#!/usr/bin/env bash
set -euo pipefail

echo "== Autolearn candidates =="
pgrep -af 'Autolearn Review' || true

mapfile -t pids < <(pgrep -f 'Autolearn Review' || true)

if ((${#pids[@]} == 0)); then
  echo "Keine Autolearn-Review-Prozesse gefunden."
  exit 0
fi

echo "Sende SIGTERM an: ${pids[*]}"
kill -TERM "${pids[@]}" 2>/dev/null || true
sleep 3

echo "== Verbleibende Kandidaten =="
pgrep -af 'Autolearn Review' || echo "keine"

echo "== RAM =="
free -h
