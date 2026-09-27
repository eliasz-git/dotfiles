{ config, lib, pkgs, modulesPath, ... }:
{
  # Placeholder — real hardware config generated on first boot with nixos-generate-config
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "nvme" "r8169" ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/boot"; fsType = "vfat"; options = [ "fmask=0077" "dmask=0077" ]; };
  swapDevices = [ ];
  
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
