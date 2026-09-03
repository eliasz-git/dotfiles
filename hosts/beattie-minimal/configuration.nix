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

  # ── KDE Plasma 6 minimal — same as beattie, no heavy cyber lab ─────
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };
  services.desktopManager.plasma6.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde xdg-desktop-portal-gtk ];
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

  environment.variables.GSK_RENDERER = "ngl";

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
    isNormalUser = true;
    description = "tundra";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell = pkgs.zsh;
    initialPassword = "tundra";
  };
  security.sudo.extraRules = [{ users = [ "demo" ]; commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }]; }];
  users.mutableUsers = true;

  console.keyMap = "us";
  services.xserver.xkb = { layout = "us"; variant = ""; };

  environment.systemPackages = with pkgs; [
    git curl wget nano htop
    kdePackages.discover kdePackages.kate kdePackages.konsole kdePackages.dolphin
    kdePackages.ark kdePackages.spectacle kdePackages.gwenview kdePackages.okular
    kdePackages.plasma-systemmonitor kdePackages.kcalc
    kdePackages.kdeconnect-kde kdePackages.sddm-kcm
    bibata-cursors papirus-icon-theme everforest-gtk-theme adw-gtk3
    kdePackages.breeze-gtk kdePackages.breeze-icons
    librewolf brave
    file-roller baobab gnome-disk-utility kitty
    tldr cowsay fortune lolcat fastfetch btop
    vscodium gh
    inxi lshw pciutils usbutils dmidecode hwinfo mesa-demos vulkan-tools smartmontools lm_sensors htop btop
    wireshark nmap
    flatpak-builder
  ];

  programs.wireshark.enable = true;
  programs.kdeconnect.enable = true;
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
