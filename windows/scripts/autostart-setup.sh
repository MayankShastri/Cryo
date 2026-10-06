#!/usr/bin/env bash
# windows/scripts/autostart-setup.sh
# Creates VBScript background launchers for OmniRoute and Supermemory
# and registers them in the HKCU Run registry key for silent startup on login.
# Safe to run multiple times (idempotent).
set -euo pipefail

APPDATA_LOCAL="${LOCALAPPDATA:-/c/Users/mayan/AppData/Local}"
USERPROFILE_WIN="${USERPROFILE:-C:\\Users\\mayan}"
APPDATA_LOCAL_WIN="$(cygpath -w "${APPDATA_LOCAL}")"
USERPROFILE_POSIX="$(cygpath -u "${USERPROFILE_WIN}")"

log() { echo "[cryo/autostart] $*"; }
die() { echo "[cryo/autostart] ERROR: $*" >&2; exit 1; }

# ── Ensure target directories exist ────────────────────────────────────────────
HERMES_DIR="$(cygpath -u "${APPDATA_LOCAL_WIN}\\hermes")"
SUPERMEM_DIR="${USERPROFILE_POSIX}/.supermemory"

mkdir -p "${HERMES_DIR}"
mkdir -p "${SUPERMEM_DIR}"

# ── 1. Create OmniRoute VBScript launcher ──────────────────────────────────────
# Silent launcher that starts OmniRoute binary in the background (hidden window: 0)
OMNI_VBS_PATH="${HERMES_DIR}/OmniRoute_Start.vbs"
OMNI_VBS_WIN="$(cygpath -w "${OMNI_VBS_PATH}")"
OMP_EXE_WIN="${APPDATA_LOCAL_WIN}\\omp\\omp.exe"

log "Creating OmniRoute VBS launcher at: ${OMNI_VBS_WIN}"
cat <<'EOF' > "${OMNI_VBS_PATH}"
' OmniRoute background launcher (silent start, hidden window)
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Dim appData, ompPath
appData = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%")
ompPath = appData & "\omp\omp.exe"

If fso.FileExists(ompPath) Then
    ' Run hidden (0), do not wait for return (false)
    WshShell.Run """" & ompPath & """", 0, False
End If
EOF

# ── 2. Create Supermemory VBScript launcher ────────────────────────────────────
# Silent launcher that starts supermemory-server binary in the background
SUPERMEM_VBS_PATH="${SUPERMEM_DIR}/Supermemory_Start.vbs"
SUPERMEM_VBS_WIN="$(cygpath -w "${SUPERMEM_VBS_PATH}")"

log "Creating Supermemory VBS launcher at: ${SUPERMEM_VBS_WIN}"
cat <<'EOF' > "${SUPERMEM_VBS_PATH}"
' Supermemory background launcher (silent start, hidden window)
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Dim userProfile, supermemPath
userProfile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
supermemPath = userProfile & "\.supermemory\bin\supermemory-server.exe"

If fso.FileExists(supermemPath) Then
    ' Set working directory to .supermemory so .env is found
    WshShell.CurrentDirectory = userProfile & "\.supermemory"
    ' Run hidden (0), do not wait for return (false)
    WshShell.Run """" & supermemPath & """", 0, False
End If
EOF

# ── 3. Register HKCU Run keys ──────────────────────────────────────────────────
log "Registering HKCU Run autostart entries..."

# OmniRoute
cmd.exe /c "reg add \"HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" /v OmniRoute /t REG_SZ /d \"wscript.exe \\\"${OMNI_VBS_WIN}\\\"\" /f" && \
  log "Registered OmniRoute in HKCU Run" || \
  log "WARNING: Failed to register OmniRoute in HKCU Run"

# Supermemory
cmd.exe /c "reg add \"HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" /v Supermemory /t REG_SZ /d \"wscript.exe \\\"${SUPERMEM_VBS_WIN}\\\"\" /f" && \
  log "Registered Supermemory in HKCU Run" || \
  log "WARNING: Failed to register Supermemory in HKCU Run"

log "Autostart setup complete."
