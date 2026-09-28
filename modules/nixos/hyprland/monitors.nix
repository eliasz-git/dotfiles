{ config, lib, pkgs, ... }:

{
  # Hyprland monitor configuration
  wayland.windowManager.hyprland.settings.monitor = [
    # Any monitor, native resolution, highest refresh rate, auto position
    ",highrr,auto,1"
  ];

  # Monitor-specific rules (generated from hardware-configuration.nix ideally)
  # wayland.windowManager.hyprland.settings.monitor = [
  #   "eDP-1,1920x1080@120,0x0,1"
  #   "HDMI-A-1,1920x1080@60,1920x0,1"
  # ];
}