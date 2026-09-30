{ config, lib, pkgs, ... }:

let
  cfg = config.services.homelabBackup;
in
{
  options.services.homelabBackup = {
    enable = lib.mkEnableOption "the homelab Restic backup job";
    repository = lib.mkOption {
      type = lib.types.str;
      default = "sftp:homelab-backup@desktop:/srv/backups/homelab-restic";
      description = "Restic repository on the separate desktop backup target.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/homelab-backup/restic-password";
      description = "Root-readable Restic password file, never stored in the Nix checkout.";
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/etc/nixos"
        "/etc/stacks"
        "/home/elias/.config/nix-config"
        "/var/lib/homelab-backup/exports"
        "/mnt/storage/appdata"
        "/mnt/storage/photos"
        "/mnt/storage/documents"
      ];
      description = "Paths to back up; exclude rebuildable media and caches by default.";
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/mnt/storage/appdata/*/cache"
        "/mnt/storage/appdata/*/transcodes"
        "/mnt/storage/downloads"
        "/mnt/storage/media/movies"
        "/mnt/storage/media/tv"
      ];
      description = "Rebuildable or low-priority data excluded from the backup.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.restic ];

    systemd.tmpfiles.rules = [
      "d /var/lib/homelab-backup 0700 root root -"
      "d /var/lib/homelab-backup/exports 0700 root root -"
    ];

    services.restic.backups.homelab = {
      inherit (cfg) repository passwordFile paths exclude;
      initialize = false;
      user = "root";
      timerConfig = {
        OnCalendar = "*-*-* 03:30:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
    };
  };
}
