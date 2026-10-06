#!/usr/bin/env bash
# windows/scripts/restore.sh
# Cryo restore script — deploys service configs from the repo onto a fresh Windows install.
# Safe to run multiple times (idempotent).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

APPDATA_LOCAL="${LOCALAPPDATA:-/c/Users/mayan/AppData/Local}"
USERPROFILE_POSIX="${USERPROFILE:-/c/Users/mayan}"

HERMES_DEST="$(cygpath -u "${APPDATA_LOCAL}/hermes")"
OMP_DEST="$(cygpath -u "${USERPROFILE_POSIX}/.omp/agent")"
SUPERMEM_DEST="$(cygpath -u "${USERPROFILE_POSIX}/.supermemory")"

HERMES_SRC="${REPO_ROOT}/windows/hermes"
OMP_SRC="${REPO_ROOT}/windows/omniroute"
SUPERMEM_SRC="${REPO_ROOT}/windows/supermemory"

log() { echo "[cryo/restore] $*"; }
die() { echo "[cryo/restore] ERROR: $*" >&2; exit 1; }

cmd_exists() { command -v "$1" &>/dev/null; }

copy_file() {
  local src="$1" dest="$2"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    log "Restored file: $dest"
  else
    log "SKIP (not in repo): $src"
  fi
}

copy_dir() {
  local src="$1" dest="$2"
  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    cp -r "$src/." "$dest/"
    log "Restored dir: $dest"
  else
    log "SKIP (not in repo): $src"
  fi
}

# ── Hermes ─────────────────────────────────────────────────────────────────────
log "=== Hermes ==="

if ! cmd_exists hermes; then
  log "hermes not found — installing via npm..."
  if ! cmd_exists npm; then
    die "npm not found. Install Node.js from https://nodejs.org first."
  fi
  npm install -g hermes
  log "hermes installed."
else
  log "hermes already installed: $(hermes --version 2>/dev/null || echo '(version unknown)')"
fi

mkdir -p "${HERMES_DEST}"
copy_file "${HERMES_SRC}/config.yaml" "${HERMES_DEST}/config.yaml"
for dir in skills profiles memories; do
  copy_dir "${HERMES_SRC}/${dir}" "${HERMES_DEST}/${dir}"
done

# ── OmniRoute ─────────────────────────────────────────────────────────────────
log "=== OmniRoute ==="
mkdir -p "${OMP_DEST}"
copy_file "${OMP_SRC}/models.yml" "${OMP_DEST}/models.yml"
copy_file "${OMP_SRC}/config.yml"  "${OMP_DEST}/config.yml"

# ── Supermemory ────────────────────────────────────────────────────────────────
log "=== Supermemory ==="
mkdir -p "${SUPERMEM_DEST}"
copy_file "${SUPERMEM_SRC}/.env" "${SUPERMEM_DEST}/.env"

# ── Autostart registration ─────────────────────────────────────────────────────
log "=== Autostart ==="

# OmniRoute: use the VBScript already present in the Hermes dir
OMNI_VBS_WIN="${APPDATA_LOCAL}\\hermes\\OmniRoute_Start.vbs"

if [[ -f "$(cygpath -u "${OMNI_VBS_WIN}")" ]]; then
  REG_CMD="reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\" \
/v OmniRoute /t REG_SZ /d \"wscript.exe \\\"${OMNI_VBS_WIN}\\\"\" /f"
  cmd.exe /c "${REG_CMD}" && log "OmniRoute autostart registered." \
    || log "WARNING: could not register OmniRoute autostart (may need elevation)."
else
  log "SKIP OmniRoute autostart: VBScript not found at ${OMNI_VBS_WIN}."
  log "  Run autostart-setup.sh to create it, or download OmniRoute first."
fi

# Supermemory: delegate to autostart-setup.sh if present
AUTOSTART_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/autostart-setup.sh"
if [[ -f "${AUTOSTART_SCRIPT}" ]]; then
  bash "${AUTOSTART_SCRIPT}"
else
  log "SKIP Supermemory autostart: autostart-setup.sh not found."
fi

# ── Manual steps reminder ──────────────────────────────────────────────────────
cat <<'EOF'

━━━━━━━━━━━━━━━ NEXT STEPS (manual) ━━━━━━━━━━━━━━━

1. OmniRoute binary
   Download and place the omp binary in:
     %LOCALAPPDATA%\omp\
   Then ensure it is in your PATH or update OmniRoute_Start.vbs.

2. Supermemory binary
   Download and place the supermemory binary / folder in:
     %LOCALAPPDATA%\supermemory\   (or wherever supermemory expects)
   Then start it manually once to verify: supermemory start

3. Edit secrets
   Replace all placeholder values (YOUR_KEY_HERE, your@email.com, etc.)
   in:
     %LOCALAPPDATA%\hermes\config.yaml
     %USERPROFILE%\.omp\agent\models.yml
     %USERPROFILE%\.supermemory\.env

4. Reboot or log off/on for autostart entries to take effect.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
