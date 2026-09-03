{ config, pkgs, ... }:

{
  imports = [
    (if builtins.pathExists ./hardware-configuration.nix
     then ./hardware-configuration.nix
     else ./hardware-configuration.nix.example)
  ];

  # ── Boot ──────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # use default kernel for max compat (was linuxPackages_latest - caused black screen on some hw)
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.plymouth.enable = false;

  # ── Networking ────────────────────────────────────────────────────
  networking.hostName = "beattie";
  networking.networkmanager.enable = true;

  # ── Locale ────────────────────────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── GNOME Desktop ─────────────────────────────────────────────────
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Exclude some default GNOME bloat but keep it beginner-friendly
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
  ];

  # Needed for screen sharing, flatpak portals, etc.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  # Flatpak for GUI app store (GNOME Software)
  services.flatpak.enable = true;
  # Enable GNOME Software to see flatpaks
  services.packagekit.enable = true;

  # ── Sound ─────────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Bluetooth ─────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ── Input ─────────────────────────────────────────────────────────
  services.libinput.enable = true;
  # Touchpad tap-to-click on by default (friendly)
  services.libinput.touchpad.tapping = true;

  # ── Printing ──────────────────────────────────────────────────────
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint hplip epson-escpr brlaser cnijfilter2
    ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ── Users — demo friendly ────────────────────────────────────────
  # Primary demo account — no password required for showcase.
  # Change password on first boot with `passwd demo` / `passwd student`.
  users.users.demo = {
    isNormalUser = true;
    description = "Beattie Demo";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell = pkgs.zsh;
    initialPassword = "demo";
  };
  # Also keep your account for admin
  users.users.tundra = {
    isNormalUser = true;
    description = "tundra";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell = pkgs.zsh;
  };

  # Allow passwordless sudo for demo (classroom convenience) — remove if you want security
  security.sudo.extraRules = [{
    users = [ "demo" ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];

  # Auto-login demo for instant showcase (optional — comment out to require login)
  # disabled for now - was causing fast black-screen loop if gdm failed
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = "demo";
  # };

  # ── Keymap — QWERTY by default for beginners ─────────────────────
  # (your laptop uses colemak — this host stays normal for students)
  console.keyMap = "us";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ── System packages — GNOME polish + beginner tools ───────────────
  environment.systemPackages = with pkgs; [
    # GNOME essentials
    gnome-tweaks
    gnome-extension-manager
    gnome-software
    dconf-editor
    gnome-shell-extensions
    gnome-backgrounds

    # Extensions — installed system-wide
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.just-perfection
    gnomeExtensions.vitals
    gnomeExtensions.arcmenu
    gnomeExtensions.user-themes
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.gsconnect

    # Cursor / icons / themes (same family as your laptop)
    bibata-cursors
    papirus-icon-theme
    everforest-gtk-theme
    adw-gtk3

    # Browsers
    librewolf
    brave

    # Files + tweaks
    nautilus
    file-roller
    baobab        # disk usage
    gnome-disk-utility
    gnome-system-monitor
    gnome-calculator
    gnome-calendar
    gnome-weather
    gnome-clocks
    gnome-characters
    gnome-font-viewer
    loupe         # image viewer (replaces eog)
    evince        # pdf

    # Terminal choices — GNOME Console for beginners + Kitty for you
    gnome-console
    kitty

    # Beginner-friendly helpers
    tldr
    cowsay fortune lolcat sl cmatrix
    fastfetch btop htop nvtopPackages.full

    # Fun / showcase
    hollywood
    pipes

    # Beginner dev
    vscodium
    gh

    # ── Cybersecurity Lab — full toolkit ─────────────────────────────
    # Network / recon
    wireshark
    nmap
    socat
    tcpdump
    netcat-gnu
    masscan
    amass
    gobuster
    ffuf
    wfuzz
    nuclei
    dnsutils
    whois
    # Web / appsec
    burpsuite
    zap
    sqlmap
    nikto
    # Cracking / crypto
    hashcat
    john
    hydra
    hashcat-utils
    hcxtools
    aircrack-ng
    # Forensics / reversing
    binwalk
    exiftool
    foremost
    sleuthkit
    ghidra
    radare2
    cutter
    binutils
    strace
    ltrace
    # Misc pentest
    metasploit
    exploitdb
    seclists

    # Flatpak helper
    flatpak-builder
  ];

  # Wireshark needs this
  programs.wireshark.enable = true;

  # Needed for GSConnect / KDE Connect firewall
  networking.firewall.allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
  networking.firewall.allowedUDPPortRanges = [{ from = 1714; to = 1764; }];

  # ── Docker — for class demos ──────────────────────────────────────
  virtualisation.docker.enable = true;

  # ── Shell ─────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  programs.dconf.enable = true;

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
    nerd-fonts.fira-code
    victor-mono
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Plymouth theme — keep boot pretty
  # boot.plymouth.theme = "bgrt";

  system.stateVersion = "25.05";
}
