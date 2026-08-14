#!/usr/bin/env bash
set -euo pipefail

SWAPFILE="/swapfile"
SIZE="16G"

if [[ ${EUID} -ne 0 ]]; then
  echo "Bitte mit sudo ausführen: sudo bash $0" >&2
  exit 1
fi

echo "== Filesystem =="
findmnt -no FSTYPE /
df -h /

if swapon --show=NAME --noheadings | grep -qx "$SWAPFILE"; then
  echo "$SWAPFILE ist bereits aktiv."
  swapon --show
  exit 0
fi

if [[ -e "$SWAPFILE" ]]; then
  echo "$SWAPFILE existiert bereits, ist aber nicht aktiv. Breche sicherheitshalber ab." >&2
  exit 2
fi

fallocate -l "$SIZE" "$SWAPFILE"
chmod 600 "$SWAPFILE"
mkswap "$SWAPFILE"
swapon "$SWAPFILE"

if ! grep -qE '^/swapfile[[:space:]]' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

cat > /etc/sysctl.d/99-shadowops-swap.conf <<'SYSCTL'
vm.swappiness=10
SYSCTL

sysctl --system >/dev/null

echo "== Swap aktiv =="
free -h
swapon --show
