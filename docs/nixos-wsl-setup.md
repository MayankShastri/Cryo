# NixOS-WSL Setup Guide

Install a NixOS-WSL2 development environment from scratch using the Cryo flake.

## What you get

- NixOS running inside WSL2 on Windows 11
- Home Manager managing user packages, zsh, git, fzf, bat, ripgrep
- A single command (`cryo-update`) to sync config changes from this repo

---

## 1 — Enable WSL2 on Windows

Open **PowerShell as Administrator**:

```powershell
wsl --install --no-distribution
# Reboot when prompted
```

After reboot, verify:

```powershell
wsl --status
# Should show: Default Version: 2
```

---

## 2 — Download the NixOS-WSL tarball

Go to: https://github.com/nix-community/NixOS-WSL/releases

Download the latest `nixos-wsl.tar.gz` (or `.tar.zst`).

---

## 3 — Import the NixOS-WSL distro

```powershell
# Create a directory to store the WSL virtual disk
mkdir C:\WSL\NixOS

# Import (adjust paths as needed)
wsl --import NixOS C:\WSL\NixOS C:\Users\mayan\Downloads\nixos-wsl.tar.gz --version 2
```

Verify it's registered:

```powershell
wsl --list --verbose
# Should show NixOS in the list
```

---

## 4 — Boot into NixOS for the first time

```powershell
wsl -d NixOS
```

You land as the `nixos` user. Run a quick sanity check:

```bash
nixos-version
# e.g. 24.05pre-git (Uakari)
```

---

## 5 — Clone the Cryo repository

```bash
# Install git via nix-shell (not yet in profile)
nix-shell -p git

# Clone Cryo into home
git clone https://github.com/TheHunter171/Cryo.git ~/Cryo
exit  # exit nix-shell
```

---

## 6 — Copy the flake into the system config location

NixOS-WSL reads its config from `/etc/nixos`. Link or copy the Cryo flake there:

```bash
sudo cp -r ~/Cryo/nixos-wsl/* /etc/nixos/
```

Alternatively, keep the source of truth in `~/Cryo` and symlink:

```bash
sudo ln -sfn ~/Cryo/nixos-wsl /etc/nixos/cryo
# Then point flake to /etc/nixos/cryo
```

---

## 7 — Run the first system rebuild

```bash
sudo nixos-rebuild switch --flake /etc/nixos#hunter
```

This will:
- Download all declared packages (takes a few minutes first time)
- Create the `hunter` user with zsh
- Apply Home Manager config (git, zsh plugins, aliases, packages)

---

## 8 — Switch to the hunter user

```bash
# Log out of nixos user
exit

# Re-enter as hunter
wsl -d NixOS -u hunter
```

Verify:

```bash
echo $SHELL
# /run/current-system/sw/bin/zsh

git --version && node --version && bat --version
```

---

## 9 — Set default distro (optional)

```powershell
wsl --set-default NixOS
```

Now `wsl` without arguments opens NixOS directly.

---

## Updating the config later

Any change committed to `~/Cryo/nixos-wsl/` is applied with:

```bash
cryo-update
# Equivalent to: cd ~/Cryo && git pull && sudo nixos-rebuild switch --flake .#hunter
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `error: flake 'path:...' does not provide attribute` | Wrong hostname in flake | Check `nixosConfigurations.hunter` in `flake.nix` |
| User `hunter` not in sudoers | First build failed mid-way | Run rebuild again as `nixos` user |
| Zsh not starting | Home Manager not applied | Run `home-manager switch --flake /etc/nixos#hunter` manually |
| Slow nix downloads | No cache hit | Normal on first build; subsequent builds are cached |
