{ config, lib, pkgs, ... }:

# ── iCloud on Linux ─────────────────────────────────────────────────────
# Apple makes no iCloud client for Linux. This module bridges the gap with
# third-party tools:
#
#   icloudpd        — download iCloud Photos (originals)
#   rclone          — generic cloud sync (Dropbox, Drive, S3, …)
#   python3 + pip   — icloud-export uses a venv at ~/icloud-venv with the
#                     `icloud` PyPI package to export Drive, Notes, Contacts,
#                     Calendar, Reminders, Bookmarks
#
# Scripts are deployed to ~/.local/bin via home.file in hosts/desktop/home.nix.
# First run of either iCloud script is interactive: Apple ID password + 2FA on a
# trusted device; the session is remembered afterwards.

let
  icloudDir = "${config.home.homeDirectory}/icloud-venv";
in {
  home.sessionVariables = {
    ICLOUD_USERNAME   = "";   # set your Apple ID before running icloud-photos-sync
    ICLOUD_APPLE_ID   = "";   # set your Apple ID before running icloud-export
    ICLOUD_PHOTOS_DIR = "${config.home.homeDirectory}/Pictures/iCloud Photos";
    ICLOUD_EXPORT_DIR = "${config.home.homeDirectory}/iCloud-export";
  };

  home.packages = with pkgs; [
    rclone
    icloudpd
    python3
    python3Packages.pip
    gnupg   # keyring / password storage for pyicloud
    curl
    wget
  ];

  # Optional daily iCloud Photos sync. Enable the timer after rebuild with:
  #   systemctl --user enable --now icloud-photos-sync.timer
  systemd.user.services."icloud-photos-sync" = {
    serviceConfig = {
      Environment = "ICLOUD_USERNAME=you@icloud.com";
      ExecStart = "${config.home.homeDirectory}/.local/bin/icloud-photos-sync --recent-days 7";
    };
  };
  systemd.user.timers."icloud-photos-sync" = {
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    serviceConfig = {
      Environment = "ICLOUD_USERNAME=you@icloud.com";
    };
  };
}
