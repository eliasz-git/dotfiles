{ config, pkgs, lib, ... }:
let
  uconfig = config.users.elias;
in {
  home.stateVersion = "25.11";
  home-manager.enable = true;
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # ── WINDOW MANAGER: HYPRLAND ────────────────────────────────
  # Hyprland is a dynamic tiling Wayland compositor
  programs.hyprland = {
    enable = true;
    # Basic hyprland configuration
    mainMonitor = "eDP-1";  # Will be auto-detected, user may change
    # General colors/appearance (matching Tundra Dark)
    col.active_border = "#c0caf5";
    col.inactive_border = "#181825";
    col.separating_border = "#565f89";
    col.workspace_button = "#7aa2f7";
    # Layout
    general = {
      gap = 0;
      border = 2;
      col.active_opacity = 1;
      col.inactive_opacity = 0.9;
    };
    # Input configuration
    input = {
      KB = {
        loader = "keyboards/us.json";
      };
      mouse = {
        accelerate = true;
        accelerateFactor = 0.2;
        accelerateFPS = 60;
      };
    };
    # Appearance
    decoration = {
      roundCorners = true;
      blur = {
        enabled = true;
        size = 10;
        fps = 60;
      };
    };
    # Multi-monitor (FHD 120Hz setup)
    monitor = {
      eDP-1 = {
        model = "FHD 120Hz";
        refreshRate = 120;
        scale = 1;
      };
    };
  };

  # ── HYPRLAND KEYBINDINGS (core set) ───────────────────────
  # Essential Hyprland controls

  # Focus/manage
  home.packages = with pkgs; [
    hyprland
    hyprpaper
    wofi
  ];

  # ── GAMES & STEAM ──────────────────────────────────────────
  home.packages = with pkgs; [
    steam
    # Gaming overlays
    mangohud
    gamescope
    radeon-profile
    gamemode
    libstrangle
    # Utility tools
    wofi           # Application launcher (dmenu alternative)
    bemenu         # Wayland menu
    foot           # Terminal (Wayland-native)
    # Media/ audio
    pulsemixer
    # File management (Wayland)
    nnn
    lf
  ];

  # Steam launch options / Proton config
  programs.steam = {
    enable = true;
    enableProton = true;
    # Use proton-ge-custom for better compatibility
    launchOptions = {
      default = {
        protonVersion = "proton-ge-custom";
      };
    };
  };

  # ── APPLE/ICLOUD INTEGRATION ──────────────────────────────
  # iPhone/icloud support tools (all under single home.packages assignment)
  home.packages = with pkgs; [
    steam
    # Gaming overlays
    mangohud
    gamescope
    radeon-profile
    gamemode
    libstrangle
    # Utility tools
    wofi
    bemenu
    foot
    pulsemixer
    nnn
    lf
    # Apple integration
    blueutil       # Bluetooth CLI control
    bluefish       # Bluetooth device manager
    nowplaying-cli # Show now-playing from Apple devices
  ];

  # Bluetooth configuration for iPhone (not in home.packages, system-level)
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # nowplaying-cli config for Apple Music integration
  programs.nowplaying-cli = {
    enable = true;
    player = "apple-music";  # Try Apple Music first
    # Fallback to lastfm, etc.
  };

  # ── TERMINAL (foot for Wayland) ───────────────────────────
  programs.foot = {
    enable = true;
    font = "JetBrainsMono Nerd Font:size=11";
    # Transparency/blur for Wayland
    immediate = true;
    # Bell style
    bell = "none";
  };

  # ── ROFI / WOFI MENU ──────────────────────────────────────
  programs.wofi = {
    enable = true;
    # General appearance to match hyprland
    theme = ''
      * {
        background: #181825;
        foreground: #c0caf5;
        selected-background: #7aa2f7;
      }
    '';
  };

  # ── POWER & PERFORMANCE ───────────────────────────────────
  # TLP for automatic power management
  services.tlp.enable = true;
  services.tlp.autoEnable = true;

  # GPU power profiles
  # On AC: performance; On battery: powersave
  # Handled by TLP automatically

  # ── NOTIFICATIONS ────────────────────────────────────────
  # Dunst or Wayland-native notification daemon
  home.packages += [ "dunst" ];

  # Hyprland specific: rule for notifications
  programs.hyprland.rules = {
    # Mark certain apps as floating
    float [
      "mpv"
      "pinentry"
      "feh"
      "qalculate-gtk"
    ];
    # Move specific apps to workspace
    moveToWorkspace [
      { class = "Firefox"; workspace = 1; }
      { class = "Steam"; workspace = 2; }
    ];
  };

  # ── FONT & APPEARANCE ─────────────────────────────────────
  home.packages += with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    ttf-ubuntu-font-family
  ];

  # GTK theming for Wayland apps
  gtk = {
    enable = true;
    theme = "Orchis-Dark";  # Match existing theme
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    iconTheme = {
      name = "Papirus-Dark";
    };
  };

  # ── SYSTEM SERVICES ───────────────────────────────────────
  # SSH for cross-device access
  services.openssh.enable = true;

  # Avahi for local network service discovery
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  # power-profiles-daemon for hybrid performance/power
  services.power-profiles-daemon.enable = true;

  # ── STEAM LIBRARY PATH ────────────────────────────────────
  # Configure Steam to store games on appropriate partition
  # This is typically set within Steam UI, but we can hint
  home.file".local/share/Steam".ensure = "directory";

  system.stateVersion = "25.11";
}
