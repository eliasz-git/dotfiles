{ config, pkgs, ... }:

{
  imports = [ /etc/nixos/nixos/hardware-configuration.nix ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "America/New_York";  # Change to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable SDDM for Wayland login with proper theme
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "chili";  # Using chili theme which supports customization
  };

  # XDG Portal for screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Enable touchpad support
  services.libinput.enable = true;

  # Define user account
  users.users.elias = {
    isNormalUser = true;
    description = "elias";
    extraGroups = [ "networkmanager" "wheel" "docker" "bluetooth" ];
    shell = pkgs.zsh;
  };

  # System packages including SDDM theme and cursor theme
  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    curl
    git
    librewolf
    kdePackages.dolphin
    bibata-cursors           # Cursor theme for SDDM and system-wide
    sddm-chili-theme         # Modern SDDM theme
  ];

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable SSH
  services.openssh.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    victor-mono
  ];

  system.stateVersion = "25.05";
}