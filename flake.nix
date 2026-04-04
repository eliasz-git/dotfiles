{
  description = "Multi-system nix configuration — Everforest / Gruvbox";

  inputs = {
    # Stable — used by macOS, NixOS, and Artix hosts
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.05";
    darwin.url           = "github:LnL7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url     = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Unstable — used by the Alpine host for latest packages
    # (ly 1.3.2, neovim HEAD, etc.)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, darwin, home-manager, ... }:
  let
    darwinSystem   = "aarch64-darwin";
    linuxSystem    = "x86_64-linux";

    darwinPkgs     = import nixpkgs          { system = darwinSystem; config.allowUnfree = true; };
    linuxPkgs      = import nixpkgs          { system = linuxSystem;  config.allowUnfree = true; };
    unstablePkgs   = import nixpkgs-unstable { system = linuxSystem;  config.allowUnfree = true; };
  in {

    # ── macOS M2 ──────────────────────────────────────────────────
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system  = darwinSystem;
      pkgs    = darwinPkgs;
      modules = [
        ./hosts/darwin/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          home-manager.users.elias     = import ./hosts/darwin/home.nix;
        }
      ];
    };

    # ── NixOS (systemd) ───────────────────────────────────────────
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system  = linuxSystem;
      pkgs    = linuxPkgs;
      modules = [
        ./hosts/nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs           = true;
          home-manager.useUserPackages         = true;
          home-manager.backupFileExtension     = "backup";
          home-manager.users.tundra            = import ./hosts/nixos/home.nix;
        }
      ];
    };

    # ── Artix Linux — OpenRC, Everforest, nixpkgs 25.05 ──────────
    homeConfigurations.artix = home-manager.lib.homeManagerConfiguration {
      pkgs    = linuxPkgs;
      modules = [ ./hosts/artix/home.nix ];
    };

    # ── Alpine Linux — OpenRC, Gruvbox Dark, nixpkgs UNSTABLE ────
    # Uses unstable for latest package versions (neovim, starship, etc.)
    # Ly display manager is intentionally kept in APK — it runs as root
    # before any user nix profile is mounted, so can't come from nixpkgs.
    #
    # Apply:  home-manager switch --flake ~/.config/nix-config#alpine
    # Update: hmu  (alias: nix flake update && home-manager switch ...)
    homeConfigurations.alpine = home-manager.lib.homeManagerConfiguration {
      pkgs    = unstablePkgs;
      modules = [ ./hosts/alpine/home.nix ];
    };

  };
}
