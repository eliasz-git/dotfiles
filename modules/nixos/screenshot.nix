{ config, lib, pkgs, ... }:

{
  # Screenshot and screen recording tools
  home.packages = with pkgs; [
    grim        # Screenshot
    slurp       # Region selection
    swappy      # Screenshot annotation
    wf-recorder # Screen recording
    wl-clipboard # Wayland clipboard
  ];

  # Screenshot/recording directories. This file is imported at the Home-Manager
  # level (home.nix), where systemd.tmpfiles and config.users.users don't exist
  # — those are NixOS-only. home.file with a placeholder is the HM-native way
  # to make sure a directory exists.
  home.file."Pictures/Screenshots/.keep".text = "";
  home.file."Videos/.keep".text = "";

  # Screenshot keybindings are in bindings.nix:
  # SUPER+S             = area screenshot (grim + slurp) -> clipboard
  # SUPER+Shift+S       = full screenshot (grim) -> clipboard
  # SUPER+Ctrl+S        = area recording (wf-recorder + slurp) -> file
  # SUPER+Ctrl+Shift+S  = stop recording
  # SUPER+Print        = area screenshot (grim + slurp) -> clipboard
  # SUPER+Shift+Print  = full screenshot (grim) -> clipboard
  # SUPER+Ctrl+Print   = area recording (wf-recorder + slurp) -> file
  # SUPER+Ctrl+Shift+Print = stop recording (pkill wf-recorder)
}
