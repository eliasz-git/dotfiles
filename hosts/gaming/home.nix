{ config, pkgs, lib, zen-browser, ... }:

# Home Manager config for the gaming PC (user: elias).
# System-level stuff (Steam, Hyprland package, drivers, TLP/PPD, ssh, avahi,
# bluetooth) lives in configuration.nix — Home Manager has no options for those.
let
  wallpaper = ../../wallpapers/wallpaper.jpg;
in {
  imports = [
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/home/themes.nix
    ../../modules/nixos/hyprland/monitors.nix
    ../../modules/nixos/hyprland/input.nix
    ../../modules/nixos/hyprland/bindings.nix
    ../../modules/nixos/hyprland/looknfeel.nix
    ../../modules/nixos/hyprland/autostart.nix
    ../../modules/nixos/hyprland/toggles.nix
    ../../modules/nixos/rofi.nix
    ../../modules/nixos/clipboard.nix
    ../../modules/nixos/screenshot.nix
    ../../modules/nixos/ai-tools.nix
    ../../modules/nixos/gaming-enhanced.nix
  ];

  home.stateVersion = "26.05";

  # Enable theme system
  tundra.enable = true;
  tundra.theme = "catppuccin-mocha";

  # ── WINDOW MANAGER: HYPRLAND ────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland itself comes from programs.hyprland in configuration.nix;
    # null here avoids a second, possibly mismatched copy.
    package = null;
    portalPackage = null;

    # Settings below are hyprlang. HM's default flips to Lua at stateVersion 26.05,
    # so pin it — otherwise a future stateVersion bump would silently break this config.
    configType = "hyprlang";

    # Settings are now imported from modular files:
    # - monitors.nix
    # - input.nix
    # - bindings.nix
    # - looknfeel.nix
    # - autostart.nix
    # - toggles.nix
    #
    # Keep minimal overrides here if needed:
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "foot";
      "$menu" = "rofi -show drun";

      # Monitor config from monitors.nix (override if needed)
      # monitor = [ ",highrr,auto,1" ];

      # Input config from input.nix

      # Keybindings from bindings.nix

      # Look & feel from looknfeel.nix

      # Autostart from autostart.nix

      # Env vars
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "HYPRCURSOR_THEME,Bibata-Modern-Classic"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_STYLE_OVERRIDE,kvantum"
        "GTK_THEME,Orchis-Dark"
        "ICON_THEME,Papirus-Dark"
        "CURSOR_THEME,Bibata-Modern-Classic"
        "MOZ_ENABLE_WAYLAND,1"
        "NIXOS_OZONE_WL,1"
      ];
    };
  };

  # ── TERMINAL ───────────────────────────────────────────────
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "12x12";
      };
      colors = {
        background = "181825";
        foreground = "c0caf5";
      };
    };
  };

  # ── LAUNCHER: ROFI (replaces wofi) ─────────────────────────
  # Configured in rofi.nix

  # ── NOTIFICATIONS ──────────────────────────────────────────
  services.dunst.enable = true;

  # ── TOP BAR ────────────────────────────────────────────────
  # Waybar: workspaces + window title on the left, clock in the middle,
  # cpu, memory, network, volume, tray on the right.
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "top";
      height = 32;
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "cpu" "memory" "network" "pulseaudio" "tray" ];
      "hyprland/window".max-length = 60;
      clock.format = "{:%a %b %d  %I:%M %p}";
      cpu = {
        format = "󰻠 {usage}%";
        interval = 5;
      };
      memory = {
        format = "󰍛 {percentage_used}%";
        interval = 5;
      };
      network = {
        format-wifi = "󰖨 {signalStrength}%";
        format-ethernet = "󰈀 {ipaddr}";
        format-disconnected = "󰖪 Disconnected";
        interval = 10;
      };
      pulseaudio = {
        format = "vol {volume}%";
        format-muted = "muted";
        on-click = "pavucontrol";
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
      }
      window#waybar {
        background-color: #181825;
        color: #c0caf5;
      }
      #workspaces button {
        padding: 0 8px;
        color: #c0caf5;
        background: transparent;
      }
      #workspaces button.active {
        background-color: #7aa2f7;
        color: #181825;
      }
      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #window {
        padding: 0 12px;
      }
      #cpu.warning {
        color: #f9e2af;
      }
      #cpu.critical {
        color: #f38ba8;
      }
      #memory.warning {
        color: #f9e2af;
      }
      #memory.critical {
        color: #f38ba8;
      }
    '';
  };

  # ── GAME OVERLAY ───────────────────────────────────────────
  programs.mangohud.enable = true;

  # ── CURSOR & GTK ───────────────────────────────────────────
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Orchis-Dark";
      package = pkgs.orchis-theme;
    };
    gtk4.theme = config.gtk.theme; # keep GTK4 apps themed too
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # ── SHELL ──────────────────────────────────────────────────
  # Aliases defined in modules/shared/shell.nix

  # ── PACKAGES ───────────────────────────────────────────────
  # Steam, gamemode, gamescope, and Proton-GE are enabled system-wide
  # (configuration.nix); they don't belong here.
  # Zen Browser comes from the zen-browser flake input (it isn't in nixpkgs);
  # the binary is `zen-beta`, which is what Super+B launches.
  home.packages = with pkgs; [
    # Apps
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    discord
    # Desktop utilities
    swaybg wl-clipboard grim slurp playerctl
    pulsemixer pavucontrol
    nnn lf
    # Clipboard
    cliphist
    # Screenshot/recording
    swappy wf-recorder
    # Needed by modules/shared/shell.nix (aliases + init hook)
    eza pay-respects
    # AI tools (also in ai-tools.nix)
    # opencode claude-code gemini-cli copilot-cli
  ];
}