# i7 On-Demand Power Policy

## Feste Regel

Der i7-Server (`shadowserver`) ist standardmäßig **AUS** und läuft nur, wenn er gebraucht wird.

1. Start bei Bedarf per **Wake-on-LAN** (`i7-on`).
2. Während echter Arbeit bleibt er eingeschaltet.
3. Nach **60 Minuten** echter Inaktivität fährt er automatisch sauber herunter.
4. Niemals während laufender Jobs ausschalten.

## Systemdaten

- Host: `shadowserver` (FUJITSU D3161-B1, Ubuntu 24.04 LTS, i7-3770)
- Interface: `enp0s25`
- MAC: `00:19:99:f0:a6:7f`
- IP: `10.42.0.44` (USB-Tether 10.42.0.0/24)
- Wake-on-LAN: unterstützt (`Supports Wake-on: pumbg`), aktiviert (`wol g`)

## Wake-on-LAN

- `ethtool -s enp0s25 wol g` aktiviert WOL.
- Persistenz: `i7-wol.service` (systemd, aktiviert bei jedem Boot).
- Magic Packet wird vom Ryzen-Client via Python3-socket gesendet (kein externes WOL-Tool nötig).

### Client (Ryzen-Hauptrechner)

- `i7-on` - WOL-Packet senden, bis zu 120 s auf Erreichbarkeit warten
- `i7-status` - zeigt ONLINE oder AUS/OFFLINE
- Konfiguration: `~/.config/i7-ondemand.conf` (MAC, IP, Timeout)

## Idle-Guard

- Skript: `/usr/local/sbin/i7-idle-guard`
- Konfiguration: `/etc/default/i7-idle-guard`

| Parameter | Wert |
|-----------|------|
| IDLE_MINUTES | 60 |
| LOAD_MAX | 2.0 |
| DRY_RUN | 0 (produktiv) |

### Idle-Logik

- Erster IDLE-Check schreibt Zeitstempel nach `/run/i7-idle-since`.
- BUSY löscht `/run/i7-idle-since`.
- Shutdown erst nach durchgehend 60 Min IDLE.
- Vor Shutdown: 30 s warten, kompletter BUSY-Check erneut - bei BUSY Abbruch.

### Shutdown-blockierende Bedingungen (BUSY)

- `/run/i7-keepawake` existiert
- aktive SSH-Session (eingehend Port 22)
- laufende libvirt/KVM-VM
- OpenCode / `opencode run`
- Whisper/faster-whisper, ffmpeg, OCRmyPDF/Tesseract
- rsync/rclone/scp/sftp (echte Übertragungen)
- apt/dpkg, git clone/fetch/pull/push, pytest/make/ninja
- aktiver Ollama-Runner
- System-Load > 2.0

### Keine Keep-Alive-Wirkung (permanente Daemons)

`ollama serve`, Open WebUI, Flowise, ausgehende autossh-/SFTP-Tunnel.

## Keep-Awake-Kommandos (auf dem i7)

- `i7-keepawake` -> Ausgabe: `i7 Auto-Shutdown blockiert`
- `i7-auto` -> Ausgabe: `i7 Auto-Shutdown wieder aktiv`

## Systemd Units

| Unit | Typ | Zustand |
|------|-----|---------|
| `i7-wol.service` | oneshot | active (enabled) |
| `i7-idle-guard.service` | oneshot | triggered vom Timer |
| `i7-idle-guard.timer` | timer | active (enabled) |

Timer: erster Check 10 Min nach Boot, danach alle 10 Min. Logging ausschließlich via journald (`-t i7-idle-guard`, `STATUS=BUSY/IDLE/SHUTDOWN`).

## Testresultate

- Syntaxprüfung aller Shell-Dateien: OK
- `systemd-analyze verify` (3 Units): OK
- WOL-Service: active/enabled
- Timer: active/enabled
- keepawake => `STATUS=BUSY REASON=keepawake`
- aktive SSH-Session => `STATUS=BUSY REASON=ssh`
- IDLE first-check => Marker wird gesetzt
- BUSY => Marker wird gelöscht
- IDLE >= Threshold => `STATUS=SHUTDOWN` (im DRY_RUN getestet, kein echtes Poweroff)

## Hinweise / bekannte Fallstricke

- Naiver `pgrep -f 'scp|sftp'` matcht auch permanente Tunnel (z. B. `shadowmedia sftp`) - Check wurde auf echte Transfers (`sftp-server`, `scp -[tf]`) präzisiert.
- `ss -tn state established` hat keine State-Spalte; Busy-Check prüft Spalte 3 (lokale Adresse) auf `:22`.
- Falls Wake-on-LAN nicht startet: BIOS/UEFI des i7 aktivieren (Wake on LAN / Power On by PCI-E).