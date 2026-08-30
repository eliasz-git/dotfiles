{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

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
  # Static .76 if you want it pinned; otherwise DHCP reservation on router.
  # networking.interfaces.enp1s0.ipv4.addresses = [{ address = "192.168.1.76"; prefixLength = 24; }];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "192.168.1.75" "1.1.1.1" ]; # point at mini1 AdGuard when enabled

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 41641 ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.elias = {
    isNormalUser = true;
    description = "elias";
    extraGroups = [ "wheel" "networkmanager" "docker" "render" "video" ];
    shell = pkgs.zsh;
  };
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
    extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl mesa ];
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
    ffmpeg vaapiVdpau libva-utils # for `vainfo` testing
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

  # ── Tailscale Serve — persistent svc: hosts for Jellyfin/Navidrome ──
  # Persists `tailscale serve` across reboots (state is in /var/lib/tailscale, this re-applies on boot).
  # Requires tags tag:media/tag:music + ACL nodeAttrs funnel + grants svc:media/svc:music (already added).
  # Use the same tailscale package as the service (unstable 1.102.x, not stable 1.82.x which lacks --service svc:)
  systemd.services.tailscale-serve-media = {
    description = "Tailscale serve svc:media → Jellyfin 8096";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service svc:media --https 443 --bg 8096";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service svc:media --https 443 off";
    };
  };
  systemd.services.tailscale-serve-music = {
    description = "Tailscale serve svc:music → Navidrome 4533";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service svc:music --https 443 --bg 4533";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service svc:music --https 443 off";
    };
  };
  systemd.services.tailscale-serve-immich = {
    description = "Tailscale serve svc:immich → Immich 2283";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service svc:immich --https 443 --bg 2283";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service svc:immich --https 443 off";
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22    # ssh
    80 443
    8096 8920 # jellyfin
    2283 # immich
    4533 # navidrome
    9090 # cockpit
    9696 8989 7878 5055 9091 # prowlarr/sonarr/radarr/jellyseerr/transmission
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "25.05";
}
