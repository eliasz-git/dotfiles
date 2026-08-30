# Placeholder — replace after first NixOS install.
# On mini1, run:  nixos-generate-config --show-hardware-config > hosts/mini/1/hardware-configuration.nix
# Then `git add` and rebuild.
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "e1000e" ];
  boot.kernelModules = [ "kvm-intel" ];
  # boot.initrd.kernelModules = [];

  # Replace with real UUIDs from `blkid` after install:
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # STAGED for NAS move from mini2 → mini1 — uncomment after physically moving the 2TB drive:
  # fileSystems."/mnt/storage" = {
  #   device = "/dev/disk/by-uuid/04d77883-ba85-4992-af18-9862040416a2";
  #   fsType = "ext4";
  #   options = [ "nofail" "noatime" ];
  # };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
