{ config, pkgs, lib, ... }:

# Standalone Home Manager entry for iCloud + Orthodox tools.
#
# Apply with: home-manager switch -f ~/.config/dotfiles/standalone-dotfiles/icloud-orthodox.nix
#
# The full desktop integration (theming, Mango, etc.) lives in
# hosts/desktop/home.nix and is applied via `nixos-rebuild switch --flake
# ~/.config/dotfiles#desktop` (requires sudo). This standalone entry lets you
# use the iCloud and Orthodox tools today without a system rebuild.

{
  home.stateVersion = "26.05";
  home.username = "elias";
  home.homeDirectory = "/home/elias";

  imports = [
    ../modules/home/icloud.nix
    ../modules/home/orthodox.nix
  ];

  home.file = {
    ".local/bin/icloud-photos-sync".source = ../scripts/icloud/icloud-photos-sync;
    ".local/bin/icloud-export".source = ../scripts/icloud/icloud-export;
    ".local/bin/orthodox-readings".source = ../scripts/orthodox/orthodox-readings;
    ".local/bin/dormition".source = ../scripts/orthodox/dormition;
  };
}
