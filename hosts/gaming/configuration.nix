{ config, pkgs, lib, ... }:
let
  system = "x86_64-linux";
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # ── BASIC SYSTEM ──────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── KERNEL & CPU ─────────────────────────────────────────────
  # Ryzen 5 5600 optimized params (gaming-focused)
  boot.kernelParams = [
    "mitigations=off"  # Gaming performance — revert if unstable
    "amdgpu.vm_debugfs=1"
    "amdgpu.dpm=1"
    "amdgpu.gfx_v9_0.siar_support=0"
    "idle=poll"
    "processor.max_cstate=12"
    "processor.off=1"
  ];

  # ── NETWORK ──────────────────────────────────────────────────
  networking.hostName = "gaming-pc";
  networking.networkmanager.enable = true;

  # ── TIMEZONE & LOCAL ────────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── DISPLAY SERVER ───────────────────────────────────────────
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.videoDrivers = [ "amdgpu" ];

  # VRR/FreeSync for FHD 120Hz monitor
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
    Option "DRI" "3"
    Option "TripleBuffer" "true"
  '';

  # ── SOUND ────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ── POWER MANAGEMENT ────────────────────────────────────────
  # TLP is managed via Home Manager only (home.nix)
  # No system-level TLP configuration needed

  # ── KEYMAP & INPUT ──────────────────────────────────────────
  console.keyMap = "us";
  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };

  # ── EXTERNAL SERVICES ───────────────────────────────────────
  services.openssh.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  system.stateVersion = "25.11";
}