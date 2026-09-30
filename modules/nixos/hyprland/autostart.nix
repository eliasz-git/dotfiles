{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.exec_once = [
    # Notifications
    "${pkgs.dunst}/bin/dunst"

    # Clipboard history
    "${pkgs.cliphist}/bin/cliphist listen &"

    # Polkit agent
    "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

    # Bluetooth applet
    "${pkgs.blueman}/bin/blueman-applet"

    # Network manager applet
    "${pkgs.networkmanagerapplet}/bin/nm-applet"

    # Input method (fcitx5)
    "${pkgs.fcitx5}/bin/fcitx5 -d"

    # Idle management
    "${pkgs.hypridle}/bin/hypridle"
  ];

  # Environment variables
  wayland.windowManager.hyprland.settings.env = [
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_SIZE,24"
    "XCURSOR_THEME,Bibata-Modern-Classic"
    "HYPRCURSOR_THEME,Bibata-Modern-Classic"
    "QT_QPA_PLATFORMTHEME,qt5ct"
    "QT_STYLE_OVERRIDE,kvantum"
    "ICON_THEME,Papirus-Dark"
    "CURSOR_THEME,Bibata-Modern-Classic"
    "MOZ_ENABLE_WAYLAND,1"
    "NIXOS_OZONE_WL,1"
  ];
}
