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
    command=foot -e {}
    width=60
    lines=10
    prompt=>

    [color]
    normal=#2d353bff,#d3c6aaff,#2d353bff,#7fbbb3ff,#d3c6aaff
    selected=#7fbbb3ff,#2d353bff,#7fbbb3ff,#d3c6aaff,#2d353bff
    active=#a7c080ff,#2d353bff,#a7c080ff,#d3c6aaff,#2d353bff
    urgent=#e67e80ff,#2d353bff,#e67e80ff,#d3c6aaff,#2d353bff
  '';
}
