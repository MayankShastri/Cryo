{ config, pkgs, lib, ... }:

{
  # ── WSL integration ────────────────────────────────────────────────────────
  wsl.enable = true;
  wsl.defaultUser = "hunter";

  # ── Nix settings ──────────────────────────────────────────────────────────
  nix.settings = {
    # Enable the Nix flakes feature and nix-command CLI
    experimental-features = [ "nix-command" "flakes" ];
    # Cache substituters for faster rebuilds
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # Keep flake registry and nix path in sync with the flake inputs
  nix.registry.nixpkgs.flake = import <nixpkgs>;

  # ── Locale & timezone ──────────────────────────────────────────────────────
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── System packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    # Node.js LTS from nixpkgs
    nodejs_22
    # Editors
    vim
    neovim
    # Shell
    zsh
    # Home Manager CLI (also available via the NixOS module, but handy to have)
    home-manager
    # Utilities
    gnumake
    unzip
    tree
    htop
  ];

  # ── Shell ──────────────────────────────────────────────────────────────────
  # Set zsh as the system default shell for new users
  programs.zsh.enable = true;

  # ── User definition ────────────────────────────────────────────────────────
  users.users.hunter = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    # Password authentication is fine inside WSL; external access is via Windows
    hashedPassword = "";  # Set via `passwd` after first boot or replace with mkpasswd hash
  };

  # Allow wheel group members to use sudo without a password (WSL convenience)
  security.sudo.wheelNeedsPassword = false;

  # ── State version ──────────────────────────────────────────────────────────
  # Set to the NixOS version used when this configuration was first created.
  # Do NOT change after initial setup unless you understand the implications.
  system.stateVersion = "24.05";
}
