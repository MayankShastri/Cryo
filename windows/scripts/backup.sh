#!/usr/bin/env bash
# windows/scripts/backup.sh
# Cryo backup script — copies service configs into the repo and commits.
# Safe to run multiple times (idempotent).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# ── Source paths (Windows → POSIX via Git Bash) ───────────────────────────────
APPDATA_LOCAL="${LOCALAPPDATA:-/c/Users/mayan/AppData/Local}"
USERPROFILE_POSIX="${USERPROFILE:-/c/Users/mayan}"

HERMES_SRC="$(cygpath -u "${APPDATA_LOCAL}/hermes")"
OMP_SRC="$(cygpath -u "${USERPROFILE_POSIX}/.omp/agent")"
SUPERMEM_SRC="$(cygpath -u "${USERPROFILE_POSIX}/.supermemory")"

# ── Destination paths ──────────────────────────────────────────────────────────
HERMES_DEST="${REPO_ROOT}/windows/hermes"
OMP_DEST="${REPO_ROOT}/windows/omniroute"
SUPERMEM_DEST="${REPO_ROOT}/windows/supermemory"

# ── Helpers ────────────────────────────────────────────────────────────────────
log()  { echo "[cryo/backup] $*"; }
die()  { echo "[cryo/backup] ERROR: $*" >&2; exit 1; }

copy_if_exists() {
  local src="$1" dest="$2"
  if [[ -e "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
    log "Copied: $src → $dest"
  else
    log "SKIP (not found): $src"
  fi
}

# ── Hermes ─────────────────────────────────────────────────────────────────────
log "=== Hermes ==="
mkdir -p "${HERMES_DEST}"

copy_if_exists "${HERMES_SRC}/config.yaml"  "${HERMES_DEST}/config.yaml"
# Directories: wipe then copy so deleted upstream files don't linger
for dir in skills profiles memories; do
  if [[ -d "${HERMES_SRC}/${dir}" ]]; then
    rm -rf "${HERMES_DEST}/${dir}"
    cp -r  "${HERMES_SRC}/${dir}" "${HERMES_DEST}/${dir}"
    log "Synced: ${HERMES_SRC}/${dir} → ${HERMES_DEST}/${dir}"
  else
    log "SKIP (not found): ${HERMES_SRC}/${dir}"
  fi
done
# Explicitly excluded: sessions/, state.db (volatile / too large)

# ── OmniRoute ─────────────────────────────────────────────────────────────────
log "=== OmniRoute ==="
mkdir -p "${OMP_DEST}"

for f in models.yml config.yml; do
  copy_if_exists "${OMP_SRC}/${f}" "${OMP_DEST}/${f}"
done

# ── Supermemory ────────────────────────────────────────────────────────────────
log "=== Supermemory ==="
mkdir -p "${SUPERMEM_DEST}"

copy_if_exists "${SUPERMEM_SRC}/.env" "${SUPERMEM_DEST}/.env"

# ── Git commit ─────────────────────────────────────────────────────────────────
cd "${REPO_ROOT}"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  log "Not a git repo — skipping commit."
  exit 0
fi

git add windows/hermes windows/omniroute windows/supermemory

if git diff --cached --quiet; then
  log "Nothing changed — no commit needed."
else
  TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
  git commit -m "cryo: backup ${TIMESTAMP}"
  log "Committed: cryo: backup ${TIMESTAMP}"
fi
