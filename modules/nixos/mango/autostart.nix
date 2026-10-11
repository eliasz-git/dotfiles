{ config, lib, pkgs, ... }:

{
  wayland.windowManager.mango.settings = {
    exec_once = [
      # Notifications
      "${pkgs.dunst}/bin/dunst"

      # Clipboard history
      "${pkgs.cliphist}/bin/cliphist listen"

      # Polkit agent
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

      # Bluetooth applet
      "${pkgs.blueman}/bin/blueman-applet"

      # Network manager applet
      "${pkgs.networkmanagerapplet}/bin/nm-applet"

      # Input method (fcitx5)
      "${pkgs.fcitx5}/bin/fcitx5 -d"

      # Per-output wallpaper daemon (scripts/wallpaper-daemon.sh).
      # The TUNDRA_WALLPAPER_DIR env var it needs is set via env below.
      "${config.home.homeDirectory}/.local/bin/tundra-wallpaper-daemon"
    ];

    # Environment variables. Set as config.env so they apply to the whole
    # session, not just the exec_once line.
    env = [
      "XCURSOR_SIZE,24"
      "XCURSOR_THEME,Bibata-Modern-Classic"
      "QT_QPA_PLATFORMTHEME,qt5ct"
      "QT_STYLE_OVERRIDE,kvantum"
      "ICON_THEME,Papirus-Dark"
      "CURSOR_THEME,Bibata-Modern-Classic"
      "MOZ_ENABLE_WAYLAND,1"
      "NIXOS_OZONE_WL,1"
      "TUNDRA_WALLPAPER_DIR,${config.home.homeDirectory}/.local/share/tundra/wallpapers"
    ];
  };

  # Idle (swayidle) and nightlight (wlsunset) are started as per-user systemd
  # services in home.nix so they can be toggled without killing the session.
}