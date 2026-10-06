{
  description = "Hunter's NixOS-WSL development environment (Cryo)";

  inputs = {
    # Track nixos-unstable for latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # NixOS-WSL module: integrates NixOS with WSL2 interop
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager: per-user environment and dotfile management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.hunter = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          # NixOS-WSL integration module
          nixos-wsl.nixosModules.wsl

          # System-level config (WSL settings, packages, locale, timezone)
          ./configuration.nix

          # Home Manager as a NixOS module so `nixos-rebuild switch` rebuilds
          # both system and user environment in a single command
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hunter = import ./home.nix;
          }
        ];
      };
    };
}
