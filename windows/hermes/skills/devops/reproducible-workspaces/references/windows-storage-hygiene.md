# Windows Storage Hygiene & Safe Cache Reclaim

When maintaining local AI and developer workstations, disk space rapidly degrades due to accumulated package caches, machine learning model checkpoints, virtual disk expansion, and application buffers.

## High-Yield Developer Cache Targets

| Component | Default Path | Clean Method / Command |
| :--- | :--- | :--- |
| **NPM Cache** | `AppData\Local\npm-cache` | Delete directory or `npm cache clean --force` |
| **Pip Wheel Cache** | `AppData\Local\pip\cache` | Delete directory or `pip cache purge` / `uv cache clean` |
| **PNPM Store** | `AppData\Local\pnpm` | Delete directory or `pnpm store prune` |
| **Stremio Buffer** | `AppData\Roaming\stremio\stremio-server\stremio-cache` | Delete cache directory |
| **Roblox Cache** | `AppData\Local\Roblox` | Safe to delete if client can re-download on next launch |
| **Old ML / TTS Models** | `AppData\Local\tts`, `~/.cache/huggingface/hub` | Remove unused model weights (e.g. legacy XTTS checkpoints `model.pth`) |
| **User Temp Files** | `AppData\Local\Temp` | Purge unlocked files (skip active session locks) |
| **Old Installers** | `Downloads\*.exe`, `Downloads\*.msi` | Prune downloaded setup installers (Docker, SEB, IDE setups) |

## Windows Deletion Performance Pitfalls

1. **Avoid Recursive Traversal for Size Calculation**:
   - Running deep `os.walk` or shell `du -sh` across massive directory trees (e.g. `npm-cache`, `node_modules`, `Roblox` with 100k+ tiny files) on Windows NTFS causes severe I/O latency and CLI timeouts (180s+).
   - **Fix**: Perform fast un-enumerated deletions using `shutil.rmtree(path, ignore_errors=True)` or native `rm -rf` directly. Measure overall disk reclamation using `shutil.disk_usage('C:/')` before and after.

2. **WSL2 VHDX Disk Compaction**:
   - Deleting files inside WSL does not automatically shrink the host `ext4.vhdx` container.
   - `wsl --manage <distro> --set-sparse true` is disabled by default on some WSL builds due to potential data corruption without `--allow-unsafe`.
   - Always shut down WSL (`wsl --shutdown`) before performing disk maintenance, and never run unsafe sparse conversions on active critical development distros without user consent.

3. **Strict Preservation Rules**:
   - Never touch game saves or mod profiles (`ModrinthApp`, `saves/`, `DistantHorizons.sqlite`).
   - Never delete digital art working directories (`Clip Studio Paint`, `csp exports`).
   - Never delete media capture and screenshots (`Pictures\Screenshots`, `Videos\NVIDIA`).
   - Retain embedded toolchain cores (`AppData\Local\Arduino15\packages\esp32`) during active project phases.
