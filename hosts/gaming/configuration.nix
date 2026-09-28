{ config, pkgs, lib, ... }:

# Gaming PC — Ryzen 5 5600 + AMD Radeon GPU, Hyprland (Wayland), Steam.
# Apply on the machine:  sudo nixos-rebuild switch --flake ~/.config/nix-config#gaming-pc
{
  imports = [
      ../../modules/system/themes.nix
      ../../modules/nixos/themes.nix
      ./configuration/hardware-configuration.nix
    ];

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
  # Change the password on first login (`passwd`). SSH is key-only, so this
  # password is only usable at the keyboard.
  users.users.elias = {
    isNormalUser = true;
    description = "elias";
    extraGroups = [ "wheel" "networkmanager" "video" "render" "input" ];
    shell = pkgs.zsh;
    initialPassword = "changeme";
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

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      user = "greeter";
    };
  };

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

  # ── FONTS & PACKAGES ──────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  environment.systemPackages = with pkgs; [
    git vim nano curl wget htop pciutils usbutils
    # Theme system
    tundra-theme
    # CLI tool
    (pkgs.writeScriptBin "tundra" (builtins.readFile ./scripts/tundra-cli.sh))
  ];

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
