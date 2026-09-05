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

  # ── SMART — STORAGE disk health ───────────────────────────────
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.wall.enable = true;
    notifications.mail.enable = false;
  };

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

  # -- Home Assistant docker (oci-container) - auto-started via systemd docker-homeassistant
  virtualisation.oci-containers.containers.homeassistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    volumes = [
      "/mnt/storage/homeassistant:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];
    environment = {
      TZ = "America/New_York";
    };
    extraOptions = [
      "--network=host"
      "--privileged"
    ];
  };

  # -- Home Assistant — DOCKER (migrated 2026-09-01) ─────────────────
  # NixOS module disabled — now runs as Docker container for HACS/latest.
  # Config preserved at /mnt/storage/homeassistant (bind mount).
  # Compose lives at /etc/stacks/homeassistant/compose.yaml on mini1.
  # Backup: sudo tar -czf /mnt/storage/homeassistant-backup-$(date +%%F).tgz -C /mnt/storage homeassistant
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
    8010 # paperless
    3001 # uptime kuma
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
  # disable user service duplicate - system service is the one we use (0.0.0.0:8384)
  # the user service binds same port and fails with restart loop
  systemd.user.services.syncthing.enable = lib.mkForce false;

  # ── Lightweight backup — configs only (not full media) ──────────
  # Photos already iCloud, media re-downloadable. This backs up homeassistant,
  # syncthing config, and homepage data daily to /mnt/storage/backups.
  systemd.tmpfiles.rules = [
    "d /mnt/storage/backups 0755 elias users -"
    "d /mnt/storage/uptime-kuma 0755 elias users -"
    "d /mnt/storage/paperless 0755 elias users -"
    "d /mnt/storage/paperless/data 0755 elias users -"
    "d /mnt/storage/paperless/media 0755 elias users -"
    "d /mnt/storage/paperless/consume 0755 elias users -"
    "d /mnt/storage/paperless/export 0755 elias users -"
    "d /mnt/storage/paperless/pgdata 0755 elias users -"
    "d /mnt/storage/paperless/pgdata-redis 0755 elias users -"
  ];
  systemd.services.homelab-backup = {
    description = "homelab config backup to /mnt/storage/backups";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c \'mkdir -p /mnt/storage/backups && tar -czf /mnt/storage/backups/homeassistant-$(date +%%F).tgz --exclude=homeassistant/home-assistant_v2.db -C /mnt/storage homeassistant 2>/dev/null; tar -czf /mnt/storage/backups/syncthing-$(date +%%F).tgz -C /home/elias .config/syncthing 2>/dev/null; tar -czf /mnt/storage/backups/mini1-config-$(date +%%F).tgz -C /home/elias/.config nix-config 2>/dev/null; ls -t /mnt/storage/backups/homeassistant-*.tgz | tail -n +8 | xargs -r rm; ls -t /mnt/storage/backups/syncthing-*.tgz | tail -n +8 | xargs -r rm; ls -t /mnt/storage/backups/mini1-config-*.tgz | tail -n +8 | xargs -r rm; echo backup done $(date) >> /mnt/storage/backups/backup.log\'";
      User = "elias";
    };
  };
  systemd.timers.homelab-backup = {
    description = "daily homelab backup";
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "daily"; Persistent = true; Unit = "homelab-backup.service"; };
  };

  # ── Uptime Kuma — lightweight status monitor ────────────────────
  virtualisation.oci-containers.containers.uptime-kuma = {
    image = "louislam/uptime-kuma:1";
    ports = [ "3001:3001" ];
    volumes = [ "/mnt/storage/uptime-kuma:/app/data" ];
    extraOptions = [ "--pull=always" ];
  };
  systemd.services.tailscale-serve-status = {
    description = "Tailscale serve svc:status -> Uptime Kuma 3001";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service svc:status --https 443 --bg 3001";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service svc:status --https 443 off";
    };
  };


  # ── Paperless-NGX — document archive (mini1, english ocr) ───────
  # consume: /mnt/storage/paperless/consume (drop pdfs there, auto-ocr)
  # samba: \\mini1\storage\paperless or NFS /mnt/storage/paperless


  # paperless docker network (so paperless-db/redis/gotenberg resolve via name)
  systemd.services.docker-network-paperless = {
    description = "Create docker network paperless";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create paperless || true'";
      ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network rm paperless || true'";
    };
  };

  virtualisation.oci-containers.containers.paperless-redis = {
    image = "redis:7";
    volumes = [ "/mnt/storage/paperless/pgdata-redis:/data" ];
    extraOptions = [ "--network=paperless" "--pull=always" ];
  };
  virtualisation.oci-containers.containers.paperless-db = {
    image = "postgres:17";
    environment = {
      POSTGRES_DB = "paperless";
      POSTGRES_USER = "paperless";
      POSTGRES_PASSWORD = "paperless";
    };
    volumes = [ "/mnt/storage/paperless/pgdata:/var/lib/postgresql/data" ];
    extraOptions = [ "--network=paperless" "--pull=always" ];
  };
  virtualisation.oci-containers.containers.paperless-gotenberg = {
    image = "gotenberg/gotenberg:8";
    cmd = [ "gotenberg" "--api-timeout=300s" ];
    extraOptions = [ "--network=paperless" "--pull=always" ];
  };
  virtualisation.oci-containers.containers.paperless = {
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    ports = [ "8010:8000" ];
    dependsOn = [ "paperless-db" "paperless-redis" "paperless-gotenberg" ];
    environment = {
      PAPERLESS_REDIS = "redis://paperless-redis:6379";
      PAPERLESS_DBHOST = "paperless-db";
      PAPERLESS_DBNAME = "paperless";
      PAPERLESS_DBUSER = "paperless";
      PAPERLESS_DBPASS = "paperless";
      PAPERLESS_SECRET_KEY = "d12835f54bbd6283df54883d45a6cc6a228ef102d468110ed6cdc90654d4cd54";
      PAPERLESS_URL = "https://paperless.adal-matrix.ts.net";
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_TIME_ZONE = "America/New_York";
      PAPERLESS_OCR_MODE = "auto";
      PAPERLESS_CONSUMER_POLLING = "10";
      PAPERLESS_CONSUMER_RECURSIVE = "true";
      PAPERLESS_TIKA_ENABLED = "0";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paperless-gotenberg:3000";
      PAPERLESS_TIKA_ENDPOINT = "http://paperless-gotenberg:3000";
    };
    volumes = [
      "/mnt/storage/paperless/data:/usr/src/paperless/data"
      "/mnt/storage/paperless/media:/usr/src/paperless/media"
      "/mnt/storage/paperless/export:/usr/src/paperless/export"
      "/mnt/storage/paperless/consume:/usr/src/paperless/consume"
    ];
    extraOptions = [ "--network=paperless" "--pull=always" ];
  };

  # ensure paperless network exists before containers start
  systemd.services.docker-paperless-redis.after = [ "docker-network-paperless.service" ];
  systemd.services.docker-paperless-redis.wants = [ "docker-network-paperless.service" ];
  systemd.services.docker-paperless-db.after = [ "docker-network-paperless.service" ];
  systemd.services.docker-paperless-db.wants = [ "docker-network-paperless.service" ];
  systemd.services.docker-paperless-gotenberg.after = [ "docker-network-paperless.service" ];
  systemd.services.docker-paperless-gotenberg.wants = [ "docker-network-paperless.service" ];
  systemd.services.docker-paperless.after = [ "docker-network-paperless.service" ];
  systemd.services.docker-paperless.wants = [ "docker-network-paperless.service" ];

  systemd.services.tailscale-serve-paperless = {
    description = "Tailscale serve svc:paperless -> Paperless 8010";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service svc:paperless --https 443 --bg 8010";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service svc:paperless --https 443 off";
    };
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
