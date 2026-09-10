{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ../../../modules/nixos/tailscale-serve.nix ];

  networking.hostName = "mini2"; # media — elias-server2 alias via DNS

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "pcie_aspm=force" "amd_pstate=active" ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  environment.interactiveShellInit = ''
    if [ "$TERM" = "xterm-ghostty" ]; then
      export TERM=xterm-256color
    fi
  '';

  # ── Networking ──────────────────────────────────────────────────
  networking.networkmanager.enable = true;
  # Wired .76 static like mini1 .75 — eno1 is the real NIC (altname enp5s0f0, enx80e82c16c768)
  # Force NM to manual so DHCP 192.168.68.x never returns
  networking.networkmanager.ensureProfiles.profiles."Wired connection 1" = {
    connection = { id = "Wired connection 1"; type = "ethernet"; interface-name = "eno1"; };
    ipv4 = { method = "manual"; addresses = "192.168.1.76/24"; gateway = "192.168.1.1"; dns = "192.168.1.75;1.1.1.1;"; };
    ipv6.method = "disabled";
  };

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 41641 ];

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

  users.users.elias = {
    isNormalUser = true;
    description = "elias";
    extraGroups = [ "wheel" "networkmanager" "docker" "render" "video" "optical" ];
    shell = pkgs.zsh;
  };

  # ── Optical — DVD/Blu-ray auto-rip via ARM ────────────────────────
  services.udev.extraRules = ''KERNEL=="sr[0-9]*", MODE="0666", GROUP="optical"'';
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # ── Memory — 16GB now, spare 16GB laptop DDR4 stick would make 32GB (405 G4 supports 2x16). ──
  # You said don't count on it — so default is 16GB-safe with zram. If you do add it,
  # just bump `memoryPercent = 15` or disable zram.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };
  boot.kernel.sysctl."vm.swappiness" = 10;

  # ── Graphics / VAAPI (Vega 11) for Jellyfin transcode ───────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ libva-vdpau-driver libvdpau-va-gl mesa ];
  };
  hardware.enableRedistributableFirmware = true;

  # ── Docker — same reasoning as mini1: Docker+compose is the path with docs for *arr. ──
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };
  virtualisation.oci-containers.backend = "docker";

  environment.systemPackages = with pkgs; [
    git vim nano htop btop curl wget
    docker-compose
    ffmpeg libva-vdpau-driver libva-utils # for `vainfo` testing
    smartmontools hdparm
  ];

  # ── Media services — Nix-native where trivial, else Docker compose ─
  # Option A (native, simple): Jellyfin via NixOS module — uses VAAPI above.
  services.jellyfin = {
    enable = false; # flip true if you want nix-managed Jellyfin on :8096
    openFirewall = true;
  };

  # Option B (Docker compose, matches your old Ubuntu stack):
  # Put your compose at /etc/stacks/media/compose.yaml and enable:
  # virtualisation.oci-containers.containers handled by compose, not Nix.
  # Example compose will include: gluetun (Mullvad) -> transmission, prowlarr,
  # sonarr, radarr, jellyseerr, navidrome, immich. Keep it in git under
  # hosts/mini/2/stacks/ and symlink or `docker compose up -d`.
  # systemd.services.media-stack = {
  #   description = "media docker compose";
  #   after = [ "docker.service" "mnt-storage.mount" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     WorkingDirectory = "/etc/stacks/media";
  #     ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
  #     ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
  #   };
  # };

  # Cockpit optional on media too
  services.cockpit = {
    enable = true;
    openFirewall = true;
    port = 9090;
  };

  # ── Tailscale Serve — persistent svc: hosts for the media/homelab stack ──
  # Persists `tailscale serve` across reboots (state is in /var/lib/tailscale, this re-applies on boot).
  # Requires tags tag:media/tag:music + ACL nodeAttrs funnel + grants svc:media/svc:music (already added).
  # Applied via modules/nixos/tailscale-serve.nix (single serialized service —
  # 14 separate oneshot units used to race each other on tailscaled restart).
  services.tailscaleServe.services = {
    media       = { port = 8096; description = "Jellyfin"; };
    music       = { port = 4533; description = "Navidrome"; };
    photos      = { port = 2283; description = "Immich"; };
    home        = { port = 3000; description = "Homepage"; };
    radarr      = { port = 7878; };
    sonarr      = { port = 8989; };
    prowlarr    = { port = 9696; };
    seerr       = { port = 5055; };
    lidarr      = { port = 8686; description = "music *arr"; };
    rdt-client  = { port = 6500; description = "RDT-Client"; };
    arm         = { port = 8080; description = "Automatic Ripping Machine"; };
    maintainerr = { port = 6246; };
    bazarr      = { port = 6767; };
    tautulli    = { port = 8181; };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22    # ssh
    80 443
    3000 # homepage
    8096 8920 # jellyfin
    2283 # immich
    4533 # navidrome
    8080 # ARM (Automatic Ripping Machine)
    9090 # cockpit
    6767 # bazarr
    8181 # tautulli
    6500 # rdt-client (TorBox qBittorrent bridge for *arr)
    6246 # maintainerr
    9696 8989 7878 5055 9091 # prowlarr/sonarr/radarr/seerr/transmission
  ];

  # ── Ensures /downloads/lidarr etc exist for rdt-client -> Lidarr Remote Path Mappings
  # Lidarr health check is "download client places downloads in /downloads/lidarr but this directory
  # does not appear to exist inside the container" when host dir is missing. tmpfiles creates it
  # with correct ownership before docker starts, so docker exec lidarr ls -la /downloads/lidarr succeeds.
  # Containers share host path via same container path (/mnt/storage/downloads -> /downloads) so Remote
  # Path Mapping can be Remote=/downloads Local=/downloads (Host=rdt-client). If you switch rdt-client to
  # /data/downloads, change Local/Remote to /data/downloads accordingly.
  systemd.tmpfiles.rules = [
    "d /mnt/storage/downloads 0775 elias users -"
    "d /mnt/storage/downloads/lidarr 0775 elias users -"
    "d /mnt/storage/downloads/radarr 0775 elias users -"
    "d /mnt/storage/downloads/sonarr 0775 elias users -"
    "d /mnt/storage/music-archive 0775 elias users -"
    "d /mnt/storage/backups 0755 elias users -"
  ];
  # ── Navidrome cleaner — archive not-played music (dry-run logs, no delete until you approve) ──
  # Queries navidrome.db for tracks not played in 90 days, then unmonitors artist in Lidarr with deleteFiles=false (keeps files, moves to music-archive if you enable mv)
  # Run: sudo systemctl start navidrome-cleaner && cat /mnt/storage/backups/navidrome-clean.log
  systemd.services.navidrome-cleaner = let cleanScript = pkgs.writeShellScript "navidrome-cleaner" ''
    set -e
    LIDARR_KEY=$(grep -oP '(?<=<ApiKey>)[^<]+' /etc/stacks/media/data/lidarr/config.xml | head -n1)
    LIDARR_URL=http://localhost:8686
    NAVI_DB=/etc/stacks/media/data/navidrome/navidrome.db
    LOG=/mnt/storage/backups/navidrome-clean.log
    echo "[$(date -Iseconds)] navidrome-clean dry-run" >> "$LOG"
    if [ ! -f "$NAVI_DB" ]; then echo "no navidrome.db" >> "$LOG"; exit 0; fi
    ARTISTS=$(curl -s -H "X-Api-Key: $LIDARR_KEY" $LIDARR_URL/api/v1/artist | ${pkgs.jq}/bin/jq length)
    echo "lidarr artists: $ARTISTS" >> "$LOG"
    ${pkgs.sqlite}/bin/sqlite3 "$NAVI_DB" "SELECT artist, title, last_played_at, play_count FROM annotation LEFT JOIN media_file ON annotation.item_id=media_file.id WHERE (play_count=0 OR last_played_at < datetime(\'now\',\'-90 days\')) LIMIT 20;" >> "$LOG" 2>&1 || echo "sqlite query failed" >> "$LOG"
    echo "-- dry-run: would unmonitor artists with no play in 90d via Lidarr DELETE ?deleteFiles=false (keeps files, manual mv to /mnt/storage/music-archive if wanted)" >> "$LOG"
    echo "checked $(date)" >> "$LOG"
    cat "$LOG" | tail -n 20
  '' ; in {
    description = "navidrome music archive - unmonitor not-played 90d (keeps files)";
    after = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "elias";
      ExecStart = "${cleanScript}";
    };
  };
  systemd.timers.navidrome-cleaner = {
    description = "weekly navidrome archive check";
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "weekly"; Persistent = true; Unit = "navidrome-cleaner.service"; };
  };


  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };


  # NAS — 2TB STORAGE on mini1 (moved from mini2) - defined in hardware-configuration.nix
  # fileSystems."/mnt/storage" now in hardware-configuration.nix with IP 100.99.239.80

}
