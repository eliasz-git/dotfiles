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
  # Primary 2 TB storage is physically on mini1; mini2 consumes it via NFS.
  fileSystems."/mnt/storage" = {
    device = "192.168.1.75:/mnt/storage";
    fsType = "nfs4";
    options = [ "nofail" "x-systemd.automount" "x-systemd.device-timeout=10s" "noatime" "hard" "timeo=600" "retrans=3" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
