#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

fail=0

section() {
  printf '\n== %s ==\n' "$*"
}

section "Required repository control files"
required=(
  ".repo-agent.yaml"
  "SECURITY.md"
  "docs/agent/AGENT_SYSTEM.md"
  "docs/architecture/LOCAL_SYSTEM_MAPPING.md"
  "scripts/repo-agent-check.sh"
  "scripts/repo-agent-snapshot.sh"
)
for path in "${required[@]}"; do
  if [[ -s "$path" ]]; then
    printf '[OK] %s\n' "$path"
  else
    printf '[FAIL] Missing or empty: %s\n' "$path"
    fail=1
  fi
done

section "Tracked runtime and private paths"
if git ls-files | grep -E '(^|/)(\.venv|venv|node_modules|__pycache__|\.local|secrets|private)(/|$)'; then
  echo "[FAIL] Runtime or private directory is tracked."
  fail=1
else
  echo "[OK] No forbidden runtime/private directories are tracked."
fi

section "Forbidden tracked file names"
credential_files="$(
  git ls-files \
    | grep -Ei '(^|/)(\.env($|\.)|.*credentials.*\.json$|.*token.*\.json$|.*\.kdbx$|.*\.p12$|.*\.pfx$)' \
    | grep -Eiv '(^|/)\.env\.(example|sample|template)$' \
    || true
)"
if [[ -n "$credential_files" ]]; then
  printf '%s\n' "$credential_files"
  echo "[FAIL] Potential credential file is tracked."
  fail=1
else
  echo "[OK] No obvious credential file names are tracked."
fi

section "Shell syntax"
while IFS= read -r script; do
  bash -n "$script" || fail=1
done < <(git ls-files '*.sh')

section "Diff hygiene"
git diff --check || fail=1

section "Secret and local-path scan"
scan_pattern='(sk-[A-Za-z0-9_-]{16,}|ghp_[A-Za-z0-9_]{16,}|github_pat_[A-Za-z0-9_]{16,}|xox[baprs]-[A-Za-z0-9-]{16,}|hf_[A-Za-z0-9]{20,}|/home/[A-Za-z0-9._-]+/|/media/[A-Za-z0-9._-]+/|C:\\Users\\[A-Za-z0-9._-]+\\)'

if git grep -nEI "$scan_pattern" -- . \
  ':(exclude)scripts/repo-agent-check.sh' \
  ':(exclude)package-lock.json' \
  ':(exclude)*.lock'; then
  echo "[FAIL] Review the potential secret or machine-specific path findings above."
  fail=1
else
  echo "[OK] No obvious secrets or machine-specific paths found."
fi

section "External-action boundary"
echo "[OK] This check performs no push, release, upload, webhook or message action."

printf '\n'
if ((fail == 0)); then
  echo "REPO_AGENT_CHECK=PASS"
else
  echo "REPO_AGENT_CHECK=REVIEW_REQUIRED"
fi
exit "$fail"
