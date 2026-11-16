{ config, lib, pkgs, ... }:

{
  # Shared Nix client settings — imported by every NixOS host.
  # Centralises experimental-features, store optimisation, and garbage
  # collection so hosts don't repeat the same boilerplate.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # cache.nixos.org returns SSL error 35 under default connection limits.
    # http-connections = 10 raises the ceiling so large binary-cache fetches
    # complete instead of failing mid-download. (Was previously only in
    # /etc/nix/nix.custom.conf on each host; now centralised in the repo.)
    http-connections = 10;
    # Cache flake input tarballs for 30 days so `nix flake update` doesn't
    # re-download (and re-rate-limit against) GitHub on every rebuild.
    tarball-ttl = "30 days";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
