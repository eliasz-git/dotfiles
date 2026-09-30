{ config, lib, ... }:

let
  # Last.fm password lives OUTSIDE the repo, in ~/.config/mpdscribble/lastfm-password
  # (chmod 600, just the password on one line). The scrobbler config is generated
  # from it at activation so no credential is ever committed.
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
          <string>/opt/homebrew/bin/mpdscribble</string>
          <string>--conf</string>
          <string>${generatedConf}</string>
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
    SCRIBBLE_CONF="$HOME/.cache/mpdscribble/lastfm.conf"

    umask 077
    mkdir -p "$HOME/.cache/mpdscribble"
    if [ -r "$HOME/.config/mpdscribble/lastfm-password" ]; then
      cat > "$SCRIBBLE_CONF" <<EOF
    verbose = 1

    [last.fm]
    url = https://post.audioscrobbler.com/
    username = quasar327
    password = $(head -n1 "$HOME/.config/mpdscribble/lastfm-password")
    journal = $HOME/.cache/mpdscribble/lastfm.journal
    EOF
    else
      echo "mpdscribble: missing $HOME/.config/mpdscribble/lastfm-password" \
        "(put your Last.fm password in it, chmod 600); scrobbler will stay down" >&2
      rm -f "$SCRIBBLE_CONF"
    fi
    chmod 600 "$SCRIBBLE_CONF" 2>/dev/null || true

    pkill -x mpd 2>/dev/null || true
    pkill -x mpdscribble 2>/dev/null || true
    launchctl bootout "$DOMAIN/${label}" 2>/dev/null || true
    launchctl bootout "$DOMAIN/${scribbleLabel}" 2>/dev/null || true

    if [ -f "$HOME/Library/LaunchAgents/${label}.plist" ]; then
      launchctl bootstrap "$DOMAIN" "$HOME/Library/LaunchAgents/${label}.plist" 2>/dev/null \
        || launchctl load -w "$HOME/Library/LaunchAgents/${label}.plist" 2>/dev/null \
        || echo "mpd: failed to load launch agent" >&2
    fi

    if [ -f "$SCRIBBLE_CONF" ]; then
      launchctl bootstrap "$DOMAIN" "$HOME/Library/LaunchAgents/${scribbleLabel}.plist" 2>/dev/null \
        || launchctl load -w "$HOME/Library/LaunchAgents/${scribbleLabel}.plist" 2>/dev/null \
        || echo "mpdscribble: failed to load launch agent" >&2
    fi
  '';
}
