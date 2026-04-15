---
id: KI-2026-04-14-001
type: known_issue
title: Shell Heredoc Safety – Vier Fehlerklassen
date: 2026-04-14
project: shadow-command-hub / workflow-engine
status: resolved
severity: high
---

## Problem

1. **Wrapper vor Zieldatei gestartet**
   set -Eeuo pipefail bricht sofort ab wenn die Zieldatei fehlt.
   Regel: Erst Datei schreiben, dann starten.

2. **Verschachtelte Heredocs**
   Bash verliert den Kontext des aeusseren Heredocs.
   Schliessendes Delimiter-Wort wird nicht gefunden, Datei geht bis EOF.
   Regel: Keine verschachtelten Heredocs. Separater Block oder Python-Schreibschritt.

3. **Python f-String mit Path-Division**
   f"{TD/'name'}" parst 'name' als Variablenname => NameError.
   Regel: Kein f-String fuer Path-Objekte in Einzeilern. str()-Konkatenation nutzen.

4. **Ausgabetext ins Terminal kopiert**
   Zeilen wie === WRITTEN FILES === werden als Shell-Befehle interpretiert.
   Regel: Nur Code-Bloecke einfuegen, nie Ausgabetext.

## Fix

Python-Einzeiler mit reiner String-Konkatenation statt f-String.

## Prozessregel

Erst schreiben. Dann pruefen. Dann ausfuehren. Dann Report sichern.

## Referenz

- Template: ~/shadow-command-hub/templates/standard_process_report_template.sh
- Reports: ~/process_reports/
