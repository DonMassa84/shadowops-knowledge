#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

stamp="$(date +%Y-%m-%d_%H%M%S)"
out=".local/repo-agent/snapshots"
mkdir -p "$out"
target="$out/REPO_SNAPSHOT_$stamp.md"

{
  echo "# Local Repository Snapshot"
  echo
  echo "Generated: $stamp"
  echo
  echo "## Branch"
  echo
  git branch --show-current || true
  echo
  echo "## Status"
  echo
  git status --short || true
  echo
  echo "## Recent commits"
  echo
  git log --oneline -5 2>/dev/null || true
  echo
  echo "## Agent check"
  echo
  if bash scripts/repo-agent-check.sh; then
    echo "PASS"
  else
    echo "REVIEW_REQUIRED"
  fi
} > "$target"

chmod 600 "$target"
echo "SNAPSHOT=$target"
