---
name: reproducible-workspaces
description: Strategies and configurations for creating reproducible developer and AI agent workspaces across OS reinstalls and migrations.
category: devops
---

# Reproducible Workspaces

Managing development workspaces and local AI companion states (Hermes, OmniRoute, Supermemory, OpenCode, Oh My Pi / `omp`) can become a major headache during system resets or migrations if configurations and states are scattered imperatively. 

This skill provides strategies for transitioning from imperative workspace setups to declarative, easily restorable environments.

## Core Approaches

### 1. The Declarative OS / Container Path: NixOS on WSL2
For Windows users who want a bulletproof, reproducible Linux development subsystem without giving up Windows 11.

- **NixOS-WSL**: Runs a full NixOS instance inside WSL2.
- **Home Manager**: Declaratively manages user packages, shell environments, dotfiles, and background services via a single config repo.
- **Key Reference (The "Dendro" Pattern)**:
  - Track your system configuration in a public/private Git repository (e.g., `github.com/<username>/Dendro`).
  - Use `hosts/<machine>.nix` to define host-specific packages (e.g., `wget`, `home-manager`, `starship`, VSCode server).
  - Rebuilding the environment on a fresh Windows install is a simple matter of installing WSL2, NixOS-WSL, cloning the repo, and running one build command.

### 2. The Symlink & Dotfiles Path (Windows Native)
If running a full Nix environment is too heavy, consolidate native Windows settings using a central dotfiles folder and symlinks:

- Create a central Git-tracked directory (e.g., `C:\Users\<user>\dotfiles`).
- Move configuration folders of AI tools into this directory:
  - **Hermes**: `AppData\Local\hermes` (profiles, skills, database)
  - **OmniRoute**: config files
  - **Supermemory**: `.supermemory` directory
- Create symbolic links from the expected system locations to your central dotfiles folder:
  ```bash
  # In Git Bash or Command Prompt (Admin)
  mklink /D "C:\Users\<user>\AppData\Local\hermes" "C:\Users\<user>\dotfiles\hermes"
  ```
- If resetting Windows, simply clone the dotfiles repository and run a script to recreate the symbolic links.

## Step-by-Step Restoration Protocols

### Restoring Hermes Agent & Local DBs
1. **Preserve Database & State**: Copy or back up `AppData\Local\hermes\state.db` and the `sessions/` directory.
2. **Preserve Custom Skills**: Custom skills are stored in `AppData\Local\hermes\skills/`.
3. **Restore Hook**: Re-install Hermes via the standard installer, then swap or symlink the backed-up directory back to `AppData\Local\hermes`.

### Restoring Local Supermemory
1. **Database & Graph Store**: All data lives in the local `.supermemory/` directory under the user's home folder.
2. **Restoration**: Back up this folder entirely. To restore, place it back in the home folder before starting the server (`supermemory-server` or `npx supermemory local`).

## Windows Background Services Autostart (Silent Logon Pattern)

On Windows, running local developer services (such as OmniRoute, Supermemory, or other background API servers) automatically on system logon—without displaying intrusive command prompt windows—is a frequent requirements trap.

While Windows Task Scheduler (`Register-ScheduledTask`) can register `LogonTrigger` tasks, it often fails with "Access is denied" if the shell is not running with administrative privileges (UAC elevation). A cleaner, non-elevated user-level approach is to leverage the Current User Run registry key (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`) combined with a silent VBScript launcher.

### The Silent VBScript Launcher Pattern
Create a `.vbs` file (e.g., under `AppData\Local\hermes\<service>_service\`) containing:

```vbs
Dim sh
Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = "C:\path\to\working\directory"
sh.Run "command_to_run.exe with arguments", 0, False
```
*Note: The `0` parameter hides the window entirely, and `False` runs it asynchronously (the launcher exits immediately while leaving the target process running in the background).*

### Registering the Service in Registry Run Keys
Execute the following `reg` command in any user-level (non-admin) terminal to write to the current user's Run registry:

```bash
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Service_Name" /t REG_SZ /d "wscript.exe //B //Nologo \"C:\Users\<user>\path\to\launcher.vbs\"" /f
```
*(The `//B` and `//Nologo` flags ensure the VBScript host executes the script silently without popups or error dialogues).*

## Linked Files
- `references/oh-my-pi-omniroute-setup.md` — Setup instructions, directory layout, and OpenAI-compatible proxy (OmniRoute) routing configuration for Oh My Pi (`omp`).
- `references/supermemory-local-setup.md` — Setup instructions, Windows binary troubleshooting (Git Bash vs. PowerShell traps), and local proxy (OmniRoute) configuration.
- `references/windows-background-services.md` — Non-elevated pattern for silent Windows background service autostart using VBScript wrappers and the HKCU Run registry key.
- `references/windows-storage-hygiene.md` — High-yield cache targets and safe cleanup patterns for Windows AI/developer workstations, including WSL VHDX compaction caveats and strict preservation rules.
