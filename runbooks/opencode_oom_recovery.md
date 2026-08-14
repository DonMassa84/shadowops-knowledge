# Runbook: OpenCode OOM Recovery

## 1. Zustand prüfen

```bash
free -h
swapon --show
ps aux --sort=-%mem | head -25
sudo journalctl -k --since "30 minutes ago" --no-pager \
  | grep -Ei 'oom|out of memory|killed process|kill process'
pgrep -af 'Autolearn Review' || true
pgrep -af '/opencode' || true
```

## 2. Alte Autolearn-Reviews bereinigen

```bash
bash scripts/cleanup_stale_autolearn.sh
```

Das Skript beendet nur Prozesse, deren Kommandozeile `Autolearn Review` enthält. Es verwendet zuerst SIGTERM.

## 3. Swap einrichten

Vorher:

```bash
findmnt -no FSTYPE /
df -h /
swapon --show
```

Bei geeignetem Dateisystem und ausreichend Platz:

```bash
sudo bash scripts/setup_swap_16g.sh
```

## 4. Verifizieren

```bash
free -h
swapon --show
pgrep -af 'Autolearn Review' || true
sudo journalctl -k --since "10 minutes ago" --no-pager \
  | grep -Ei 'oom|out of memory|killed process' || true
```

## 5. Betriebsregel

- Nicht mehrere schwere OpenCode-Instanzen gleichzeitig starten, solange der Autolearn-Leak nicht behoben ist.
- `killall opencode` vermeiden.
- Kali nur mit notwendigem RAM betreiben.
- Auto-Shutdown bis zur Stabilisierung in DRY-RUN lassen.
