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
  # Only unload when the running agent is not already using our real plist, so a
  # healthy daemon is left alone across ordinary rebuilds.
  home.activation.syncthingStrayProcess = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
    DOMAIN="gui/$(id -u)"
    LABEL="xyz.syncthing.agent"
    PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

    loaded_path="$(launchctl print "$DOMAIN/$LABEL" 2>/dev/null \
      | sed -n 's/^[[:space:]]*path = //p' | head -n 1)"
    if [[ -n "$loaded_path" && "$loaded_path" != "$PLIST" ]]; then
      launchctl bootout --wait "$DOMAIN/$LABEL" || true
    fi

    if ! launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
      pkill -x syncthing 2>/dev/null || true
    fi
  '';
}
