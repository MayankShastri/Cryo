# Supermemory Local Setup & Troubleshooting Guide

## Overview
Supermemory provides a self-hosted memory and context graph engine (`supermemory-server`) running by default on `http://localhost:6767`.

## Windows Installation & Pitfalls

### The Platform Detection Trap
When running `npx supermemory local` or `curl -fsSL https://supermemory.ai/install | bash` inside Git Bash or MSYS shells on Windows, the installer script often detects the OS as `linux-x64` via `uname -s` and downloads an ELF binary / bash wrapper to `~/.supermemory/bin/supermemory-server`.
When a user subsequently attempts to execute `supermemory-server` in PowerShell or Windows Command Prompt, Windows fails with `CommandNotFoundException` or cannot execute the script.

### Solution: Manual Windows Binary Fetch
Download the native Windows executable directly from GitHub Releases:

```powershell
# In PowerShell:
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.supermemory\bin"

Invoke-WebRequest -Uri "https://github.com/supermemoryai/supermemory/releases/download/server-v0.0.8/supermemory-server-windows-x64.exe" -OutFile "$env:USERPROFILE\.supermemory\bin\supermemory-server.exe"

# Add to user PATH
[Environment]::SetEnvironmentVariable("PATH", [Environment]::GetEnvironmentVariable("PATH", "User") + ";$env:USERPROFILE\.supermemory\bin", "User")
```

## Connecting to Local OpenAI-Compatible Proxies (OmniRoute, Ollama, etc.)
Supermemory local supports any OpenAI-compatible provider for memory extraction and summarization.

Configure `C:\Users\<user>\.supermemory\.env`:

```ini
# Route LLM calls to local OpenAI-compatible proxy (e.g. OmniRoute on port 20128)
OPENAI_BASE_URL=http://localhost:20128/v1
OPENAI_API_KEY=your_key_here
OPENAI_MODEL=titan-coding-pool
```

## Running the Server
```powershell
& "$env:USERPROFILE\.supermemory\bin\supermemory-server.exe"
```
Verify the server is running by checking `http://localhost:6767`.
