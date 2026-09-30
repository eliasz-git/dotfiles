{ config, pkgs, lib, ... }:

{
  # Syncthing runs as a launchd agent so it starts at login without a
  # terminal. The GUI binds to 127.0.0.1:8384 (config.xml is user-owned and
  # not managed here). Binary comes from modules/shared/programs.nix.
  #
  # Declared through `launchd.agents`, not `home.file`: Home Manager links
  # home.file targets as symlinks into /nix/store, and launchd refuses to load
  # an agent whose plist is a store symlink, which is why the previous version
  # of this module printed "failed to load launch agent" on every rebuild.
  launchd.agents."xyz.syncthing.agent" = {
    # launchd.agents.<name>.enable defaults to false, so this is required.
    enable = true;
    config = {
      # Keep the existing label; Home Manager would otherwise rename the agent
      # to org.nix-community.home.* and orphan the running one.
      Label = "xyz.syncthing.agent";
      ProgramArguments = [ "${pkgs.syncthing}/bin/syncthing" ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      ThrottleInterval = 10;
      EnvironmentVariables = {
        # A syncthing upgraded outside Nix should not nag, and a crash-looping
        # one should not restart itself before the log is read.
        STNOUPGRADE = "1";
        STNORESTART = "1";
      };
      StandardOutPath = "/tmp/syncthing.log";
      StandardErrorPath = "/tmp/syncthing.err.log";
    };
  };

  # Two ways a hand-started or previously-store-symlinked syncthing keeps the
  # managed agent from coming up, so resolve both before Home Manager bootstraps:
  #
  # 1. Stale label registration. Home Manager's processAgent only calls
  #    bootoutAgent when the destination plist still exists, and the orphan-link
  #    cleanup earlier in the same activation deletes it. An agent still
  #    registered from an older /nix/store plist therefore survives, and the new
  #    bootstrap fails with "I/O error (code 5)" against the taken label.
  # 2. A stray process holding the config lock and port 8384.
  #
  # A symlinked or missing plist is exactly the stale case, since a healthy
  # generation always leaves a real file there.
  #
  # Two constraints on this entry. Home Manager runs the whole activation under
  # `set -eu -o pipefail` and inlines the body into the main script, so: no pipes
  # (a `head -n 1` on `launchctl print` gives the writer SIGPIPE, and pipefail
  # turns that into a silent abort of the whole rebuild), and no `exit`, which
  # would terminate the activation script itself.
  home.activation.syncthingStrayProcess = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
    DOMAIN="gui/$(id -u)"
    LABEL="xyz.syncthing.agent"
    PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

    if [[ -L "$PLIST" || ! -f "$PLIST" ]]; then
      launchctl bootout --wait "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
    fi

    if ! launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
      pkill -x syncthing >/dev/null 2>&1 || true
    fi
  '';
}
