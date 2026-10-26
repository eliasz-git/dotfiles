{ config, pkgs, lib, ... }:

# Desktop — Ryzen 5 5600 + AMD Radeon GPU, Mango (Wayland), Steam.
# Apply on the machine:  sudo nixos-rebuild switch --flake ~/.config/nix-config#desktop
{
    imports = [
      ./hardware-configuration.nix
      ../../modules/system/themes.nix
      ../../modules/nixos/themes.nix
      ../../modules/nixos/sddm-theme.nix
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
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  # Wake-on-LAN. NixOS ships this as a udev .link (WakeOnLan=magic) applied at
  # device enumeration, so NetworkManager taking the interface does not clobber
  # it. BIOS ErP/Deep Sleep must be Disabled or the NIC loses standby power.
  networking.interfaces.enp4s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  # Tailnet transport: Moonlight from off-LAN without port forwarding, and the
  # path to `wakeonlan` on mini for remote wake. Run `sudo tailscale up` once
  # after the rebuild.
  services.tailscale.enable = true;

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

  # Puts ~/.local/bin on PATH through /etc/profile, which the SDDM session
  # wrapper sources, so Mango and everything it spawns can run the tundra-*
  # scripts that home.nix links there (bindings call tundra-screensaver by
  # name). The zsh initContent export only reaches interactive shells.
  environment.localBinInPath = true;

  # Provides pkgs.dconf via services.dbus.packages so the `ca.desrt.dconf`
  # D-Bus activation service exists for Home Manager's dconfSettings step
  # (gtk.enable in home.nix). It stopped leaking in transitively after the
  # 2026-10-10 nixpkgs bump.
  programs.dconf.enable = true;

  # ── GRAPHICS (AMD, Mesa/RADV) ─────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam / Proton need 32-bit GL + Vulkan
  };
  hardware.amdgpu.initrd.enable = true; # load amdgpu early so the console isn't stuck at low-res
  hardware.enableRedistributableFirmware = true; # amdgpu firmware blobs
  services.lact.enable = true; # AMD GPU fan/clock/power control (replaces radeon-profile)

  # ── DESKTOP: MANGO ──────────────────────────────────────────
  # Compositor + portals live here; the config lives in home.nix. The mango
  # flake module (imported in flake.nix) configures xdg-portal (wlr + gtk),
  # xwayland and polkit, and registers the Mango session for SDDM.
  programs.mango.enable = true;

  # Graphical SDDM login: a dark, image-capable surface fits the Omarchy/Tundra
  # visual language much better than a terminal greeter with ANSI colors.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
  };

  # Sunshine runs as a user service on graphical-session.target, so after a
  # reboot it does not exist until a session is up. Without auto-login a remote
  # wake would land on the greeter with no way in. swayidle locks at 300s and
  # before suspend (hosts/desktop/home.nix), so the unlocked window is brief.
  services.displayManager.autoLogin = {
    enable = true;
    user = "elias";
  };
  services.seatd.enable = true;
  services.displayManager.defaultSession = "mango";

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

  # ── REMOTE DESKTOP ────────────────────────────────────────────
  # Sunshine (Moonlight-compatible host): AMD AMF/VAAPI encode on the RX 6600,
  # capture through the Mango compositor's wlr-screencast via PipeWire.
  # capSysAdmin installs a setuid-cap wrapper for direct KMS capture and
  # cursor compositing; without it capture works but cursor handling is flaky.
  # Pair at https://<host>:47989 (self-signed), then add the host in Moonlight.
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
    autoStart = true;
  };

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
    wakeonlan # magic packets to mini/other hosts; MAC lives in /sys/class/net/enp4s0/address
    moonlight-qt # client, for testing the loopback from this machine
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
