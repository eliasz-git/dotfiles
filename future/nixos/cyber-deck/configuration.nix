{ config, lib, pkgs, ... }:

{
  # Placeholder — future NixOS configuration for Portable Cyber Deck
  # Not yet active. See ~/Developer/portable-cyber-deck/ for active build.

  boot.kernelParams = [ "cma=256M" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = false;
  };

  networking.hostName = "cyber-deck";
  networking.networkmanager.enable = false;

  # Wi-Fi AP + router (to be implemented)
  # networking.wireless.enable = true;

  # Docker services (to be implemented)
  # virtualisation.docker.enable = true;

  # I2P + Tor (to be implemented)
  # services.i2pd.enable = true;
  # services.tor.enable = true;

  system.stateVersion = "24.11"; # Do not change lightly
}