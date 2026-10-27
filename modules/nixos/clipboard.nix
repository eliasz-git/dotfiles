{
  config, lib, pkgs, ... }:

{
  # Clipboard manager with history (cliphist + wl-clipboard)
  # programs.cliphist removed - handled via Home Manager home.packages
  home.packages = with pkgs; [
    wl-clipboard
    cliphist
  ];

  # Clipboard history keybinding (SUPER+V) is in bindings.nix
  # Uses: cliphist list | rofi -dmenu | cliphist decode | wl-copy

  # Optional: rofi-greenclip for rofi integration
  # programs.greenclip = {
  #   enable = true;
  # };
}
