{ config, pkgs, ... }:
{
  imports = [
    (if builtins.pathExists ./hardware-configuration.nix
     then ./hardware-configuration.nix
     else if builtins.pathExists ../beattie/hardware-configuration.nix
     then ../beattie/hardware-configuration.nix
     else ../beattie/hardware-configuration.nix.example)
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = false;

  networking.hostName = "beattie";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # keep portals but no extensions installed here
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk ];
  };

  services.flatpak.enable = true;
  services.packagekit.enable = true;

  hardware.graphics.enable = true;
  hardware.enableAllFirmware = true;

  security.rtkit.enable = true;
  services.pipewire = { enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true; };
  hardware.bluetooth = { enable = true; powerOnBoot = true; };
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true;

  environment.variables.GSK_RENDERER = "ngl"; # fix for older intel vulkan -> ngl (research: discourse gsk)

  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint hplip epson-escpr brlaser cnijfilter2 ];
  };
  services.avahi = { enable = true; nssmdns4 = true; openFirewall = true; };

  users.users.demo = {
    isNormalUser = true;
    description = "Beattie Demo";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell = pkgs.zsh;
    initialPassword = "demo";
  };
  users.users.tundra = {
    initialPassword = "tundra";
    isNormalUser = true;
    description = "tundra";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell = pkgs.zsh;
  };
  security.sudo.extraRules = [{ users = [ "demo" ]; commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }]; }];

  # GDM 50 PAM fix - gnome-session not in PATH (github #523332)
  security.pam.services.gdm-launch-environment.rules.session.gnome-session-path = {
    order = config.security.pam.services.gdm-launch-environment.rules.session.systemd.order + 50;
    control = "required";
    modulePath = "''${config.security.pam.package}/lib/security/pam_env.so";
    settings = {
      conffile = let env = config.services.displayManager.generic.environment; in pkgs.writeText "gdm-launch-environment-env-conf" ''
        PATH DEFAULT="''${PATH}:''${pkgs.gnome-session}/bin"
        XDG_DATA_DIRS DEFAULT="''${XDG_DATA_DIRS}:''${env.XDG_DATA_DIRS}:''${pkgs.gdm}/share"
      '';
      readenv = 0;
    };
  };

  console.keyMap = "us";
  services.xserver.xkb = { layout = "us"; variant = ""; };

  environment.systemPackages = with pkgs; [
    git curl wget nano htop
    # gnome basics only - no extensions
    gnome-tweaks gnome-extension-manager gnome-software dconf-editor gnome-backgrounds
    bibata-cursors papirus-icon-theme everforest-gtk-theme adw-gtk3
    librewolf brave nautilus file-roller baobab gnome-disk-utility gnome-system-monitor
    gnome-calculator gnome-calendar loupe evince gnome-console kitty

    # diagnostic tools - for black screen debug
    inxi lshw pciutils usbutils dmidecode hwinfo mesa-demos vulkan-tools
    htop btop nvtopPackages.full smartmontools lm_sensors ethtool
    tldr cowsay fortune fastfetch
    vscodium gh wireshark nmap

    flatpak-builder
  ];

  programs.wireshark.enable = true;
  networking.firewall.allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
  networking.firewall.allowedUDPPortRanges = [{ from = 1714; to = 1764; }];

  virtualisation.docker.enable = true;
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  programs.dconf.enable = true;
  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono nerd-fonts.fira-code victor-mono inter noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji ];

  system.stateVersion = "25.05";
}
