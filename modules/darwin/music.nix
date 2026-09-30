{ config, lib, ... }:

let
  # Last.fm password is an agenix secret (modules/shared/secrets.nix) that is
  # only readable once the per-host decrypt agent has run. The scrobbler is
  # therefore started through a wrapper that waits for the credential instead of
  # baking a password into a config at activation time.
  passwordFile = "${config.home.homeDirectory}/.config/mpdscribble/lastfm-password";
  generatedConf = "${config.home.homeDirectory}/.cache/mpdscribble/lastfm.conf";
  label = "com.elias.mpd";
  scribbleLabel = "com.elias.mpdscribble";
in
{
  # Mirrors hosts/nixos/home.nix, with the macOS CoreAudio sink instead of PipeWire.
  # mpd/rmpc stay brew-declared in configuration.nix to skip darwin builds; only
  # the config and the daemon lifecycle live here.
  home.file.".mpd/mpd.conf".text = ''
    music_directory     "~/Music"
    playlist_directory  "~/.mpd/playlists"
    db_file             "~/.mpd/database"
    log_file            "~/.mpd/log"
    pid_file            "~/.mpd/pid"
    state_file          "~/.mpd/state"
    sticker_file        "~/.mpd/sticker.sql"
    port                "6600"
    bind_to_address     "127.0.0.1"
    auto_update         "yes"
    follow_outside_symlinks "yes"
    follow_inside_symlinks "yes"
    log_level           "default"

    audio_output {
      type      "osx"
      name      "Mac OS X"
      mixer_type "software"
    }
  '';

  home.file.".local/bin/mpdscribble-lastfm" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Started by com.elias.mpdscribble.plist. Regenerates the scrobbler config
      # from the agenix-managed Last.fm password, then execs mpdscribble.
      set -eu

      CONF="$HOME/.cache/mpdscribble/lastfm.conf"
      PW="$HOME/.config/mpdscribble/lastfm-password"

      waited=0
      while [ ! -s "$PW" ] && [ "$waited" -lt 30 ]; do
        waited=$((waited + 1))
        sleep 1
      done
      if [ ! -s "$PW" ]; then
        echo "mpdscribble: no Last.fm password at $PW (agenix has not decrypted it yet)" >&2
        exit 1
      fi

      umask 077
      mkdir -p "$(dirname "$CONF")"
      cat > "$CONF" <<EOF
      verbose = 1

      [last.fm]
      url = https://post.audioscrobbler.com/
      username = quasar327
      password = $(head -n1 "$PW")
      journal = $HOME/.cache/mpdscribble/lastfm.journal
      EOF
      chmod 600 "$CONF"

      exec /opt/homebrew/bin/mpdscribble --conf "$CONF"
    '';
  };

  home.file."Library/LaunchAgents/${label}.plist" = {
    executable = false;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>${label}</string>
        <key>ProgramArguments</key>
        <array>
          <string>/opt/homebrew/bin/mpd</string>
          <string>--no-daemon</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProcessType</key>
        <string>Background</string>
        <key>ThrottleInterval</key>
        <integer>10</integer>
        <key>StandardOutPath</key>
        <string>/tmp/mpd.log</string>
        <key>StandardErrorPath</key>
        <string>/tmp/mpd.err.log</string>
      </dict>
      </plist>
    '';
  };

  home.file."Library/LaunchAgents/${scribbleLabel}.plist" = {
    executable = false;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>${scribbleLabel}</string>
        <key>ProgramArguments</key>
        <array>
          <string>${config.home.homeDirectory}/.local/bin/mpdscribble-lastfm</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProcessType</key>
        <string>Background</string>
        <key>ThrottleInterval</key>
        <integer>10</integer>
        <key>StandardOutPath</key>
        <string>/tmp/mpdscribble.log</string>
        <key>StandardErrorPath</key>
        <string>/tmp/mpdscribble.err.log</string>
      </dict>
      </plist>
    '';
  };

  home.activation.mpdLastfm = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    DOMAIN="gui/$(id -u)"

    pkill -x mpd 2>/dev/null || true
    pkill -x mpdscribble 2>/dev/null || true
    launchctl bootout "$DOMAIN/${label}" 2>/dev/null || true
    launchctl bootout "$DOMAIN/${scribbleLabel}" 2>/dev/null || true

    for plist in "${label}" "${scribbleLabel}"; do
      file="$HOME/Library/LaunchAgents/$plist.plist"
      [ -f "$file" ] || continue
      launchctl bootstrap "$DOMAIN" "$file" 2>/dev/null \
        || launchctl load -w "$file" 2>/dev/null \
        || echo "$plist: failed to load launch agent" >&2
    done
  '';
}
