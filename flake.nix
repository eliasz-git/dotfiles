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
    # hosts/laptop/home.nix (the laptop). Without it that host cannot evaluate.
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Mango — dwl-based Wayland compositor for the desktop host. The flake
    # ships both the NixOS module (programs.mango) and the home-manager module
    # (wayland.windowManager.mango, used by hosts/desktop/home.nix); nixpkgs
    # does not provide the home-manager side.
    mango.url = "github:mangowm/mango";
    mango.inputs.nixpkgs.follows = "nixpkgs";

    # Mangobar — the status bar that talks to Mango over IPC. Its flake
    # exports the package plus a home-manager module (services.mangobar).
    mangobar.url = "github:mangowm/mangobar";
    mangobar.inputs.nixpkgs.follows = "nixpkgs";

    # agenix — encrypted secrets. Used via agenix.decipher in
    # modules/shared/secrets.nix, which is pure Nix, so one code path covers
    # nix-darwin, NixOS, and standalone home-manager hosts.
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, darwin, home-manager, hermes-agent, zen-browser, niri, mango, mangobar, agenix, ... }:
  let
    darwinSystem   = "aarch64-darwin";
    linuxSystem    = "x86_64-linux";

    # ltrace 0.7.91 runs a dejagnu suite in its checkPhase that fails 15 tests
    # on Linux — the ptrace and ASLR expectations are sensitive to the build
    # environment. Because nixpkgs CI hits the same failures, no output is
    # published to cache.nixos.org, so anything depending on ltrace compiles it
    # from source and then fails on the test suite. The package itself builds
    # and works; only the suite is at fault. Drop this once nixpkgs fixes it.
    #
    # Python packages whose own test suites break the build in CI even though
    # the packages themselves compile and work. Their checkPhase is skipped
    # until nixpkgs fixes or stabilises the tests:
    #  - pyopenjtalk-plus 0.4.1-post9: one test expects "must be str" but the
    #    interpreter now says "Expected str, got int". calibre pulls it in
    #    through piper-tts, which broke the laptop's Home Manager generation.
    #  - pyrate-limiter 4.5.0: test_limiter_async_factory_get asserts on timing
    #    (assert 300 <= 270) and fails on a loaded runner. lutris reaches it
    #    through moddb, which made the desktop build fail intermittently.
    overlays = [
      (final: prev: {
        ltrace = prev.ltrace.overrideAttrs (_: { doCheck = false; });

        # calibre 9.16.0 runs its own test_build suite as an install check; one
        # test (test_speech_dispatcher) fails because the speechd Python module
        # is not importable in the build sandbox. 672 of 673 other tests pass
        # and the package builds. Only the laptop installs it.
        calibre = prev.calibre.overrideAttrs (_: { doInstallCheck = false; });

        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (pyFinal: pyPrev:
            prev.lib.genAttrs
              (builtins.filter (n: pyPrev ? ${n}) [ "pyopenjtalk-plus" "pyrate-limiter" ])
              (n: pyPrev.${n}.overridePythonAttrs (_: { doCheck = false; })))
        ];
      })
    ];

    darwinPkgs     = import nixpkgs { system = darwinSystem; config.allowUnfree = true; inherit overlays; };
    linuxPkgs      = import nixpkgs { system = linuxSystem;  config.allowUnfree = true; inherit overlays; };
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
          home-manager.sharedModules   = [ agenix.homeManagerModules.default ];
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
        ./hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs           = true;
          home-manager.useUserPackages         = true;
          home-manager.backupFileExtension     = "backup";
          # `programs.niri.settings` / `config.lib.niri` (used by hosts/laptop/home.nix).
          # Config-only module: the niri binary still comes from nixpkgs via
          # programs.niri.enable in configuration.nix.
          home-manager.sharedModules           = [
            niri.homeModules.config
            agenix.homeManagerModules.default
          ];
          home-manager.extraSpecialArgs        = { inherit zen-browser; };
          home-manager.users.elias            = import ./hosts/laptop/home.nix;
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
          home-manager.sharedModules        = [ agenix.homeManagerModules.default ];
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
          home-manager.sharedModules        = [ agenix.homeManagerModules.default ];
          home-manager.users.elias         = import ./hosts/mini/2/home.nix;
        }
      ];
    };

    # ── DESKTOP (formerly Gaming PC) ───────────────────────────
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      pkgs = linuxPkgs;
      specialArgs = { inherit hermes-agent; };
      modules = [
        ./hosts/desktop/configuration.nix
        # NixOS module for Mango: programs.mango (portals, xwayland, session
        # entry, polkit). This is pinned ahead of any nixpkgs copy via the
        # flake's own disabledModules.
        mango.nixosModules.mango
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          # `wayland.windowManager.mango` (settings/autostart_sh/systemd) and
          # `services.mangobar` (the Mango status bar) come from their flakes.
          home-manager.sharedModules        = [
            mango.hmModules.mango
            mangobar.homeManagerModules.default
            agenix.homeManagerModules.default
          ];
          home-manager.extraSpecialArgs = { inherit zen-browser; };
          home-manager.users.elias = import ./hosts/desktop/home.nix;
        }
      ];
    };

    # mini2 — HP ProDesk 405 G4 DM — desktop + gaming (AMD Vega)
    homeConfigurations.mini2 = home-manager.lib.homeManagerConfiguration {
      pkgs = linuxPkgs;
      modules = [
        ./hosts/mini/2/home.nix
        agenix.homeManagerModules.default
      ];
    };

    # ── Standalone Home Manager fallbacks ─────────────────────────
    # These are user-environment outputs only; they are not NixOS systems and
    # do not replace the mini1/mini2 system outputs above.
    homeConfigurations.mini1 = home-manager.lib.homeManagerConfiguration {
      pkgs = unstablePkgs;
      modules = [
        ./hosts/mini/1/home.nix
        agenix.homeManagerModules.default
      ];
    };

  };
}
