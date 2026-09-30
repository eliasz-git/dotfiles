{ config, pkgs, lib, ... }:

{
  # Syncthing runs as a launchd agent so it starts at login without a
  # terminal. The GUI binds to 127.0.0.1:8384 (config.xml is user-owned and
  # not managed here). Binary comes from modules/shared/programs.nix.
  home.file."Library/LaunchAgents/xyz.syncthing.agent.plist" = {
    executable = false;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>xyz.syncthing.agent</string>
        <key>ProgramArguments</key>
        <array>
          <string>${pkgs.syncthing}/bin/syncthing</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProcessType</key>
        <string>Background</string>
        <key>ThrottleInterval</key>
        <integer>10</integer>
        <key>EnvironmentVariables</key>
        <dict>
          <key>STNOUPGRADE</key>
          <string>1</string>
          <key>STNORESTART</key>
          <string>1</string>
        </dict>
        <key>StandardOutPath</key>
        <string>/tmp/syncthing.log</string>
        <key>StandardErrorPath</key>
        <string>/tmp/syncthing.err.log</string>
      </dict>
      </plist>
    '';
  };

  home.activation.syncthingAgent = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ST_UID="$(id -u)"
    PLIST="$HOME/Library/LaunchAgents/xyz.syncthing.agent.plist"
    DOMAIN="gui/$ST_UID"

    # A manually launched syncthing (or a stale agent) would race this one for
    # the config lock and port 8384, so clear both before loading.
    pkill -x syncthing 2>/dev/null || true
    launchctl bootout "$DOMAIN/xyz.syncthing.agent" 2>/dev/null || true

    if [ -f "$PLIST" ]; then
      launchctl bootstrap "$DOMAIN" "$PLIST" 2>/dev/null \
        || launchctl load -w "$PLIST" 2>/dev/null \
        || echo "syncthing: failed to load launch agent" >&2
    fi
  '';
}
