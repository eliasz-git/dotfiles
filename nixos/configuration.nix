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

  # Enable SDDM for Wayland login
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "everforest";
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

  # Enable touchpad support
  services.libinput.enable = true;

  # Define user account
  users.users.{user} = {
    isNormalUser = true;
    description = "{user}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # SDDM Everforest theme
  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    curl
    git
    librewolf
    kdePackages.dolphin
    (pkgs.writeTextDir "share/sddm/themes/everforest/theme.conf" ''
      [General]
      background=${../../wallpapers/wallpaper.jpg}
      backgroundMode=scaled
      
      [Design]
      ThemeColor=#a7c080
      AccentColor=#7fbbb3
      BackgroundColor=#2d353b
      OverrideLoginBoxColor=#343f44
    '')
  ];

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable SSH
  services.openssh.enable = true;

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