{ config, pkgs, lib, ... }:

{
  home.file.".config/sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
      #!/bin/sh
      PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
      sketchybar --bar position=top height=32 margin=4 y_offset=4 corner_radius=9 border_width=0 blur_radius=20 color=0xE604182F padding_left=8 padding_right=8 notch_width=0
      default=(padding_left=4 padding_right=4 icon.font="JetBrainsMono Nerd Font:Bold:12.0" label.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=0xff68A2C6 label.color=0xff68A2C6 background.height=22 background.corner_radius=6 icon.padding_left=6 icon.padding_right=6 label.padding_left=0 label.padding_right=6)
      sketchybar --default "''${default[@]}"
      sketchybar --add event aerospace_workspace_change
      for sid in 1-browsers 2-chat 3-mail 4-code 5-terminal 6-docs 7-media 8-games 9-security 10-vms; do num="''${sid%%-*}"; [ "$num" = "10" ] && display="0" || display="$num"; sketchybar --add item "workspace.$sid" left --set "workspace.$sid" icon="$display" label.drawing=off background.drawing=off background.color=0x40116FAE background.corner_radius=6 background.height=22 background.padding_left=2 background.padding_right=2 script="$PLUGIN_DIR/aerospace.sh" click_script="aerospace workspace $sid" --subscribe "workspace.$sid" aerospace_workspace_change; done
      sketchybar --add item front_app center --set front_app icon.drawing=off label.max_chars=28 label.color=0xff7E8A94 script="$PLUGIN_DIR/front_app.sh" --subscribe front_app front_app_switched
      sketchybar --add item media center --set media icon="" icon.color=0xff68A2C6 label.max_chars=0 scroll_texts=on label.color=0xff68A2C6 drawing=off update_freq=5 script="$PLUGIN_DIR/media.sh" click_script="$PLUGIN_DIR/media_click.sh"
      # Right: cpu, mem, net (tailscale/warp), battery, volume, clock
      sketchybar --add item cpu right --set cpu update_freq=5 icon="" icon.color=0xff68A2C6 script="$PLUGIN_DIR/cpu.sh"
      sketchybar --add item mem right --set mem update_freq=10 icon="" icon.color=0xff68A2C6 script="$PLUGIN_DIR/memory.sh"
      sketchybar --add item net right --set net update_freq=15 icon="󰖩" icon.color=0xff68A2C6 script="$PLUGIN_DIR/network.sh"
      sketchybar --add item battery right --set battery update_freq=60 icon.color=0xff68A2C6 script="$PLUGIN_DIR/battery.sh" --subscribe battery system_woke power_source_change
      sketchybar --add item volume right --set volume icon.color=0xff305561 script="$PLUGIN_DIR/volume.sh" --subscribe volume volume_change
      sketchybar --add item clock right --set clock icon="" icon.color=0xff116FAE update_freq=30 script="$PLUGIN_DIR/clock.sh"
      sketchybar --update
      FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null || echo "1-browsers")"
      sketchybar --trigger aerospace_workspace_change FOCUSED="$FOCUSED"
    '';
  };
  home.file.".config/sketchybar/plugins/aerospace.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -z "$FOCUSED" ]; then FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null)"; fi
      WORKSPACE="''${NAME#workspace.}"
      if [ "$WORKSPACE" = "$FOCUSED" ]; then sketchybar --set "$NAME" background.drawing=on background.color=0xff116FAE icon.color=0xff04182F; else COUNT="$(aerospace list-windows --workspace "$WORKSPACE" --count 2>/dev/null || echo 0)"; if [ "$COUNT" -eq 0 ]; then sketchybar --set "$NAME" background.drawing=off icon.color=0x667E8A94; else sketchybar --set "$NAME" background.drawing=off icon.color=0xff68A2C6; fi; fi
    '';
  };
  home.file.".config/sketchybar/plugins/clock.sh" = { executable = true; text = '' #!/bin/sh
sketchybar --set "$NAME" label="$(date '+%a %d  %I:%M %p')" ''; };
  home.file.".config/sketchybar/plugins/front_app.sh" = { executable = true; text = '' #!/bin/sh
if [ "$SENDER" = "front_app_switched" ]; then sketchybar --set "$NAME" label="$INFO"; fi ''; };
  home.file.".config/sketchybar/plugins/battery.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      PERCENTAGE="$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)"
      CHARGING="$(pmset -g batt | grep 'AC Power')"
      [ -z "$PERCENTAGE" ] && exit 0
      case "$PERCENTAGE" in 9[0-9]|100) ICON="" ;; [6-8][0-9]) ICON="" ;; [3-5][0-9]) ICON="" ;; [1-2][0-9]) ICON="" ;; *) ICON="" ;; esac
      [ -n "$CHARGING" ] && ICON=""
      if [ "$PERCENTAGE" -lt 20 ] && [ -z "$CHARGING" ]; then COLOR="0xffff6b6b"; elif [ "$PERCENTAGE" -lt 40 ] && [ -z "$CHARGING" ]; then COLOR="0xffe8a87c"; else COLOR="0xff68A2C6"; fi
      sketchybar --set "$NAME" icon="$ICON" label="''${PERCENTAGE}%" icon.color="$COLOR" label.color="$COLOR"
    '';
  };
  home.file.".config/sketchybar/plugins/volume.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ "$SENDER" = "volume_change" ]; then VOLUME="$INFO"; case "$VOLUME" in [6-9][0-9]|100) ICON="󰕾" ;; [3-5][0-9]) ICON="󰖀" ;; [1-9]|[1-2][0-9]) ICON="󰕿" ;; *) ICON="󰖁" ;; esac; sketchybar --set "$NAME" icon="$ICON" label="''${VOLUME}%"; fi
    '';
  };
  home.file.".config/sketchybar/plugins/cpu.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      CPU="$(ps -A -o %cpu | awk '{s+=$1} END {printf "%d", s}')"
      # Clamp 0-100 per core avg
      CORES="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
      AVG=$((CPU / CORES))
      [ "$AVG" -gt 100 ] && AVG=100
      if [ "$AVG" -gt 80 ]; then COLOR="0xffe8a87c"; elif [ "$AVG" -gt 50 ]; then COLOR="0xff68A2C6"; else COLOR="0xff7E8A94"; fi
      sketchybar --set "$NAME" label="''${AVG}%" icon.color="$COLOR" label.color="$COLOR"
    '';
  };
  home.file.".config/sketchybar/plugins/memory.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      MEM_PRESSURE="$(memory_pressure 2>&1 | head -n 5 || echo "")"
      # Use vm_stat for ADHD low-stim (just %)
      PAGES_FREE="$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')"
      PAGES_ACTIVE="$(vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.')"
      PAGES_INACTIVE="$(vm_stat | grep "Pages inactive" | awk '{print $3}' | tr -d '.')"
      PAGES_WIRED="$(vm_stat | grep "Pages wired" | awk '{print $4}' | tr -d '.')"
      # Simplified: just show pressure via free vs total
      sketchybar --set "$NAME" label="$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.' | head -c4)"
    '';
  };
  home.file.".config/sketchybar/plugins/network.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Wi-Fi (en0) + Tailscale + WARP
      WIFI_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"
      WIFI_POWER="$(networksetup -getairportpower en0 2>/dev/null)"
      echo "$WIFI_POWER" | grep -q "On" && POWER_ON=1 || POWER_ON=0

      if [ -n "$WIFI_IP" ]; then
        # Connected — try to get SSID (filter redacted placeholder)
        SSID="$(networksetup -getairportnetwork en0 2>/dev/null | sed -n 's/.*: "\(.*\)".*/\1/p')"
        if [ -z "$SSID" ] || echo "$SSID" | grep -qi "not associated\|redacted"; then
          SSID="$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Current Network Information:/{getline; gsub(/^[ \t]+/,"",$0); gsub(/:$/,"",$0); print; exit}')"
        fi
        if echo "$SSID" | grep -qi "redacted"; then SSID=""; fi
        # If SSID still empty/redacted, hide label (just show blue wifi icon + badges) instead of "<redacted>" or IP
        if [ -z "$SSID" ]; then LABEL=""; else LABEL="$SSID"; fi
        ICON="󰖩"
        COLOR="0xff68A2C6"
      elif [ "$POWER_ON" = 1 ]; then
        ICON="󰖪"
        COLOR="0xffe8a87c"
        LABEL="no wifi"
      else
        ICON="󰖪"
        COLOR="0x667E8A94"
        LABEL="off"
      fi

      # Tailscale indicator (append to label)
      TS="$(/Applications/Tailscale.app/Contents/MacOS/Tailscale status 2>&1 | head -n 5 || tailscale status 2>&1 | head -n 5)"
      if echo "$TS" | grep -q "Tailscale is stopped"; then TS_BADGE=""; else TS_BADGE=" 󰖂"; fi
      # WARP indicator
      if scutil --nc list 2>&1 | grep -q "WARP"; then WARP_BADGE=" 󰦝"; else WARP_BADGE=""; fi

      sketchybar --set "$NAME" icon="$ICON" label="''${LABEL}''${TS_BADGE}''${WARP_BADGE}" icon.color="$COLOR"
    '';
  };
  home.file.".config/sketchybar/plugins/media.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Now Playing — nowplaying-cli (Music, Spotify, YouTube Music, termusic via MediaPlayer) > fallbacks
      LABEL=""
      STATE=""

      # 1) nowplaying-cli (covers Music, Spotify, YouTube Music, browsers, termusic) if installed
      if command -v nowplaying-cli >/dev/null 2>&1; then
        TITLE="$(nowplaying-cli get title 2>/dev/null)"
        ARTIST="$(nowplaying-cli get artist 2>/dev/null)"
        RATE="$(nowplaying-cli get playbackRate 2>/dev/null)"
        # nowplaying-cli returns literal "null" when idle
        [ "$TITLE" = "null" ] && TITLE=""
        [ "$ARTIST" = "null" ] && ARTIST=""
        if [ -n "$TITLE" ] && [ "$TITLE" != "(null)" ]; then
          case "$RATE" in 1|1.0) STATE="playing" ;; *) STATE="paused" ;; esac
          if [ -n "$ARTIST" ]; then LABEL="$ARTIST — $TITLE"; else LABEL="$TITLE"; fi
        fi
      fi

      # 2) Fallback: Apple Music
      if [ -z "$LABEL" ] && pgrep -x "Music" >/dev/null 2>&1; then
        INFO="$(osascript -e 'tell application "Music" to if it is running then try
          set t to name of current track
          set a to artist of current track
          set s to player state as string
          return t & "§" & a & "§" & s
        on error
          return "§§stopped"
        end try
        end tell' 2>/dev/null)"
        T="$(echo "$INFO" | cut -d'§' -f1)"
        A="$(echo "$INFO" | cut -d'§' -f2)"
        S="$(echo "$INFO" | cut -d'§' -f3)"
        if [ -n "$T" ] && [ "$S" != "stopped" ] && [ "$S" != "" ]; then
          STATE="$S"
          if [ -n "$A" ]; then LABEL="$A — $T"; else LABEL="$T"; fi
        fi
      fi

      # 3) Fallback: Spotify
      if [ -z "$LABEL" ] && pgrep -x "Spotify" >/dev/null 2>&1; then
        INFO="$(osascript -e 'tell application "Spotify" to if it is running then try
          set t to name of current track
          set a to artist of current track
          set s to player state as string
          return t & "§" & a & "§" & s
        on error
          return "§§stopped"
        end try
        end tell' 2>/dev/null)"
        T="$(echo "$INFO" | cut -d'§' -f1)"
        A="$(echo "$INFO" | cut -d'§' -f2)"
        S="$(echo "$INFO" | cut -d'§' -f3)"
        if [ -n "$T" ] && [ "$S" != "stopped" ] && [ "$S" != "" ]; then
          STATE="$S"
          if [ -n "$A" ]; then LABEL="$A — $T"; else LABEL="$T"; fi
        fi
      fi

      # 4) Fallback: cmus
      if [ -z "$LABEL" ] && command -v cmus-remote >/dev/null 2>&1 && pgrep -x cmus >/dev/null 2>&1; then
        CMUS_Q="$(cmus-remote -Q 2>/dev/null)"
        if echo "$CMUS_Q" | grep -q "status playing\|status paused"; then
          CMUS_ARTIST="$(echo "$CMUS_Q" | awk '/tag artist /{sub(/^tag artist /, ""); print; exit}')"
          CMUS_TITLE="$(echo "$CMUS_Q" | awk '/tag title /{sub(/^tag title /, ""); print; exit}')"
          CMUS_FILE="$(echo "$CMUS_Q" | awk '/^file /{sub(/^file /, ""); print; exit}')"
          CMUS_STATUS="$(echo "$CMUS_Q" | awk '/^status /{print $2}')"
          STATE="$CMUS_STATUS"
          if [ -n "$CMUS_TITLE" ]; then
            if [ -n "$CMUS_ARTIST" ]; then LABEL="$CMUS_ARTIST — $CMUS_TITLE"; else LABEL="$CMUS_TITLE"; fi
          elif [ -n "$CMUS_FILE" ]; then
            LABEL="$(basename "$CMUS_FILE")"
          fi
        fi
      fi

      # 5) Fallback: termusic (TUI, not always exposed via nowplaying-cli on macOS)
      if [ -z "$LABEL" ] && (pgrep -x termusic >/dev/null 2>&1 || pgrep -x termusic-server >/dev/null 2>&1); then
        # termusic links MediaPlayer.framework, so nowplaying-cli should have caught it.
        # If not, show a generic indicator so the widget still appears and is controllable.
        # Try to extract file from termusic playlist.log as title fallback.
        TERM_PL=""; [ -f "$HOME/.config/termusic/playlist.log" ] && TERM_PL="$(head -n 1 "$HOME/.config/termusic/playlist.log" 2>/dev/null)"
        [ -z "$TERM_PL" ] && TERM_PL="$(ls -t "$HOME/Library/Application Support/termusic/"*.log 2>/dev/null | head -n 1 | xargs head -n 1 2>/dev/null)"
        if [ -n "$TERM_PL" ]; then
          LABEL="$(basename "$TERM_PL")"
          # strip extension
          LABEL="''${LABEL%.*}"
        else
          LABEL="termusic"
        fi
        STATE="playing"
      fi

      # 6) Fallback: mpd/mpc
      if [ -z "$LABEL" ] && command -v mpc >/dev/null 2>&1 && pgrep -x mpd >/dev/null 2>&1; then
        MPC_STATUS="$(mpc status 2>/dev/null | head -n 1)"
        MPC_STATE="$(mpc status 2>/dev/null | grep -o "\[playing\]\|\[paused\]")"
        if [ -n "$MPC_STATUS" ] && [ "$MPC_STATUS" != "" ]; then
          LABEL="$MPC_STATUS"
          case "$MPC_STATE" in "[playing]") STATE="playing" ;; *) STATE="paused" ;; esac
        fi
      fi

      if [ -z "$LABEL" ]; then
        sketchybar --set "$NAME" drawing=off
        exit 0
      fi

      # Idle auto-hide: bar disappears after IDLE_TIMEOUT (s) without playback
      IDLE_TIMEOUT=300
      LAST_PLAY_FILE="$HOME/.cache/sketchybar/media_last_play"
      if [ "$STATE" = "playing" ]; then
        mkdir -p "$(dirname "$LAST_PLAY_FILE")"
        date +%s > "$LAST_PLAY_FILE"
      elif [ -f "$LAST_PLAY_FILE" ]; then
        LAST="$(cat "$LAST_PLAY_FILE" 2>/dev/null)"
        NOW="$(date +%s)"
        if [ -z "$LAST" ] || [ "$((NOW - LAST))" -gt "$IDLE_TIMEOUT" ]; then
          sketchybar --set "$NAME" drawing=off
          exit 0
        fi
      else
        sketchybar --set "$NAME" drawing=off
        exit 0
      fi

      if [ "$STATE" = "playing" ]; then ICON=""; COLOR="0xff68A2C6"; else ICON="󰏤"; COLOR="0x997E8A94"; fi
      sketchybar --set "$NAME" drawing=on icon="$ICON" label="$LABEL" icon.color="$COLOR" label.color="$COLOR" label.drawing=on
    '';
  };
  home.file.".config/sketchybar/plugins/media_click.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Left click: play/pause, Right click: skip (next)
      # Order: nowplaying-cli (covers termusic, Music, Spotify) > app-specific > TUI fallbacks
      if [ "$BUTTON" = "2" ] || [ "$BUTTON" = "right" ]; then
        nowplaying-cli next 2>/dev/null && exit 0
        osascript -e 'tell application "Music" to if it is running then next track' 2>/dev/null && exit 0
        osascript -e 'tell application "Spotify" to if it is running then next track' 2>/dev/null && exit 0
        cmus-remote --next 2>/dev/null && exit 0
        mpc next 2>/dev/null && exit 0
        # termusic: no CLI, fallback to media key via nowplaying-cli already tried; send generic next via osascript media key if needed
        pgrep -x termusic >/dev/null 2>&1 && nowplaying-cli next 2>/dev/null && exit 0
      else
        nowplaying-cli togglePlayPause 2>/dev/null && exit 0
        osascript -e 'tell application "Music" to if it is running then playpause' 2>/dev/null && exit 0
        osascript -e 'tell application "Spotify" to if it is running then playpause' 2>/dev/null && exit 0
        cmus-remote --pause 2>/dev/null && exit 0
        mpc toggle 2>/dev/null && exit 0
        pgrep -x termusic >/dev/null 2>&1 && nowplaying-cli togglePlayPause 2>/dev/null && exit 0
      fi
    '';
  };
}
