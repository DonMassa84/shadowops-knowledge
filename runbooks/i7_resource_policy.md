# i7 Resource Policy

## Standard

Der i7 wird standardmäßig AUS betrieben und nur bei Bedarf per Wake-on-LAN gestartet.
Sicherheit laufender Jobs hat Vorrang vor Stromersparnis.

## Finale Betriebsregel

- Standardzustand: AUS (stromlos).
- Start: nur bei Bedarf per `i7-on` (Wake-on-LAN) vom Ryzen-Hauptrechner.
- Nach 60 Minuten echter Inaktivität: automatisches sauberes Herunterfahren (systemctl poweroff).
- Laufende Arbeit blockiert das Ausschalten.

## Vor Auto-Shutdown blockierende Workloads (BUSY)

- aktive SSH-Sitzungen (eingehend auf Port 22)
- laufende libvirt/KVM-VMs
- OpenCode (`opencode`, `opencode run`)
- Whisper/faster-whisper
- ffmpeg
- OCRmyPDF/Tesseract
- rsync / rclone / scp / sftp (echte Übertragungen)
- apt/dpkg
- git clone/fetch/pull/push
- pytest/make/ninja
- aktiver Ollama-Runner (Rechenlast)
- System-Load über 2.0
- expliziter Keep-Awake-Lock (`/run/i7-keepawake`)

## Permanente Daemons (kein Keep-Alive-Grund)

- `ollama serve`
- Open WebUI
- Flowise
- autossh-/SFTP-Tunnel (ausgehende Verbindungen)

## Keep-Awake-Kommandos (auf dem i7)

- `i7-keepawake` - Auto-Shutdown blockieren
- `i7-auto` - Auto-Shutdown wieder freigeben

## Aktueller Zustand

- Auto-Shutdown im DRY_RUN-Modus erst nach Beobachtungszeitraum produktiv schalten.
- 8 GiB Swap (Ryzen) bzw. 4 GiB Swap (i7) aktiv.