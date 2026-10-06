# Supermemory & Local Memory Engine Integration

## Architecture & Configuration
Supermemory serves as an external contextual memory and graph engine running locally at `http://localhost:6767` with zero data leakage.

### Integrating with Local OpenAI-Compatible Proxies (OmniRoute)
Supermemory uses OpenAI standard API formatting for its extraction and summarization workers. When routing through a local model aggregator like OmniRoute (`http://localhost:20128`):

In `.supermemory/.env`:
```ini
OPENAI_BASE_URL=http://localhost:20128/v1
OPENAI_API_KEY=sk-...
OPENAI_MODEL=titan-coding-pool
```

### Windows Installation & Platform Detection Pitfall
- **Problem**: Running `npx supermemory local` from environments with Git Bash / MSYS tools present can cause the installer script to report `linux-x64` and install an unexecutable ELF wrapper script in PowerShell.
- **Solution**: Download the Windows native binary directly via PowerShell:
```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.supermemory\bin"
Invoke-WebRequest -Uri "https://github.com/supermemoryai/supermemory/releases/latest/download/supermemory-server-windows-x64.exe" -OutFile "$env:USERPROFILE\.supermemory\bin\supermemory-server.exe"
```

## System Reset & Declarative Environment Management
To prevent anxiety around OS wipes and configuration drift:
1. **Track Config Locations**:
   - Hermes: `AppData/Local/hermes`
   - Supermemory: `~/.supermemory`
   - OmniRoute configs
2. **NixOS WSL Strategy**:
   - Use `nixos-wsl` + `home-manager` with Flakes (e.g., modular flake configurations) to manage development environments, dependencies, and services declaratively in a Git repository.

## Dashboard & Storage Quirks
- **Local Storage Format**: Data is persisted in a local binary SQLite database under `~/.supermemory/data` (not as raw `.md` files). Graph viewing requires the web dashboard at `http://localhost:6767#memory`.
- **Dashboard Dark Mode Workarounds**:
  - The local bundle lacks a native dark-mode switch.
  - *Firefox / Zen Browser*: Use the Dark Reader add-on (`Alt + Shift + D`) configured to allow `localhost`.
  - *Edge / Chrome*: Toggle `#enable-force-dark` in `edge://flags` or `chrome://flags`, or install as a Progressive Web App (PWA).
- **Document & Memory Deletion**:
  - Delete document by ID: `DELETE /v3/documents/{id}`
  - Forget memories by semantic search query: `POST /v4/memories/forget-matching` with `{ "containerTag": "<tag>", "query": "<terms>" }`

