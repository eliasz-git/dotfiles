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

  # Screenshot directory
  systemd.tmpfiles.rules = [
    "d ${config.users.users.elias.home}/Pictures/Screenshots 0755 ${config.users.users.elias.name} users -"
    "d ${config.users.users.elias.home}/Videos 0755 ${config.users.users.elias.name} users -"
  ];

  # Screenshot keybindings are in bindings.nix:
  # SUPER+Print        = area screenshot (grim + slurp) -> clipboard
  # SUPER+Shift+Print  = full screenshot (grim) -> clipboard
  # SUPER+Ctrl+Print   = area recording (wf-recorder + slurp) -> file
  # SUPER+Ctrl+Shift+Print = stop recording (pkill wf-recorder)