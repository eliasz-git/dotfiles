{ config, lib, pkgs, ... }:

{
  # Clipboard manager with history (cliphist + wl-clipboard)
  programs.cliphist = {
    enable = true;
    # cliphist runs as a daemon: cliphist listen
    # Stores history in ~/.cache/cliphist
  };

  # Ensure wl-clipboard is available
  home.packages = with pkgs; [ wl-clipboard cliphist ];

  # Clipboard history keybinding (SUPER+V) is in bindings.nix
  # Uses: cliphist list | wofi --dmenu | cliphist decode | wl-copy

  # Optional: rofi-greenclip for rofi integration
  # programs.greenclip = {
  #   enable = true;
  # };
}