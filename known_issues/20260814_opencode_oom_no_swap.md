# Known Issue: OpenCode durch globalen OOM-Killer beendet

Datum: 2026-08-14
Host: schattenmacher-D3161-B1
Status: BESTÄTIGT
Schweregrad: HOCH

## Symptom

Mehrere OpenCode-Sitzungen wurden ohne regulären Abschluss beendet.

## Primärursache

Der Linux-Kernel hat OpenCode wegen globalem Speichermangel beendet. Zum Zeitpunkt der Diagnose war kein Swap konfiguriert.

Bestätigte Kernel-Ereignisse:

- 23:03:54: `Out of memory: Killed process 1632665 (opencode)`, anon-rss ca. 3.67 GiB
- 23:07:36: `Out of memory: Killed process 1688462 (opencode)`, anon-rss ca. 3.68 GiB
- 23:09:59: `Out of memory: Killed process 1692300 (opencode)`, anon-rss ca. 3.33 GiB

## RAM-Zustand bei Diagnose

- Physischer RAM: 31 GiB
- benutzt: ca. 27 GiB
- frei: ca. 230 MiB
- verfügbar: ca. 3.7 GiB
- Swap: 0 B

## Größte bekannte Verbraucher

- `kali-2026`: 8 GiB Gast-RAM konfiguriert; Host-RSS bei Diagnose ca. 5 GiB
- aktive OpenCode-Sitzung: ca. 3.6 GiB RSS
- Ollama-Server: ca. 2.2 GiB RSS
- zusätzliche Ollama-Runner
- Browser/Renderer, Firefox
- Open WebUI und Flowise
- mehrere alte `opencode run --format json # Autolearn Review` Prozesse
- zugehörige MCP-Prozesse (`git`, `fetch`, `time`)

## Sekundärursache: Autolearn-Prozessleck

Mehrere Autolearn-Review-Prozesse liefen seit Stunden weiter, obwohl sie als kurzlebige Exit-Reviews gedacht sind. Jeder Review startet weitere MCP-Prozesse. Dadurch akkumulieren Prozesszahl und RAM-Verbrauch.

Das Problem ist deshalb nicht nur ein großer Prompt. Auch kleine neue OpenCode-Sitzungen können sterben, sobald globaler Speicherdruck entsteht.

## Sofortmaßnahmen

1. Festhängende Autolearn-Reviews kontrolliert mit SIGTERM beenden.
2. Nur veraltete/entbehrliche OpenCode-Sitzungen beenden; kein pauschales `killall opencode`.
3. 16 GiB Swap einrichten, sofern Root-Dateisystem und freier Speicher dies erlauben.
4. RAM und Swap erneut prüfen.
5. Erst anschließend neue parallele OpenCode-Sitzungen starten.

## Dauerhafte Maßnahmen

- Autolearn-Runner mit Single-Instance/Lock absichern.
- Timeout pro Review erzwingen.
- Kind-/MCP-Prozesse beim Exit zuverlässig terminieren.
- OpenCode-/Autolearn-Parallelität begrenzen.
- Swap dauerhaft aktivieren.
- Kali-VM im Standardbetrieb auf 4 GiB prüfen.
- Auto-Shutdown erst nach OOM-Stabilisierung produktiv aktivieren.

## Datenschutz

Der rohe `ps`-Dump wurde bewusst nicht veröffentlicht, weil darin Autolearn-/Chat-Inhalte enthalten waren.

## Recovery-Ergebnis 2026-08-14 23:23

Die ursprüngliche Annahme, dass ein neuer 16-GiB-Swap angelegt werden müsse, wurde nach Prüfung präzisiert.

Vorhanden war bereits:

- `/swapfile`
- Größe: 8 GiB
- Typ: gültige Linux-Swap-Datei
- Berechtigungen: `600`
- Eigentümer: `root:root`
- war zunächst nicht aktiviert
- war zunächst nicht in `/etc/fstab` eingetragen

Durchgeführt:

- vorhandenen Swap mit `swapon /swapfile` aktiviert
- `/swapfile none swap sw 0 0` in `/etc/fstab` eingetragen
- `vm.swappiness=10` bestätigt

Ergebnis:

- 31 GiB physischer RAM
- 8 GiB aktiver Swap
- ca. 15 GiB RAM verfügbar
- Swap aktiv und reboot-persistent
- akutes OOM-Risiko deutlich reduziert

Der vorhandene 8-GiB-Swap wird zunächst beibehalten. Eine Erweiterung auf 16 GiB ist aktuell nicht notwendig.
