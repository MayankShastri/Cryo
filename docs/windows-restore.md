# Windows Service Restore Guide

Step-by-step recovery from a fresh Windows 11 install — restores Hermes, OmniRoute, and Supermemory.

## Prerequisites

Install these before running Cryo scripts:

| Tool | Where |
|---|---|
| Git Bash | https://git-scm.com/downloads |
| Node.js LTS | https://nodejs.org |
| Git | bundled with Git Bash |

---

## 1 — Clone the Cryo repository

```bash
# Open Git Bash
git clone https://github.com/TheHunter171/Cryo.git ~/Documents/Cryo
# Or with SSH:
git clone git@github.com:TheHunter171/Cryo.git ~/Documents/Cryo
```

---

## 2 — Get the OmniRoute binary

OmniRoute is not stored in the repo (binary too large).

1. Download `omp.exe` from your usual source.
2. Place it at: `%LOCALAPPDATA%\omp\omp.exe`
   - In Git Bash: `/c/Users/mayan/AppData/Local/omp/omp.exe`

---

## 3 — Get the Supermemory binary

Supermemory's binary is also excluded from the repo.

1. Download `supermemory-server.exe`.
2. Place it at: `%USERPROFILE%\.supermemory\bin\supermemory-server.exe`
   - In Git Bash: `/c/Users/mayan/.supermemory/bin/supermemory-server.exe`

---

## 4 — Run the restore script

```bash
cd ~/Documents/Cryo
bash windows/scripts/restore.sh
```

This script:
- Installs Hermes via npm if missing
- Copies `config.yaml`, `skills/`, `profiles/`, `memories/` → `%LOCALAPPDATA%\hermes\`
- Copies `models.yml`, `config.yml` → `%USERPROFILE%\.omp\agent\`
- Copies `.env` → `%USERPROFILE%\.supermemory\.env`
- Runs `autostart-setup.sh` to create VBScript launchers and register them in HKCU Run

---

## 5 — Fill in secrets

Edit these files and replace all `YOUR_*` placeholders:

```
%LOCALAPPDATA%\hermes\config.yaml      → api_key, home_channel
%USERPROFILE%\.omp\agent\models.yml    → (no secrets needed if auth: none)
%USERPROFILE%\.supermemory\.env        → OPENAI_API_KEY
```

---

## 6 — Start services

**OmniRoute** — first run:
```
%LOCALAPPDATA%\omp\omp.exe
```
Verify: open http://localhost:20128 in your browser. Expect a JSON response or status page.

**Supermemory** — first run (from its directory):
```
cd %USERPROFILE%\.supermemory
.\bin\supermemory-server.exe
```
Verify: open http://localhost:6767 in your browser.

**Hermes Agent**:
```bash
hermes start
```
Or use the Hermes desktop launcher if installed.

---

## 7 — Verify autostart

1. Log off → log on (or reboot).
2. Check Task Manager → Details for `omp.exe` and `supermemory-server.exe`.
3. Run a quick health check:

```bash
# OmniRoute
curl -s http://localhost:20128/v1/models | head -5

# Supermemory
curl -s http://localhost:6767/health
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `hermes: command not found` | npm not in PATH | Restart Git Bash after Node install |
| OmniRoute not starting | Wrong binary path in VBS | Edit `OmniRoute_Start.vbs` — update the path |
| Supermemory exits immediately | Missing `.env` | Confirm `.env` is at `%USERPROFILE%\.supermemory\.env` |
| Autostart not working | Registry write failed | Re-run `autostart-setup.sh` as Administrator |
