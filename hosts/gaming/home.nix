{ config, pkgs, lib, ... }:
let
  uconfig = config.users.elias;
in {
  home.stateVersion = "25.11";
  home-manager.enable = true;
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # ── WINDOW MANAGER: HYPRLAND ────────────────────────────────
  programs.hyprland = {
    enable = true;
    mainMonitor = "eDP-1";
    col.active_border = "#c0caf5";
    col.inactive_border = "#181825";
    col.separating_border = "#565f89";
    col.workspace_button = "#7aa2f7";
    general = { gap = 0; border = 2; col.active_opacity = 1; col.inactive_opacity = 0.9; };
    input = { KB = { loader = "keyboards/us.json"; }; mouse = { accelerate = true; accelerateFactor = 0.2; accelerateFPS = 60; }; };
    decoration = { roundCorners = true; blur = { enabled = true; size = 10; fps = 60; }; };
    monitor = { eDP-1 = { model = "FHD 120Hz"; refreshRate = 120; scale = 1; }; };
  };

  # ── HYPRLAND KEYBINDINGS ─────────────────────────────────

  # ── GAMES & STEAM ──────────────────────────────────────────
  programs.steam = {
    enable = true;
    enableProton = true;
    launchOptions = { default = { protonVersion = "proton-ge-custom"; }; };
  };

  # ── APPLE/ICLOUD INTEGRATION ──────────────────────────────
  programs.nowplaying-cli = { enable = true; player = "apple-music"; };

  # ── TERMINAL ───────────────────────────────────────────────
  programs.foot = { enable = true; font = "JetBrainsMono Nerd Font:size=11"; immediate = true; bell = "none"; };

  # ── ROFI / WOFI MENU ──────────────────────────────────────
  programs.wofi = {
    enable = true;
    theme = ''
      * {
        background: #181825;
        foreground: #c0caf5;
        selected-background: #7aa2f7;
      }
    '';
  };

  # ── POWER & PERFORMANCE ───────────────────────────────────
  services.tlp.enable = true; services.tlp.autoEnable = true;

  # ── NOTIFICATIONS ─────────────────────────────────────────
  programs.hyprland.rules = {
    float = [ "mpv" "pinentry" "feh" "qalculate-gtk" ];
    moveToWorkspace = [ { class = "Firefox"; workspace = 1; } { class = "Steam"; workspace = 2; } ];
  };

  # ── FONT & APPEARANCE ─────────────────────────────────────
  gtk = { enable = true; theme = "Orchis-Dark"; cursorTheme = { name = "Bibata-Modern-Classic"; size = 24; }; iconTheme = { name = "Papirus-Dark"; }; };

  # ── SYSTEM SERVICES ───────────────────────────────────────
  services.openssh.enable = true;
  services.avahi.enable = true; services.avahi.nssmdns = true;
  services.power-profiles-daemon.enable = true;

  # ── STEAM LIBRARY PATH ────────────────────────────────────
  home.file.".local/share/Steam".ensure = "directory";

  # ── ALL PACKAGES CONSOLIDATED INTO ONE ASSIGNMENT ──────────────
  home.packages = with pkgs; [
    # Hyprland WM
    hyprland hyprpaper wofi
    # Gaming & Steam
    steam mangohud gamescope radeon-profile gamemode libstrangle
    # Utility tools
    wofi bemenu foot pulsemixer nnn lf
    # Apple integration
    blueutil bluefish nowplaying-cli
    # Fonts
    nerd-fonts.jetbrains-mono nerd-fonts.fira-code ttf-ubuntu-font-family
    # Notifications
    dunst
  ];

  system.stateVersion = "25.11";
}