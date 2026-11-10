{ config, lib, pkgs, ... }:

{
  # Shared Nix client settings — imported by every NixOS host.
  # Centralises experimental-features, store optimisation, and garbage
  # collection so hosts don't repeat the same boilerplate.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
