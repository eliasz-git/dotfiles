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

  # Power Management with TLP
  services.tlp = {
    enable = true;
    settings = {
      # CPU Settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;
      
      # Intel CPU Boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # Intel GPU Settings (11th Gen)
      INTEL_GPU_MIN_FREQ_ON_AC = 0;
      INTEL_GPU_MIN_FREQ_ON_BAT = 0;
      INTEL_GPU_MAX_FREQ_ON_AC = 1300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 800;
      INTEL_GPU_BOOST_FREQ_ON_AC = 1300;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 800;
      
      # Battery Care (Extend Battery Lifespan)
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
      
      # Platform Profile
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      
      # WiFi Power Saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # Runtime Power Management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      
      # USB Autosuspend
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_BTUSB = 0;
      USB_EXCLUDE_PHONE = 0;
      USB_EXCLUDE_PRINTER = 1;
      USB_EXCLUDE_WWAN = 0;
      
      # SATA Link Power Management
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "min_power";
      
      # PCIe Active State Power Management
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      
      # Disable Wake on LAN
      WOL_DISABLE = "Y";
      
      # Sound Power Saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
    };
  };

  # Thermal management for Intel CPUs
  services.thermald.enable = true;

  # Power profiles integration
  services.power-profiles-daemon.enable = true;

  # CPU Power Management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";  # Modern governor for 11th Gen Intel
    powertop.enable = true;
  };

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