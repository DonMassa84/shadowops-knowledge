# Local System Mapping

| Layer | Identifier | Direction |
|---|---|---|
| Local control plane | `ProofFlow-Obsidian-Vault / Agent State Hub` | status source |
| Local status domain | `DokumentenSystem/11_STATUS_UND_STEUERUNG/knowledge` | status source |
| GitHub | `DonMassa84/shadowops-knowledge` | sanitized code and documentation |
| Hugging Face | `Not mapped` | synthetic export only |

## Synchronization policy

The local system may read repository status and write it to the private dashboard. It must not push, publish, release or trigger external messages automatically.

GitHub content is curated from local work through a privacy gate and pull-request review. Hugging Face content, where mapped, comes only from a dedicated allowlisted export containing synthetic data.

## Forbidden sources

- Obsidian private notes
- Agent sessions and raw logs
- Emails and message archives
- Housing, authority, finance and health documents
- Local credentials and absolute filesystem paths
