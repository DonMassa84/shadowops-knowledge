# Security Policy

## Local-first boundary

`DonMassa84/shadowops-knowledge` contains only sanitized source code and documentation. Private operational evidence remains local.

## Never commit

- passwords, API keys, access tokens or credentials
- private PDFs, emails, screenshots or message archives
- identity, authority, housing, finance or health documents
- raw local agent state, sessions, logs or vector databases
- absolute local filesystem paths
- unsanitized training data or USB contents

## Hugging Face

Only dedicated synthetic exports may be uploaded. A fine-grained token must be limited to the intended repository and must never be stored in Git, documentation, logs or shell history.

## Required check

Before publishing or opening a release:

```bash
bash scripts/repo-agent-check.sh
git diff --check
git status --short
```

Human review is required before every external publication.
