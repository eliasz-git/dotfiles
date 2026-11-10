{ config, lib, pkgs, ... }:

{
  # Fuzzel — Wayland-native application launcher (replaces stale X11 rofi).
  # Active upstream, Rust-based, works natively under Wayland compositors
  # (Mango, Niri, Sway, Hyprland) without Xwayland.
  programs.fuzzel = {
    enable = true;
    # Config file is written by the importing home.nix via home.file.
  };

  home.file.".config/fuzzel/fuzzel.ini".text = ''
    [launcher]
    width=48
    height=22
    lines=11
    prompt=❯
    fuzzy=true
    case-sensitive=false
    font=JetBrainsMono Nerd Font:size=11

    [color]
    # Everforest Blue palette — fg, bg, border, separator, shadow
    normal=#d3c6aaff,#2d353bff,#343f44ff,#7fbbb3ff,#00000000
    selected=#2d353bff,#7fbbb3ff,#7fbbb3ff,#d3c6aaff,#00000000
    active=#7fbbb3ff,#2d353bff,#343f44ff,#7fbbb3ff,#00000000
    urgent=#e67e80ff,#2d353bff,#343f44ff,#e67e80ff,#00000000
    match=#dbbc7fff,#2d353bff,#343f44ff,#dbbc7fff,#00000000
'';
}
