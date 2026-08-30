{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ── Host identity ───────────────────────────────────────────────
  networking.hostName = "mini1"; # infra — elias-server alias via DNS

  # ── Boot ────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "pcie_aspm=force" ];

  # ── Time / locale ───────────────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # ── Networking ──────────────────────────────────────────────────
  # Static .75 per your homelab docs. If your router does DHCP reservation,
  # just leave NetworkManager dhcp and reserve .75 there — simpler.
  networking.networkmanager.enable = true;
  # Uncomment to force static (adjust interface name after first boot):
  # networking.interfaces.enp0s25.ipv4.addresses = [{ address = "192.168.1.75"; prefixLength = 24; }];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "127.0.0.1" "1.1.1.1" ];

  # Tailscale — replaces WireGuard for remote access. `sudo tailscale up`.
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 41641 ]; # tailscale

  # ── SSH — key only ──────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  # Add your pubkey here post-install:
  # users.users.elias.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];

  # ── User ────────────────────────────────────────────────────────
  users.users.elias = {
    isNormalUser = true;
    description = "elias";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    # set via `passwd elias` on first boot, or use sops-nix / hashedPassword
  };
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # ── Storage ─────────────────────────────────────────────────────
  # 256GB SSD at / . External mounts go under /mnt/storage if you reattach.
  # The 2TB drive lives on mini2 — don't mount it here.
  # Example placeholder for a future backup USB:
  # fileSystems."/mnt/backup" = {
  #   device = "/dev/disk/by-label/BACKUP";
  #   fsType = "ext4";
  #   options = [ "nofail" "x-systemd.automount" ];
  # };

  # ── Memory — 16GB (spare stick would be DDR3L only for this box, max 16GB anyway) ──
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25; # ~4GB compressed swap, avoids OOM on Docker spikes
  };
  boot.kernel.sysctl."vm.swappiness" = 10;

  # ── Docker (compose is the default for your arr stacks elsewhere) ─
  # You said headless — Docker is the well-documented path (linuxserver images,
  # gluetun, etc.). Podman is more Nix-pure but needs extra compat shims for
  # compose; Docker Just Works.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };
  # lets `docker compose` work without separate package (new plugin)
  environment.systemPackages = with pkgs; [
    git vim nano htop btop curl wget
    docker-compose
  ];

  # Cockpit for web management at :9090 (optional, light)
  services.cockpit = {
    enable = true;
    openFirewall = true;
    port = 9090;
  };

  # ── DNS / ad-block ──────────────────────────────────────────────
  # AdGuard Home is lighter than Pi-hole in NixOS and has a native module.
  # Runs on :3000 (setup) and :53 (DNS). Front with Tailscale or LAN.
  services.adguardhome = {
    enable = false; # flip to true after first boot, visit http://mini1:3000
    openFirewall = true;
    mutableSettings = true;
    settings = {
      dns.bind_hosts = [ "0.0.0.0" ];
      filtering.rewrites = [];
    };
  };

  # ── Reverse proxy ───────────────────────────────────────────────
  services.caddy = {
    enable = false; # enable when you add domains; auto-HTTPS via Tailscale or ACME
    email = "eliaspublic@icloud.com";
    # virtualHosts."mini1.your-tailnet.ts.net".extraConfig = ''
    #   reverse_proxy localhost:9090
    # '';
  };

  # ── Firewall ────────────────────────────────────────────────────
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22   # ssh
    80 443 # caddy
    3000 # adguard setup
    9090 # cockpit
    8123 # home assistant (if you move it here later)
    8081 # metube
  ];

  # ── Nix ─────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # ── Power / UPS ─────────────────────────────────────────────────
  # Haswell desktop — no TLP needed like a laptop. Keep powertop autos tune optional.
  powerManagement.powertop.enable = false;
  services.apcupsd.enable = false; # enable if APC Smart-UPS 2200XL on USB is wired to this host

  # ── State ───────────────────────────────────────────────────────
  system.stateVersion = "25.05";
}
