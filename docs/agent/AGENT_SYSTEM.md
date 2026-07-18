# Repository Agent System

Status: 2026-07-18
Repository: `DonMassa84/shadowops-knowledge`
Class: `SANITIZED_KNOWLEDGE`

## Purpose

This repository is a sanitized GitHub projection of a local-first system. The local Agent State Hub and DokumentenSystem remain the control plane and source of operational truth.

## Layer boundaries

- Local: private documents, evidence, logs, agent state and runtime data.
- GitHub: source code, tests, public documentation and reviewable portfolio artifacts.
- Hugging Face: synthetic demos only when explicitly mapped in `.repo-agent.yaml`.

## Guardrails

- No tokens, credentials or secrets.
- No private PDFs, emails, screenshots, account statements or authority documents.
- No absolute machine-specific paths in tracked output.
- No raw local agent memory, sessions or logs.
- No automatic push, release, upload, message or webhook from the local status synchronizer.
- Repository changes use a review branch and pull request.
- Hugging Face exports are allowlisted and synthetic.

## Working sequence

1. Read `.repo-agent.yaml` and the local status dashboard.
2. Isolate one repository task.
3. Make a small, reviewable change.
4. Run `bash scripts/repo-agent-check.sh`.
5. Review the diff and generated artifacts.
6. Commit to a branch and open a pull request.
7. Publish or release only after human review.

## Local snapshot

Run `bash scripts/repo-agent-snapshot.sh`. Snapshots are written below `.local/` and must not be committed.

## Repository-specific boundary

Curated public knowledge only; operational evidence and logs stay local.
