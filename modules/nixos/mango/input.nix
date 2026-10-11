{ config, lib, pkgs, ... }:

{
  # Mango input configuration. Mango keeps keyboard settings under xkb_rules_*
  # and pointer/trackpad settings under mouse_*/trackpad_* globals.
  wayland.windowManager.mango.settings = {
    # Caps Lock acts as Super (Mod4) - matches $mod = SUPER throughout the
    # keybindings. This is the single invariant every binding relies on.
    xkb_rules_layout = "us";
    xkb_rules_options = "caps:super";

    # No mouse acceleration for games; mirrors Hyprland accel_profile = flat.
    mouse_accel_profile = 0; # 0 = none, 1 = flat, 2 = adaptive
    mouse_accel_speed = 0.0;

    # Tap-to-click and tap-and-drag are mango's default anyway; naming them
    # keeps the intent explicit. Mango spells them tap_* (pointer-global), not
    # the trackpad_* prefix the older Hyprland layout used.
    tap_to_click = true;
    tap_and_drag = true;
    trackpad_natural_scrolling = false;
  };
}