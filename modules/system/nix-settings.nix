{ config, lib, pkgs, ... }:

{
  # Shared Nix client settings — imported by every NixOS host.
  # Centralises experimental-features, store optimisation, garbage
  # collection, and binary caches so hosts don't repeat the same boilerplate.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # cache.nixos.org returns SSL error 35 under default connection limits.
    # http-connections = 10 raises the ceiling so large binary-cache fetches
    # complete instead of failing mid-download.
    http-connections = 10;
    # Cache flake input tarballs for 30 days so `nix flake update` doesn't
    # re-download (and re-rate-limit against) GitHub on every rebuild.
    tarball-ttl = "30 days";
    # Determinate flakehub binary cache — prebuilt substitutes so hosts never
    # compile rustc/nix/openssl from source again. Previously only on mini1;
    # now shared across all NixOS hosts.
    extra-substituters = [ "https://cache.flakehub.com" ];
    extra-trusted-substituters = [ "cache.flakehub.com" ];
    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
      "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
      "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
      "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
      "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
      "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
      "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
