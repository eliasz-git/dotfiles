{ config, pkgs, lib, hermes-agent, ... }:
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

  environment.interactiveShellInit = ''
    if [ "$TERM" = "xterm-ghostty" ]; then
      export TERM=xterm-256color
    fi
  '';


  # ── Networking ──────────────────────────────────────────────────
  # Static .75 per your homelab docs. If your router does DHCP reservation,
  # just leave NetworkManager dhcp and reserve .75 there — simpler.
  networking.networkmanager.enable = true;
  # Static 192.168.1.75 per homelab docs (was 192.168.68.x DHCP) — eno1 per mini1 ls
  networking.interfaces.eno1.ipv4.addresses = [{ address = "192.168.1.75"; prefixLength = 24; }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "127.0.0.1" "1.1.1.1" ];
  # Wifi for Home Assistant — wlp6s0 via NetworkManager (add SSID via nmcli or nmtui)
  # nmcli device wifi connect "SSID" password "PASS"  or  nmtui

  # Tailscale — replaces WireGuard for remote access. `sudo tailscale up`.
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 41641 111 2049 20048 ]; # tailscale + NFS

  # ── SSH — password + key (both minis have key) ─────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };
  users.users.elias.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFa0mPA2Wbc4JsyzHxjgBrQubUYAq0qXa/ZCyl4TNMj3 tundra-node@github"
  ];

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
  # 256GB SSD at / . 2TB STORAGE now on mini1 as NAS (moved from mini2).
  # Example placeholder for a future backup USB:
  # fileSystems."/mnt/backup" = {
  #   device = "/dev/disk/by-label/BACKUP";
  #   fsType = "ext4";
  #   options = [ "nofail" "x-systemd.automount" ];
  # };

  # ── NAS — 2TB STORAGE now on mini1 (moved from mini2) ─────────────
  # HDD at /dev/disk/by-uuid/04d77883-ba85-4992-af18-9862040416a2 mounted at /mnt/storage via hardware-configuration.nix
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/storage 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash) 100.64.0.0/10(rw,sync,no_subtree_check,no_root_squash)
  '';
  services.samba = {
    enable = true;
    openFirewall = true;
    settings.global = {
      workgroup = "WORKGROUP";
      "server string" = "mini1 NAS";
      security = "user";
    };
    shares.storage = {
      path = "/mnt/storage";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "valid users" = "elias";
    };
  };

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
  virtualisation.oci-containers.backend = "docker";
  # lets `docker compose` work without separate package (new plugin)
  environment.systemPackages = with pkgs; [
    git vim nano htop btop curl wget
    docker-compose
    smartmontools hdparm
    hermes-agent.packages.x86_64-linux.default
  ];

  # Cockpit for web management at :9090 (optional, light)
  services.cockpit = {
    enable = true;
    openFirewall = true;
    port = 9090;
  };

  # ── DNS / ad-block ──────────────────────────────────────────────
  services.adguardhome = {
    enable = true; # http://mini1:3000 + :53 DNS — AdGuard lighter than Pi-hole
    openFirewall = true;
    mutableSettings = true;
    settings = {
      dns.bind_hosts = [ "0.0.0.0" ];
      filtering.rewrites = [];
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ── Home Assistant — DOCKER (migrated 2026-09-01) ─────────────────
  # NixOS module disabled — now runs as Docker container for HACS/latest.
  # Config preserved at /mnt/storage/homeassistant (bind mount).
  # Compose lives at /etc/stacks/homeassistant/compose.yaml on mini1.
  # Backup: sudo tar -czf /mnt/storage/homeassistant-backup-$(date +%F).tgz -C /mnt/storage homeassistant
  services.home-assistant.enable = lib.mkForce false;

  # ── Cloudflared Tunnel — alt to Tailscale when VPN blocked ─────────
  # 1. cloudflared tunnel login  (on mini1, creates cert.pem in ~/.cloudflared)
  # 2. cloudflared tunnel create mini1  (gives Tunnel ID + credentials JSON)
  # 3. sudo mkdir -p /etc/cloudflared; sudo cp ~/.cloudflared/<ID>.json /etc/cloudflared/credentials.json
  # 4. Cloudflare Dashboard → DNS → CNAME  ha  → <ID>.cfargotunnel.com  (same for adguard, home)
  # 5. uncomment below, set tunnel ID, nixos-rebuild
  # services.cloudflared = {
  #   enable = true;
  #   tunnels."<TUNNEL-ID>" = {
  #     credentialsFile = "/etc/cloudflared/credentials.json";
  #     default = "http_status:404";
  #     ingress = {
  #       "ha.adal-matrix.ts.net" = "http://localhost:8123";
  #       "adguard.adal-matrix.ts.net" = "http://localhost:3000";
  #       "home.adal-matrix.ts.net" = "http://mini2:3000";
  #     };
  #   };
  # };

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
    8123 # home assistant docker (host mode)
    8081 # metube
    111  # rpcbind (NFS)
    2049 # nfs
    20048 # mountd (NFS)
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
  # nixpkgs.config.allowUnfree moved to flake.nix linuxPkgs (import nixpkgs { config.allowUnfree = true; })
  # nixpkgs.config.allowUnfree = true;


  # ── Syncthing — vault sync (replaces iCloud on Linux) ──────────
  services.syncthing = {
    enable = true;
    user = "elias";
    dataDir = "/home/elias/.config/syncthing";
    configDir = "/home/elias/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    overrideDevices = false;
    overrideFolders = false;
  };

  # ── Hermes Agent — always-on when Mac is closed ────────────────
  # Single profile at /home/elias/.hermes (same as Mac). Copy Mac's
  # ~/.hermes/config.yaml + ~/.hermes/.env + auth.json after first install, then
  # `hermes gateway install` for systemd service. Tailscale-only access fine at Beattie.
  # Install via: `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash` or `nix run github:NousResearch/hermes-agent`
  # ── Power / UPS ─────────────────────────────────────────────────
  # Haswell desktop — no TLP needed like a laptop. Keep powertop autos tune optional.
  powerManagement.powertop.enable = false;
  services.apcupsd.enable = false; # enable if APC Smart-UPS 2200XL on USB is wired to this host

  # ── State ───────────────────────────────────────────────────────
  system.stateVersion = "25.05";
}
