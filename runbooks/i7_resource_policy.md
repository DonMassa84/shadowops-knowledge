# i7 Resource Policy

## Standard

Der i7 wird bedarfsgesteuert betrieben. Sicherheit laufender Jobs hat Vorrang vor Stromersparnis.

## Vor Auto-Shutdown zu blockierende Workloads

- aktive SSH-Sitzungen
- laufende libvirt/KVM-VMs
- OpenCode
- Ollama/Runner
- Whisper/faster-whisper
- ffmpeg
- OCRmyPDF/Tesseract
- rsync/rclone/scp/sftp
- relevante Python-/Shell-Batchjobs
- Backup-/Automation-Jobs
- expliziter Keep-Awake-Lock

## Reihenfolge der Stabilisierung

1. OOM-/Autolearn-Leak beheben.
2. Swap aktivieren und prüfen.
3. Parallelität kontrollieren.
4. Kali-RAM für Normalbetrieb prüfen.
5. Erst dann Auto-Shutdown zunächst im DRY-RUN testen.
6. Produktives Poweroff erst nach fehlerfreiem Beobachtungszeitraum.
