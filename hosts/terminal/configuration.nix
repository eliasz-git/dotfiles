{ config, pkgs, ... }:

{
  imports = [ /etc/nixos/hosts/terminal/hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "cpufreq_stats" ];
  boot.kernelParams = [
    "pcie_aspm=force"
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
    "i915.enable_dc=2"
  ];

  networking.hostName = "icarus";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Auto-login to TTY1 — no display manager needed
  services.getty.autologinUser = "tundra";
  
  security.sudo.extraRules = [
  {
      users = [ "tundra" ];
      commands = [
        {
          command = "${pkgs.kbd}/bin/loadkeys";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.libinput.enable = true;
  services.pcscd.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];

  security.pam.u2f = {
    enable = true;
    control = "sufficient";
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_PRINTER = 1;
      WOL_DISABLE = "Y";
      NMI_WATCHDOG = 0;
    };
  };

  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint hplip ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  users.users.tundra = {
    isNormalUser = true;
    description = "tundra";
    extraGroups = [ "networkmanager" "wheel" "docker" "bluetooth" ];
    shell = pkgs.zsh;
  };

  console.keyMap = "colemak";

  environment.systemPackages = with pkgs; [
    nano wget curl git
    yubikey-manager yubikey-personalization yubico-pam pam_u2f
    mullvad-vpn
    cups
  ];

  virtualisation.docker.enable = true;
  programs.zsh.enable = true;
  services.openssh.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system.stateVersion = "25.05";
}