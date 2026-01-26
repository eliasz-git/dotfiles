{ config, pkgs, ... }:

{
  imports = [ /etc/nixos/nixos/hardware-configuration.nix ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules and parameters for power saving
  boot.kernelModules = [ "cpufreq_stats" ];
  boot.kernelParams = [ 
    "pcie_aspm=force"           # Force PCIe ASPM
    "i915.enable_psr=1"         # Intel panel self-refresh
    "i915.enable_fbc=1"         # Intel framebuffer compression
    "i915.enable_dc=2"          # Intel display C-states
  ];

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
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  # Enable touchpad support
  services.libinput.enable = true;

  services.pcscd.enable = true;

  # YubiKey U2F/FIDO2 support
  services.udev.packages = [ pkgs.yubikey-personalization ];
  
  security.pam.u2f = {
    enable = true;
    control = "sufficient";  # Try YubiKey, fall back to password
  };
  
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    swaylock.u2fAuth = true;
  };

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
      CPU_MAX_PERF_ON_BAT = 20;
      
      # Intel CPU Boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # Intel GPU Settings (11th Gen)
      INTEL_GPU_MIN_FREQ_ON_AC = 0;
      INTEL_GPU_MIN_FREQ_ON_BAT = 0;
      INTEL_GPU_MAX_FREQ_ON_AC = 1300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 600;
      INTEL_GPU_BOOST_FREQ_ON_AC = 1300;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 600;
      
      # Battery Care (Extend Battery Lifespan)
      # NOTE: HP ProBook 450 G8 doesn't support charge thresholds via tlp/hp-wmi
      # Use BIOS "HP Battery Health Manager" -> "Maximum battery health" for 80% limit
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
      
      # NMI Watchdog (saves ~1W)
      NMI_WATCHDOG = 0;
      
      # Allow runtime PM for all drivers
      RUNTIME_PM_DRIVER_DENYLIST = "";
      
      # USB autosuspend for all devices (disable allowlist)
      USB_ALLOWLIST = "";
    };
  };

  # Thermal management for Intel CPUs
  services.thermald.enable = true;

  # Disable power-profiles-daemon as it conflicts with TLP
  services.power-profiles-daemon.enable = false;

  # CPU Power Management
  powerManagement = {
    enable = true;
    # Note: cpuFreqGovernor is managed by TLP, not set here to avoid conflicts
    powertop.enable = true;
  };

  # PowerTOP auto-tune at boot
  systemd.services.powertop-autotune = {
    description = "PowerTOP auto-tune";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
    };
  };

  # Runtime PM rules for maximum power saving
  services.udev.extraRules = ''
    # Enable runtime PM for PCI devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    
    # Enable runtime PM for USB devices
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    
    # Enable runtime PM for SCSI devices
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
    
    # Disable wake-on-LAN
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="enp*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
    
    # Intel GPU power saving
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto"
  '';

  # Define user account
  users.users.{user} = {
    isNormalUser = true;
    description = "{user}";
    extraGroups = [ "networkmanager" "wheel" "docker" "bluetooth" ];
    shell = pkgs.zsh;
  };

  # System packages including SDDM theme and cursor theme
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    git
    librewolf
    xfce.thunar
    xfce.thunar-archive-plugin
    bibata-cursors           # Cursor theme for SDDM and system-wide
    sddm-chili-theme         # Modern SDDM theme
    networkmanagerapplet
    yubikey-manager
    yubikey-personalization
    yubico-pam
    pam_u2f
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