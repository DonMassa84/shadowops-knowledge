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
