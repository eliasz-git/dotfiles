{ config, pkgs, lib, ... }:

# Gaming PC — Ryzen 5 5600 + AMD Radeon GPU, Hyprland (Wayland), Steam.
# Apply on the machine:  sudo nixos-rebuild switch --flake ~/.config/nix-config#gaming-pc
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/themes.nix
    ../../modules/nixos/themes.nix
  ];

  # System-level theme registry and optional Swaylock fallback, plus the
  # `tundra-theme` binary) is gated behind this flag in modules/system/themes.nix
  # and modules/nixos/themes.nix — without it those modules are dead code even
  # though they're imported. home.nix sets the matching HM-level flag.
  tundra.enable = true;
  tundra.theme = "everforest-blue";

  # ── BOOT ──────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Zen 3 P-state driver. Falls back to acpi-cpufreq on its own if the BIOS
  # has CPPC turned off, so it is safe either way.
  boot.kernelParams = [ "amd_pstate=active" ];

  # ── NETWORK ───────────────────────────────────────────────────
  networking.hostName = "gaming-pc";
  networking.networkmanager.enable = true;

  # ── LOCALE ────────────────────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # ── USER ──────────────────────────────────────────────────────
  users.users.elias = {
    isNormalUser = true;
    description = "elias";
    extraGroups = [ "wheel" "networkmanager" "video" "render" "input" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFa0mPA2Wbc4JsyzHxjgBrQubUYAq0qXa/ZCyl4TNMj3 tundra-node@github"
    ];
  };
  programs.zsh.enable = true;

  # ── GRAPHICS (AMD, Mesa/RADV) ─────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam / Proton need 32-bit GL + Vulkan
  };
  hardware.amdgpu.initrd.enable = true; # load amdgpu early so the console isn't stuck at low-res
  hardware.enableRedistributableFirmware = true; # amdgpu firmware blobs
  services.lact.enable = true; # AMD GPU fan/clock/power control (replaces radeon-profile)

  # ── DESKTOP: HYPRLAND ─────────────────────────────────────────
  # Compositor + portals live here; the config lives in home.nix.
  programs.hyprland.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Graphical SDDM login: a dark, image-capable surface fits the Omarchy/Tundra
  # visual language much better than a terminal greeter with ANSI colors.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
    theme = "${pkgs.sddm-sugar-dark}/share/sddm/themes/sugar-dark";
  };
  services.displayManager.defaultSession = "hyprland";

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Electron/Chromium apps on Wayland

  # ── GAMING ────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # Controller/keyboard remapping. Udev rules for hotplug are left off (upstream
  # default): https://github.com/sezanzeb/input-remapper/issues/140 — devices
  # plugged in before the service starts still work; hotplugged ones need
  # `sudo systemctl restart input-remapper` until that's fixed.
  services.input-remapper.enable = true;

  # ── SOUND ─────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # 32-bit games / Wine
    pulse.enable = true;
  };

  # ── BLUETOOTH ─────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ── POWER ─────────────────────────────────────────────────────
  # Desktop: no TLP (it is laptop-oriented). power-profiles-daemon is enough.
  services.power-profiles-daemon.enable = true;
  zramSwap.enable = true;

  # ── INPUT ─────────────────────────────────────────────────────
  services.libinput.enable = true;

  # ── SERVICES ──────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Desktop Syncthing service for vault and selected workstation folders.
  services.syncthing = {
    enable = true;
    user = "elias";
    dataDir = "/home/elias/.config/syncthing";
    configDir = "/home/elias/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:8384";
    overrideDevices = false;
    overrideFolders = false;
  };
  systemd.user.services.syncthing.enable = lib.mkForce false;

  # ── FONTS & PACKAGES ──────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  environment.systemPackages = with pkgs; [
    git vim nano curl wget htop pciutils smartmontools usbutils
  ];

  # ── SECOND SSD: Steam Games Library ─────────────────────────────
  # nvme0n1p2 — the first SSD (gaming drive) with existing Steam games
  fileSystems."/Games" = {
    device = "/dev/disk/by-uuid/14882C93882C7580";
    fsType = "ntfs3";
    # Keep boot resilient if the data drive is temporarily unavailable, then
    # mount it on first access so Steam sees the library at its stable path.
    options = [ "uid=1000" "gid=1000" "umask=022" "nofail" "x-systemd.automount" ];
  };

  # Monitor both internal NVMe drives for failing sectors and controller health.
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.wall.enable = true;
    notifications.mail.enable = false;
  };

  # ── NIX ───────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "26.05";
}
