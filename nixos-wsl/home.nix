{ config, pkgs, lib, ... }:

{
  # ── Basic home settings ────────────────────────────────────────────────────
  home.username = "hunter";
  home.homeDirectory = "/home/hunter";
  # Must match the Home Manager release used to first create this config.
  home.stateVersion = "24.05";

  # ── Packages available to hunter only ─────────────────────────────────────
  home.packages = with pkgs; [
    # Modern replacements for standard tools
    bat          # Better cat with syntax highlighting
    ripgrep      # Faster grep (rg)
    fzf          # Fuzzy finder
    fd           # Faster find
    eza          # Better ls (replaces exa)
    # Info / utilities
    neofetch
    curl
    wget
    jq
    # Node ecosystem (available at user level as well)
    nodejs_22
    nodejs_22.pkgs.npm
    # Git extras
    git
    gh           # GitHub CLI
  ];

  # ── Git configuration ──────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName  = "TheHunter171";
    # Replace with your real email
    userEmail = "your@email.com";
    extraConfig = {
      core.autocrlf = "input";  # Normalize CRLF on commit inside WSL
      pull.rebase   = true;
      init.defaultBranch = "main";
    };
  };

  # ── Zsh + Oh-My-Zsh ───────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      # Bundled plugins
      plugins = [ "git" "node" "z" "sudo" "fzf" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      # ── Cryo helpers ──────────────────────────────────────────────────────
      # Pull latest Cryo configs and rebuild the NixOS system + home env.
      # Run from inside the NixOS-WSL instance (not Windows).
      cryo-update = "cd ~/Cryo && git pull && sudo nixos-rebuild switch --flake .#hunter";

      # ── Quality-of-life ───────────────────────────────────────────────────
      ls  = "eza --icons";
      ll  = "eza -lh --icons";
      la  = "eza -lah --icons";
      cat = "bat --paging=never";
      rg  = "rg --smart-case";
    };

    # Extra lines appended verbatim to ~/.zshrc
    initExtra = ''
      # fzf key bindings and completion (provided by the fzf package)
      [ -f "${pkgs.fzf}/share/fzf/completion.zsh" ]    && source "${pkgs.fzf}/share/fzf/completion.zsh"
      [ -f "${pkgs.fzf}/share/fzf/key-bindings.zsh" ]  && source "${pkgs.fzf}/share/fzf/key-bindings.zsh"

      # Show system info on new shell (remove if too noisy)
      # neofetch
    '';
  };

  # ── Starship prompt (optional — comment out if you prefer oh-my-zsh theme) ─
  # programs.starship.enable = true;

  # ── Let Home Manager manage itself ────────────────────────────────────────
  programs.home-manager.enable = true;
}
