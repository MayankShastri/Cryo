# Cryo ❄️

> Reproducible development environment for TheHunter171's Windows 11 + NixOS-WSL setup.

Inspired by [Ansh-Sonkusare/Dendro](https://github.com/Ansh-Sonkusare/Dendro) — declarative, git-tracked, one-command restore.

## Structure

```
Cryo/
├── windows/                  # Windows-native dotfiles & backup scripts
│   ├── hermes/               # Hermes agent config backup
│   ├── omniroute/            # OmniRoute config backup
│   ├── supermemory/          # Supermemory .env + setup
│   └── scripts/              # Backup, restore, and autostart scripts
├── nixos-wsl/                # NixOS-WSL declarative config (flake-based)
│   ├── flake.nix
│   ├── configuration.nix
│   └── home.nix              # Home Manager config
└── docs/                     # Setup guides
    ├── windows-restore.md
    └── nixos-wsl-setup.md
```

## Quick Restore (Windows)

```bash
git clone https://github.com/MayankShastri/Cryo
cd Cryo/windows/scripts
bash restore.sh
```

## Quick Restore (NixOS-WSL)

```bash
# After fresh Windows install + WSL2 + NixOS-WSL tarball:
git clone https://github.com/MayankShastri/Cryo
cd Cryo/nixos-wsl
nixos-rebuild switch --flake .#hunter
```

## Services Covered

| Service | Windows Path | Backup Strategy |
|---|---|---|
| Hermes Agent | `AppData\Local\hermes` | Config + skills symlinked |
| OmniRoute | `AppData\Local\omp` + `.omp/` | Config files backed up |
| Supermemory | `~\.supermemory` | `.env` + data dir backed up |
