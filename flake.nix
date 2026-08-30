{
  description = "Multi-system nix configuration — Everforest / Gruvbox";

  inputs = {
    # Stable — used by macOS and NixOS hosts
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.05";
    darwin.url           = "github:LnL7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url     = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Unstable — used by the Alpine host for latest packages
    # (ly 1.3.2, neovim HEAD, etc.)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-agent.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, darwin, home-manager, hermes-agent, ... }:
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
      specialArgs = { inherit hermes-agent; };
      modules = [
        ./hosts/darwin/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs       = true;
          home-manager.useUserPackages     = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.elias         = import ./hosts/darwin/home.nix;
        }
      ];
    };

    # ── NixOS (systemd) ───────────────────────────────────────────
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system  = linuxSystem;
      pkgs    = linuxPkgs;
      config  = { allowUnfree = true; };
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

<<<<<<< HEAD
=======
    # ── Homelab: headless NixOS minis (Tailscale, Docker) ────────────
    #  mini1 — HP ProDesk 600 G1 DM (i3-4160T) — infra, 192.168.1.75
    #  mini2 — HP ProDesk 405 G4 DM (R5 PRO 2400GE) — media, 192.168.1.76
    nixosConfigurations.mini1 = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      pkgs   = linuxPkgs;
      modules = [
        ./hosts/mini/1/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs       = true;
          home-manager.useUserPackages     = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.elias         = import ./hosts/mini/1/home.nix;
        }
      ];
    };
    nixosConfigurations.mini2 = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      pkgs   = linuxPkgs;
      modules = [
        ./hosts/mini/2/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs       = true;
          home-manager.useUserPackages     = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.elias         = import ./hosts/mini/2/home.nix;
        }
      ];
    };

    # ── Artix Linux — OpenRC, Everforest, nixpkgs 25.05 ──────────
    homeConfigurations.artix = home-manager.lib.homeManagerConfiguration {
      pkgs    = linuxPkgs;
      modules = [ ./hosts/artix/home.nix ];
    };

>>>>>>> ba7933859e0d1e08ed694970677d1f5780c30e01
    # mini2 — HP ProDesk 405 G4 DM — desktop + gaming (AMD Vega)
    homeConfigurations.mini2 = home-manager.lib.homeManagerConfiguration {
      pkgs = linuxPkgs;
      modules = [ ./hosts/mini/2/home.nix ];
    };

    # ── Alpine Linux — OpenRC, Gruvbox Dark, nixpkgs UNSTABLE ────
    # Uses unstable for latest package versions (neovim, starship, etc.)
    # Ly display manager is intentionally kept in APK — it runs as root
    # before any user nix profile is mounted, so can't come from nixpkgs.
    #
    # Apply:  home-manager switch --flake ~/.config/nix-config#alpine
    # Update: hmu  (alias: nix flake update && home-manager switch ...)
    homeConfigurations.mini1 = home-manager.lib.homeManagerConfiguration {
      pkgs = unstablePkgs;
      modules = [ ./hosts/mini/1/home.nix ];
    };

  };
}
