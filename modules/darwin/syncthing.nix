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

  # A hand-started syncthing (or one left over from an unmanaged plist) holds
  # the config lock and port 8384, so the managed agent cannot come up. Kill
  # it only when the agent is not currently loaded, otherwise this would flap
  # the healthy daemon on every rebuild.
  home.activation.syncthingStrayProcess = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
    DOMAIN="gui/$(id -u)"
    if ! launchctl print "$DOMAIN/xyz.syncthing.agent" >/dev/null 2>&1; then
      pkill -x syncthing 2>/dev/null || true
    fi
  '';
}
