{
  description = "Multi-system nix configuration — Tundra Dark";

  inputs = {
    # Everything tracks nixpkgs unstable now — single channel, latest
    # packages everywhere (tailscale, neovim, ly, etc.)
    nixpkgs.url           = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url            = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url      = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-agent.inputs.nixpkgs.follows = "nixpkgs";
    
    # Zen Browser — community flake
    zen-browser = { url = "github:0xc000022070/zen-browser-flake"; };
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # niri — provides the home-manager `programs.niri.settings` option used by
    # hosts/nixos/home.nix (the laptop). Without it that host cannot evaluate.
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, home-manager, hermes-agent, zen-browser, niri, ... }:
  let
    darwinSystem   = "aarch64-darwin";
    linuxSystem    = "x86_64-linux";

    darwinPkgs     = import nixpkgs { system = darwinSystem; config.allowUnfree = true; };
    linuxPkgs      = import nixpkgs { system = linuxSystem;  config.allowUnfree = true; };
    unstablePkgs   = linuxPkgs;
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
      specialArgs = { inherit hermes-agent; };
      modules = [
        ./hosts/nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs           = true;
          home-manager.useUserPackages         = true;
          home-manager.backupFileExtension     = "backup";
          # `programs.niri.settings` / `config.lib.niri` (used by hosts/nixos/home.nix).
          # Config-only module: the niri binary still comes from nixpkgs via
          # programs.niri.enable in configuration.nix.
          home-manager.sharedModules           = [ niri.homeModules.config ];
          home-manager.users.tundra            = import ./hosts/nixos/home.nix;
        }
      ];
    };

    # ── Homelab: headless NixOS minis (Tailscale, Docker) ────────────
    #  mini1 — HP ProDesk 600 G1 DM (i3-4160T) — infra, 192.168.1.75
    #  mini2 — HP ProDesk 405 G4 DM (R5 PRO 2400GE) — media, 192.168.1.76
    nixosConfigurations.mini1 = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      pkgs   = unstablePkgs;
      specialArgs = { inherit hermes-agent; };
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
      pkgs   = unstablePkgs;
      specialArgs = { inherit hermes-agent; };
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

    # ── Beattie showcase — NixOS GNOME (Wayland, Tundra Dark) ────
    nixosConfigurations.beattie = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit hermes-agent; };
      system = linuxSystem;
      pkgs   = linuxPkgs;
      modules = [
        ./hosts/beattie/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs           = true;
          home-manager.useUserPackages         = true;
          home-manager.backupFileExtension     = "backup";
          home-manager.users.demo   = import ./hosts/beattie/home.nix;
          home-manager.users.tundra = import ./hosts/beattie/home.nix;
        }
      ];
    };

    # ── NEW: GAMING PC ───────────────────────────────────────────
    nixosConfigurations.gaming-pc = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      pkgs = linuxPkgs;
      specialArgs = { inherit hermes-agent; };
      modules = [
        ./hosts/gaming/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit zen-browser; };
          home-manager.users.elias = import ./hosts/gaming/home.nix;
        }
      ];
    };

    # mini2 — HP ProDesk 405 G4 DM — desktop + gaming (AMD Vega)
    homeConfigurations.mini2 = home-manager.lib.homeManagerConfiguration {
      pkgs = linuxPkgs;
      modules = [ ./hosts/mini/2/home.nix ];
    };

    # ── Standalone Home Manager fallbacks ─────────────────────────
    # These are user-environment outputs only; they are not NixOS systems and
    # do not replace the mini1/mini2 system outputs above.
    homeConfigurations.mini1 = home-manager.lib.homeManagerConfiguration {
      pkgs = unstablePkgs;
      modules = [ ./hosts/mini/1/home.nix ];
    };

  };
}
