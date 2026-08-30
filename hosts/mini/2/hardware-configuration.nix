# Placeholder — replace after first NixOS install on mini2.
# On mini2, run: nixos-generate-config --show-hardware-config > hosts/mini/2/hardware-configuration.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "r8169" ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];
  # boot.initrd.kernelModules = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  # STAGED: HDD currently on mini2 — keep local mount for now.
  # After moving 2TB to mini1 as NAS, replace with NFS mount:
  # fileSystems."/mnt/storage" = {
  #   device = "mini1:/mnt/storage";
  #   fsType = "nfs";
  #   options = [ "nofail" "x-systemd.automount" "noatime" "soft" "timeo=100" ];
  # };
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/04d77883-ba85-4992-af18-9862040416a2";
    fsType = "ext4";
    options = [ "nofail" "noatime" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
