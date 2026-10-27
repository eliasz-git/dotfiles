{ config, lib, pkgs, ... }:

{
  # Hyprland input configuration
  wayland.windowManager.hyprland.settings.input = {
    kb_layout = "us";
    # Caps Lock acts as Super (Mod4) - matches $mod = SUPER
    kb_options = "caps:super";
    follow_mouse = 1;
    accel_profile = "flat"; # no mouse acceleration for games
    sensitivity = 0;
    touchpad = {
      natural_scroll = false;
      tap-to-click = true;
      tap-and-drag = true;
    };
  };
}