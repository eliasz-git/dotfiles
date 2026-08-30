{ config, pkgs, lib, ... }:

{
  home.file.".config/sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
      #!/bin/sh
      PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
      sketchybar --bar position=top height=32 margin=4 y_offset=4 corner_radius=16 border_width=0 blur_radius=20 color=0xE604182F padding_left=8 padding_right=8 notch_width=0
      default=(padding_left=4 padding_right=4 icon.font="JetBrainsMono Nerd Font:Bold:12.0" label.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=0xff68A2C6 label.color=0xff68A2C6 background.height=22 background.corner_radius=11 icon.padding_left=6 icon.padding_right=6 label.padding_left=0 label.padding_right=6)
      sketchybar --default "''${default[@]}"
      sketchybar --add event aerospace_workspace_change
      for sid in 1-browsers 2-chat 3-mail 4-code 5-terminal 6-docs 7-media 8-games 9-security 10-vms; do num="''${sid%%-*}"; [ "$num" = "10" ] && display="0" || display="$num"; sketchybar --add item "workspace.$sid" left --set "workspace.$sid" icon="$display" label.drawing=off background.drawing=off background.color=0x40116FAE background.corner_radius=11 background.height=22 background.padding_left=2 background.padding_right=2 script="$PLUGIN_DIR/aerospace.sh" click_script="aerospace workspace $sid" --subscribe "workspace.$sid" aerospace_workspace_change; done
      sketchybar --add item front_app center --set front_app icon.drawing=off label.max_chars=28 label.color=0xff7E8A94 script="$PLUGIN_DIR/front_app.sh" --subscribe front_app front_app_switched
      sketchybar --add item media center --set media icon="" icon.color=0xff68A2C6 label.max_chars=30 scroll_texts=on label.scroll_duration=140 label.color=0xff68A2C6 drawing=off update_freq=2 script="$PLUGIN_DIR/media.sh" click_script="$PLUGIN_DIR/media_click.sh"
      for i in 1 2 3 4 5 6; do
        sketchybar --add item "media.viz$i" center --set "media.viz$i" width=12 icon.drawing=off label.font="JetBrainsMono Nerd Font:Regular:10.0" label.color=0xff68A2C6 label.padding_left=0 label.padding_right=0 icon.padding_left=0 icon.padding_right=0 background.drawing=off background.padding_left=0 background.padding_right=0 padding_left=0 padding_right=0 drawing=off
      done
      sketchybar --add item media.viz center --set media.viz icon.drawing=off drawing=off script="$PLUGIN_DIR/media_spectrogram.sh"
      sketchybar --add bracket media.bracket media media.viz1 media.viz2 media.viz3 media.viz4 media.viz5 media.viz6 --set media.bracket background.color=0x22116FAE background.corner_radius=12 background.height=24 background.border_width=0 background.drawing=off
      # Spectrogram daemon — 6 bars @ ~7fps (update_freq caps at 1s so we poll faster here)
      pkill -f "media_viz_daemon" 2>/dev/null || true
      "$PLUGIN_DIR/media_viz_daemon.sh" >/dev/null 2>&1 &
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
#!/bin/bash
# Now Playing — optimized: fast mpd first, album-colored (media_color.py) + instant cache + brighter main
LABEL=""
STATE=""
FILE=""
CACHE_KEY=""

brighten() {
  local hex=$1
  local factor=$2
  local r=$((16#''${hex:4:2}))
  local g=$((16#''${hex:6:2}))
  local b=$((16#''${hex:8:2}))
  r=$(awk -v r=$r -v f=$factor 'BEGIN{ v=r*f; if(v>255) v=255; printf "%d", v }')
  g=$(awk -v g=$g -v f=$factor 'BEGIN{ v=g*f; if(v>255) v=255; printf "%d", v }')
  b=$(awk -v b=$b -v f=$factor 'BEGIN{ v=b*f; if(v>255) v=255; printf "%d", v }')
  printf "0xff%02x%02x%02x" $r $g $b
}

# --- 1) mpd/mpc fast (0.01s) — primary for this setup ---
if command -v mpc >/dev/null 2>&1 && pgrep -x mpd >/dev/null 2>&1; then
  MPC_FMT="$(mpc -f "%title%§%artist%§%file%" current 2>/dev/null | head -n 1)"
  MPC_TITLE="$(echo "$MPC_FMT" | cut -d'§' -f1)"
  MPC_ARTIST="$(echo "$MPC_FMT" | cut -d'§' -f2)"
  MPC_FILE="$(echo "$MPC_FMT" | cut -d'§' -f3)"
  MPC_STATE="$(mpc status 2>/dev/null | grep -o "\[playing\]\|\[paused\]")"
  if [ -n "$MPC_TITLE" ]; then
    if [ -n "$MPC_ARTIST" ]; then LABEL="$MPC_TITLE — $MPC_ARTIST"; else LABEL="$MPC_TITLE"; fi
    case "$MPC_STATE" in "[playing]") STATE="playing" ;; "[paused]") STATE="paused" ;; *) STATE="paused" ;; esac
    FILE="$MPC_FILE"
    CACHE_KEY="$FILE"
  else
    MPC_STATUS="$(mpc status 2>/dev/null | head -n 1)"
    if [ -n "$MPC_STATUS" ] && [ "$MPC_STATUS" != "volume:"* ]; then
      LABEL="$MPC_STATUS"
      case "$MPC_STATE" in "[playing]") STATE="playing" ;; *) STATE="paused" ;; esac
      FILE="$MPC_FILE"
      CACHE_KEY="$FILE"
    fi
  fi
fi

# --- 2) cmus ---
if [ -z "$LABEL" ] && command -v cmus-remote >/dev/null 2>&1 && pgrep -x cmus >/dev/null 2>&1; then
  CMUS_Q="$(cmus-remote -Q 2>/dev/null)"
  if echo "$CMUS_Q" | grep -q "status playing\|status paused"; then
    CMUS_ARTIST="$(echo "$CMUS_Q" | awk '/tag artist /{sub(/^tag artist /, ""); print; exit}')"
    CMUS_TITLE="$(echo "$CMUS_Q" | awk '/tag title /{sub(/^tag title /, ""); print; exit}')"
    CMUS_FILE="$(echo "$CMUS_Q" | awk '/^file /{sub(/^file /, ""); print; exit}')"
    CMUS_STATUS="$(echo "$CMUS_Q" | awk '/^status /{print $2}')"
    STATE="$CMUS_STATUS"
    if [ -n "$CMUS_TITLE" ]; then
      if [ -n "$CMUS_ARTIST" ]; then LABEL="$CMUS_TITLE — $CMUS_ARTIST"; else LABEL="$CMUS_TITLE"; fi
    elif [ -n "$CMUS_FILE" ]; then
      LABEL="$(basename "$CMUS_FILE")"
    fi
    FILE="$CMUS_FILE"
    CACHE_KEY="$FILE"
  fi
fi

# --- 3) termusic ---
if [ -z "$LABEL" ] && (pgrep -x termusic >/dev/null 2>&1 || pgrep -x termusic-server >/dev/null 2>&1); then
  TERM_PL=""; [ -f "$HOME/.config/termusic/playlist.log" ] && TERM_PL="$(head -n 1 "$HOME/.config/termusic/playlist.log" 2>/dev/null)"
  [ -z "$TERM_PL" ] && TERM_PL="$(ls -t "$HOME/Library/Application Support/termusic/"*.log 2>/dev/null | head -n 1 | xargs head -n 1 2>/dev/null)"
  if [ -n "$TERM_PL" ]; then
    LABEL="$(basename "$TERM_PL")"
    LABEL="''${LABEL%.*}"
  else
    LABEL="termusic"
  fi
  STATE="playing"
  CACHE_KEY="$TERM_PL"
fi

# --- 4) nowplaying-cli (slow 2.7s) — only if fast didn't hit ---
if [ -z "$LABEL" ] && command -v nowplaying-cli >/dev/null 2>&1; then
  NP_JSON="$(nowplaying-cli get --json title artist playbackRate bundleIdentifier 2>/dev/null)"
  TITLE="$(echo "$NP_JSON" | grep -o '"title"[^,]*' | cut -d'"' -f4)"
  ARTIST="$(echo "$NP_JSON" | grep -o '"artist"[^,]*' | cut -d'"' -f4)"
  RATE="$(echo "$NP_JSON" | grep -o '"playbackRate"[^,]*' | cut -d: -f2 | tr -d ' ,')"
  BUNDLE="$(echo "$NP_JSON" | grep -o '"bundleIdentifier"[^,]*' | cut -d'"' -f4)"
  [ "$TITLE" = "null" ] && TITLE=""
  [ "$ARTIST" = "null" ] && ARTIST=""
  [ "$BUNDLE" = "null" ] && BUNDLE=""
  if [ -z "$BUNDLE" ] && [ -z "$ARTIST" ]; then TITLE=""; fi
  if [ -n "$TITLE" ] && [ "$TITLE" != "(null)" ]; then
    case "$RATE" in 1|1.0) STATE="playing" ;; *) STATE="paused" ;; esac
    if [ -n "$ARTIST" ]; then LABEL="$TITLE — $ARTIST"; else LABEL="$TITLE"; fi
    CACHE_KEY="$TITLE — $ARTIST"
  fi
fi

# --- 5) Music ---
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
    if [ -n "$A" ]; then LABEL="$T — $A"; else LABEL="$T"; fi
    CACHE_KEY="$T — $A"
  fi
fi

# --- 6) Spotify ---
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
    if [ -n "$A" ]; then LABEL="$T — $A"; else LABEL="$T"; fi
    CACHE_KEY="$T — $A"
  fi
fi

if [ -z "$LABEL" ]; then
  sketchybar --set "$NAME" drawing=off 2>/dev/null
  exit 0
fi

if [ -z "$CACHE_KEY" ]; then CACHE_KEY="$LABEL"; fi

# Idle timeout
IDLE_TIMEOUT=300
LAST_PLAY_FILE="$HOME/.cache/sketchybar/media_last_play"
if [ "$STATE" = "playing" ]; then
  mkdir -p "$(dirname "$LAST_PLAY_FILE")"
  date +%s > "$LAST_PLAY_FILE"
elif [ -f "$LAST_PLAY_FILE" ]; then
  LAST="$(cat "$LAST_PLAY_FILE" 2>/dev/null)"
  NOW="$(date +%s)"
  if [ -z "$LAST" ] || [ "$((NOW - LAST))" -gt "$IDLE_TIMEOUT" ]; then
    sketchybar --set "$NAME" drawing=off 2>/dev/null
    exit 0
  fi
else
  sketchybar --set "$NAME" drawing=off 2>/dev/null
  exit 0
fi

# --- Set label + force viz visibility NOW so we can query the REAL rendered
# width before generating the gradient image (fixes pill/background mismatch)
sketchybar --set "$NAME" drawing=on label="$LABEL" label.drawing=on 2>/dev/null
BW=400
if [ "$STATE" = "playing" ]; then
  for i in 1 2 3 4 5 6; do sketchybar --set "media.viz$i" drawing=on 2>/dev/null; done
  sleep 0.05
  RAW_BW="$(sketchybar --query media.bracket 2>/dev/null | jq -r '.geometry.bounding_rects | to_entries[0].value.size[0] // empty' 2>/dev/null)"
  if [ -n "$RAW_BW" ]; then
    CAND="''${RAW_BW%.*}"
    if [ -n "$CAND" ] && [ "$CAND" -ge 200 ] 2>/dev/null; then
      BW="$CAND"
    fi
  fi
fi

# --- Album color (cached, fast) + brighter main ---
DEFAULT_COLOR="0xff68A2C6"
CACHE_COLOR_FILE="$HOME/.cache/sketchybar/media_color_cache"
COLOR="$DEFAULT_COLOR"
if [ -f "$CACHE_COLOR_FILE" ]; then
  CACHED_KEY="$(head -n1 "$CACHE_COLOR_FILE" 2>/dev/null)"
  CACHED_COL="$(sed -n '2p' "$CACHE_COLOR_FILE" 2>/dev/null)"
  if [ "$CACHED_KEY" = "$CACHE_KEY" ] && [ -n "$CACHED_COL" ]; then
    COLOR="$CACHED_COL"
  else
    if [ -n "$FILE" ]; then
      NEW_COL="$(python3 "$HOME/.config/sketchybar/plugins/media_color.py" "$FILE" "$BW" 2>/dev/null)"
    else
      NEW_COL="$DEFAULT_COLOR"
    fi
    if [ -n "$NEW_COL" ]; then
      COLOR="$NEW_COL"
      mkdir -p "$(dirname "$CACHE_COLOR_FILE")"
      printf "%s
%s
" "$CACHE_KEY" "$COLOR" > "$CACHE_COLOR_FILE"
    fi
  fi
else
  if [ -n "$FILE" ]; then
    NEW_COL="$(python3 "$HOME/.config/sketchybar/plugins/media_color.py" "$FILE" "$BW" 2>/dev/null)"
  else
    NEW_COL="$DEFAULT_COLOR"
  fi
  if [ -n "$NEW_COL" ]; then
    COLOR="$NEW_COL"
    mkdir -p "$(dirname "$CACHE_COLOR_FILE")"
    printf "%s
%s
" "$CACHE_KEY" "$COLOR" > "$CACHE_COLOR_FILE"
  fi
fi

# Make main color brighter than usual (album color + 25%)
COLOR_BRIGHT="$(brighten "$COLOR" 1.25)"
BRACKET_COLOR="0x22''${COLOR_BRIGHT#0xff}"

# Choose white or black text based on brightness of bracket (for contrast)
# luminance
R=$((16#''${COLOR_BRIGHT:4:2}))
G=$((16#''${COLOR_BRIGHT:6:2}))
B=$((16#''${COLOR_BRIGHT:8:2}))
LUM=$(( (R*299 + G*587 + B*114)/1000 ))
if [ "$LUM" -gt 160 ]; then
  TEXT_COLOR="0xff000000"
else
  TEXT_COLOR="0xffffffff"
fi

if [ "$STATE" = "playing" ]; then
  ICON=""
  LABEL_COLOR="$TEXT_COLOR"
  ICON_COLOR="$TEXT_COLOR"
  BG_DRAWING="on"
else
  ICON="󰏤"
  # paused dim: keep same hue but with alpha, still white/black base
  if [ "$TEXT_COLOR" = "0xffffffff" ]; then
    PAUSED_COLOR="0x99ffffff"
  else
    PAUSED_COLOR="0x99000000"
  fi
  LABEL_COLOR="$PAUSED_COLOR"
  ICON_COLOR="$PAUSED_COLOR"
  BRACKET_COLOR="0x22''${COLOR_BRIGHT#0xff}"
  BG_DRAWING="on"
fi

sketchybar --set "$NAME" drawing=on icon="$ICON" label="$LABEL" icon.color="$ICON_COLOR" label.color="$LABEL_COLOR" label.drawing=on background.drawing=off 2>/dev/null
# gradient of top 2-3 album colors for bracket
GRADIENT="/tmp/sketchybar_media_bg.png"
if [ -f "$GRADIENT" ] && [ "$STATE" = "playing" ]; then
  sketchybar --set media.bracket background.image.string="$GRADIENT" background.image.drawing=on background.color=0x00000000 background.drawing=on 2>/dev/null || true
else
  sketchybar --set media.bracket background.image.drawing=off 2>/dev/null || true
  sketchybar --set media.bracket background.color="$BRACKET_COLOR" background.drawing="$BG_DRAWING" 2>/dev/null || true
fi

    '';
  };
  home.file.".config/sketchybar/plugins/media_spectrogram.sh" = {
    executable = true;
    text = ''
#!/bin/bash
# Fallback 1Hz viz — 6 bars gradient, album-colored via cache (daemon does 7fps)
STATE=""
if command -v mpc >/dev/null 2>&1 && pgrep -x mpd >/dev/null 2>&1; then
  if mpc status 2>/dev/null | grep -q "\[playing\]"; then
    STATE="playing"
  elif mpc status 2>/dev/null | grep -q "\[paused\]"; then
    STATE="paused"
  fi
fi
if [ -z "$STATE" ]; then
  if command -v cmus-remote >/dev/null 2>&1 && pgrep -x cmus >/dev/null 2>&1 && cmus-remote -Q 2>/dev/null | grep -q "status playing"; then
    STATE="playing"
  fi
fi
if [ -z "$STATE" ]; then
  if pgrep -x termusic >/dev/null 2>&1 || pgrep -x termusic-server >/dev/null 2>&1; then
    STATE="playing"
  fi
fi
if [ -z "$STATE" ]; then
  if command -v nowplaying-cli >/dev/null 2>&1; then
    NP_JSON="$(nowplaying-cli get --json title artist playbackRate bundleIdentifier 2>/dev/null)"
    TITLE="$(echo "$NP_JSON" | grep -o '"title"[^,]*' | cut -d'"' -f4)"
    ARTIST="$(echo "$NP_JSON" | grep -o '"artist"[^,]*' | cut -d'"' -f4)"
    RATE="$(echo "$NP_JSON" | grep -o '"playbackRate"[^,]*' | cut -d: -f2 | tr -d ' ,')"
    BUNDLE="$(echo "$NP_JSON" | grep -o '"bundleIdentifier"[^,]*' | cut -d'"' -f4)"
    [ "$TITLE" = "null" ] && TITLE=""
    [ "$ARTIST" = "null" ] && ARTIST=""
    [ "$BUNDLE" = "null" ] && BUNDLE=""
    if [ -z "$BUNDLE" ] && [ -z "$ARTIST" ]; then TITLE=""; fi
    if [ -n "$TITLE" ] && [ "$TITLE" != "(null)" ]; then
      case "$RATE" in 1|1.0) STATE="playing" ;; *) STATE="paused" ;; esac
    fi
  fi
fi
if [ -z "$STATE" ]; then
  if pgrep -x "Music" >/dev/null 2>&1; then
    S="$(osascript -e 'tell application "Music" to player state as string' 2>/dev/null)"
    [ "$S" = "playing" ] && STATE="playing" || { [ -n "$S" ] && STATE="paused"; }
  fi
fi
if [ -z "$STATE" ]; then
  if pgrep -x "Spotify" >/dev/null 2>&1; then
    S="$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)"
    [ "$S" = "playing" ] && STATE="playing" || { [ -n "$S" ] && STATE="paused"; }
  fi
fi
if [ "$STATE" != "playing" ]; then
  for i in 1 2 3 4 5 6; do sketchybar --set "media.viz$i" drawing=off 2>/dev/null; done
  exit 0
fi

# single fallback item still exists? hide it
sketchybar --set "$NAME" drawing=off 2>/dev/null || true

CACHE_COLOR_FILE="$HOME/.cache/sketchybar/media_color_cache"
VIZ_COLOR="0xff68A2C6"
if [ -f "$CACHE_COLOR_FILE" ]; then
  CACHED_COL="$(sed -n '2p' "$CACHE_COLOR_FILE" 2>/dev/null)"
  [ -n "$CACHED_COL" ] && VIZ_COLOR="$CACHED_COL"
fi
# brighter base
brighten() {
  local hex=$1; local factor=$2
  local r=$((16#''${hex:4:2})); local g=$((16#''${hex:6:2})); local b=$((16#''${hex:8:2}))
  r=$(awk -v r=$r -v f=$factor 'BEGIN{ v=r*f; if(v>255) v=255; printf "%d", v }')
  g=$(awk -v g=$g -v f=$factor 'BEGIN{ v=g*f; if(v>255) v=255; printf "%d", v }')
  b=$(awk -v b=$b -v f=$factor 'BEGIN{ v=b*f; if(v>255) v=255; printf "%d", v }')
  printf "0xff%02x%02x%02x" $r $g $b
}
VIZ_BASE="$(brighten "$VIZ_COLOR" 1.25)"
BARS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
FACTORS=(0.55 0.70 0.85 1.00 1.15 1.30 1.45 1.60)
for i in 1 2 3 4 5 6; do
  IDX=$((RANDOM % 8))
  CHAR="''${BARS[$IDX]}"
  FACTOR="''${FACTORS[$IDX]}"
  COL="$(brighten "$VIZ_BASE" "$FACTOR")"
  if [ "$IDX" -lt 2 ]; then COL="0x99''${COL#0xff}"; fi
  sketchybar --set "media.viz$i" drawing=on label="$CHAR" label.color="$COL" label.drawing=on 2>/dev/null
done

    '';
  };
  home.file.".config/sketchybar/plugins/media_viz_daemon.sh" = {
    executable = true;
    text = ''
#!/bin/bash
# Fast spectrogram poller — 6 bars @ ~7fps, white/black per brightness, close
PREV_FILE=""
PREV_STATE=""
CACHE_COLOR_FILE="$HOME/.cache/sketchybar/media_color_cache"
brighten() {
  local hex=$1
  local factor=$2
  local r=$((16#''${hex:4:2}))
  local g=$((16#''${hex:6:2}))
  local b=$((16#''${hex:8:2}))
  r=$(awk -v r=$r -v f=$factor 'BEGIN{ v=r*f; if(v>255) v=255; printf "%d", v }')
  g=$(awk -v g=$g -v f=$factor 'BEGIN{ v=g*f; if(v>255) v=255; printf "%d", v }')
  b=$(awk -v b=$b -v f=$factor 'BEGIN{ v=b*f; if(v>255) v=255; printf "%d", v }')
  printf "0xff%02x%02x%02x" $r $g $b
}
while true; do
  STATE=""
  CUR_FILE=""
  if command -v mpc >/dev/null 2>&1 && pgrep -x mpd >/dev/null 2>&1; then
    if mpc status 2>/dev/null | grep -q "\[playing\]"; then STATE="playing"
    elif mpc status 2>/dev/null | grep -q "\[paused\]"; then STATE="paused"; fi
    CUR_FILE="$(mpc --format "%file%" current 2>/dev/null | head -n 1)"
  fi
  if [ -z "$STATE" ]; then
    if command -v cmus-remote >/dev/null 2>&1 && pgrep -x cmus >/dev/null 2>&1; then
      CMUS_Q="$(cmus-remote -Q 2>/dev/null)"
      if echo "$CMUS_Q" | grep -q "status playing"; then STATE="playing"
      elif echo "$CMUS_Q" | grep -q "status paused"; then STATE="paused"; fi
      if [ -z "$CUR_FILE" ]; then CUR_FILE="$(echo "$CMUS_Q" | awk '/^file /{sub(/^file /,""); print; exit}')"; fi
    fi
  fi
  if [ -z "$STATE" ]; then
    if pgrep -x termusic >/dev/null 2>&1 || pgrep -x termusic-server >/dev/null 2>&1; then STATE="playing"; fi
  fi
  if [ -z "$STATE" ]; then
    if command -v nowplaying-cli >/dev/null 2>&1; then
      NP_JSON="$(nowplaying-cli get --json title artist playbackRate bundleIdentifier 2>/dev/null)"
      TITLE="$(echo "$NP_JSON" | grep -o '"title"[^,]*' | cut -d'"' -f4)"
      ARTIST="$(echo "$NP_JSON" | grep -o '"artist"[^,]*' | cut -d'"' -f4)"
      RATE="$(echo "$NP_JSON" | grep -o '"playbackRate"[^,]*' | cut -d: -f2 | tr -d ' ,')"
      BUNDLE="$(echo "$NP_JSON" | grep -o '"bundleIdentifier"[^,]*' | cut -d'"' -f4)"
      [ "$TITLE" = "null" ] && TITLE=""
      [ "$ARTIST" = "null" ] && ARTIST=""
      [ "$BUNDLE" = "null" ] && BUNDLE=""
      if [ -z "$BUNDLE" ] && [ -z "$ARTIST" ]; then TITLE=""; fi
      if [ -n "$TITLE" ] && [ "$TITLE" != "(null)" ]; then
        case "$RATE" in 1|1.0) STATE="playing" ;; *) STATE="paused" ;; esac
        if [ -z "$CUR_FILE" ]; then CUR_FILE="$TITLE — $ARTIST"; fi
      fi
    fi
  fi
  if [ -z "$STATE" ]; then
    if pgrep -x "Music" >/dev/null 2>&1; then
      S="$(osascript -e 'tell application "Music" to player state as string' 2>/dev/null)"
      [ "$S" = "playing" ] && STATE="playing" || { [ -n "$S" ] && STATE="paused"; }
    fi
  fi
  if [ -z "$STATE" ]; then
    if pgrep -x "Spotify" >/dev/null 2>&1; then
      S="$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)"
      [ "$S" = "playing" ] && STATE="playing" || { [ -n "$S" ] && STATE="paused"; }
    fi
  fi
  if [ -n "$CUR_FILE" ] && [ "$CUR_FILE" != "$PREV_FILE" ] || [ "$STATE" != "$PREV_STATE" ]; then
    PREV_FILE="$CUR_FILE"
    PREV_STATE="$STATE"
    NAME=media bash "$HOME/.config/sketchybar/plugins/media.sh" >/dev/null 2>&1 &
  fi
  VIZ_COLOR="0xff68A2C6"
  if [ -f "$CACHE_COLOR_FILE" ]; then
    CACHED_COL="$(sed -n '2p' "$CACHE_COLOR_FILE" 2>/dev/null)"
    [ -n "$CACHED_COL" ] && VIZ_COLOR="$CACHED_COL"
  fi
  VIZ_BASE="$(brighten "$VIZ_COLOR" 1.25)"
  RV=$((16#''${VIZ_BASE:4:2})); GV=$((16#''${VIZ_BASE:6:2})); BV=$((16#''${VIZ_BASE:8:2}))
  VIZ_LUM=$(( (RV*299 + GV*587 + BV*114)/1000 ))
  if [ "$VIZ_LUM" -gt 160 ]; then VIZ_TEXT="0xff000000"; else VIZ_TEXT="0xffffffff"; fi
  if [ "$STATE" = "playing" ]; then
    BARS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
    FACTORS=(0.55 0.70 0.85 1.00 1.15 1.30 1.45 1.60)
    ARGS=()
    for i in 1 2 3 4 5 6; do
      IDX=$((RANDOM % 8))
      CHAR="''${BARS[$IDX]}"
      FACTOR="''${FACTORS[$IDX]}"
      COL="$(brighten "$VIZ_TEXT" "$FACTOR")"
      if [ "$IDX" -lt 2 ]; then
        if [ "$VIZ_TEXT" = "0xffffffff" ]; then COL="0x99ffffff"; else COL="0x99000000"; fi
      fi
      ARGS+=(--set "media.viz$i" drawing=on label="$CHAR" label.color="$COL" label.drawing=on)
    done
    sketchybar "''${ARGS[@]}" 2>/dev/null || true
    sleep 0.16
  else
    for i in 1 2 3 4 5 6; do sketchybar --set "media.viz$i" drawing=off 2>/dev/null; done
    sleep 0.35
  fi
done

    '';
  };
  home.file.".config/sketchybar/plugins/media_color.py" = {
    executable = true;
    text = ''
#!/usr/bin/env python3
"""Extract dominant album color + gradient for sketchybar media widget."""
import sys, pathlib, subprocess
from collections import Counter

GRADIENT_PATH = "/tmp/sketchybar_media_bg.png"

def extract_embedded(music_file, out="/tmp/sketchybar_art.jpg"):
    try:
        cmd = ["ffmpeg", "-y", "-i", str(music_file), "-an", "-vcodec", "copy", out]
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3)
        if pathlib.Path(out).exists() and pathlib.Path(out).stat().st_size > 1024:
            return pathlib.Path(out)
    except Exception:
        pass
    return None

def get_dominant(image_path):
    from PIL import Image
    try:
        im = Image.open(image_path).convert("RGB")
        im_small = im.resize((64,64), Image.BILINEAR)
        pixels = list(im_small.getdata())
        filtered = [c for c in pixels if not (c[0]<30 and c[1]<30 and c[2]<30) and not (c[0]>230 and c[1]>230 and c[2]>230)]
        if len(filtered) < 100:
            filtered = pixels
        quantized = [(c[0]//16*16, c[1]//16*16, c[2]//16*16) for c in filtered]
        cnt = Counter(quantized)
        common = cnt.most_common(10)
        for color,_ in common:
            r,g,b = color
            if r<30 and g<30 and b<30: continue
            if r>230 and g>230 and b>230: continue
            if max(color) < 60: continue
            if max(color)-min(color) < 12 and max(color) < 200:
                continue
            if r+g+b < 120: continue
            return color
        if common:
            return common[0][0]
        avg = tuple(sum(c[i] for c in pixels)//len(pixels) for i in range(3))
        return avg
    except Exception:
        return None

def get_top_colors(image_path, n=3):
    from PIL import Image
    try:
        im = Image.open(image_path).convert("RGB")
        im_small = im.resize((64,64), Image.BILINEAR)
        pixels = list(im_small.getdata())
        # keep white for MASSA - only filter pure black
        filtered = [c for c in pixels if not (c[0]<15 and c[1]<15 and c[2]<15)]
        if len(filtered) < 100:
            filtered = pixels
        quantized = [(c[0]//16*16, c[1]//16*16, c[2]//16*16) for c in filtered]
        cnt = Counter(quantized)
        common = cnt.most_common(25)
        top = []
        for color,_ in common:
            r,g,b = color
            if r<15 and g<15 and b<15: continue
            if max(color) < 35: continue
            # allow white, but skip mid-gray that is not vibrant
            if 80 < max(color) < 220 and max(color)-min(color) < 12:
                # keep white (230+) but skip gray
                if not (r>230 and g>230 and b>230):
                    continue
            if r+g+b < 80: continue
            # ensure distinct (RGB + hue) - for RHCP need red + blue
            too_similar = False
            for pc in top:
                if abs(pc[0]-r)<30 and abs(pc[1]-g)<30 and abs(pc[2]-b)<30:
                    too_similar = True
                    break
                import colorsys
                h1,s1,v1 = colorsys.rgb_to_hsv(pc[0]/255, pc[1]/255, pc[2]/255)
                h2,s2,v2 = colorsys.rgb_to_hsv(r/255, g/255, b/255)
                dh = abs(h1 - h2) * 360
                if dh > 180:
                    dh = 360 - dh
                # need both hue and value close to be considered similar (so tan vs red with same hue but different value are distinct)
                if dh < 35 and s1 > 0.12 and s2 > 0.12 and abs(v1-v2) < 0.25:
                    too_similar = True
                    break
            if too_similar:
                continue
            top.append(color)
            if len(top) >= n:
                break
        # if not enough distinct, return what we have (2 is fine for RHCP)
        # don't fill with similar - keep distinct only
        pass
        # lift dark
        lifted = []
        for r,g,b in top:
            if r+g+b < 150:
                r = min(255, int(r*1.5 + 40))
                g = min(255, int(g*1.5 + 40))
                b = min(255, int(b*1.5 + 40))
            lifted.append((r,g,b))
        # also brighten a bit for visibility (like main does 1.25)
        brightened = []
        for r,g,b in lifted:
            r = min(255, int(r*1.15))
            g = min(255, int(g*1.15))
            b = min(255, int(b*1.15))
            brightened.append((r,g,b))
        return brightened
    except Exception:
        return []

def generate_gradient(colors, out=GRADIENT_PATH, w=520, h=24):
    from PIL import Image, ImageDraw
    if not colors:
        return None
    if len(colors) == 1:
        colors = colors * 3
    elif len(colors) == 2:
        colors = [colors[0], colors[1], colors[1]]
    colors = colors[:3]
    # base gradient RGB
    base = Image.new("RGB", (w, h))
    for x in range(w):
        t = x / (w-1)
        if t < 0.5:
            lt = t*2
            r = int(colors[0][0]*(1-lt) + colors[1][0]*lt)
            g = int(colors[0][1]*(1-lt) + colors[1][1]*lt)
            b = int(colors[0][2]*(1-lt) + colors[1][2]*lt)
        else:
            lt = (t-0.5)*2
            r = int(colors[1][0]*(1-lt) + colors[2][0]*lt)
            g = int(colors[1][1]*(1-lt) + colors[2][1]*lt)
            b = int(colors[1][2]*(1-lt) + colors[2][2]*lt)
        for y in range(h):
            vf = 0.92 + 0.08 * (y / h)
            rr = min(255, int(r*vf))
            gg = min(255, int(g*vf))
            bb = min(255, int(b*vf))
            base.putpixel((x,y), (rr,gg,bb))
    # pill mask with rounded corners - no edge fade, solid pill on all sides
    r = h//2
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0,0,w-1,h-1], radius=r, fill=255)
    # no edge fade - solid pill, blend via background alpha only
    for x in range(w):
        a = 230
        for y in range(h):
            m = mask.getpixel((x,y))
            mask.putpixel((x,y), int(m * a / 255))
    out_im = Image.new("RGBA", (w, h))
    out_im.paste(base, (0,0))
    out_im.putalpha(mask)
    out_im.save(out, "PNG")
    return pathlib.Path(out)

def get_top_colors_for_music(music_file, n=3):
    """Helper for viz: find cover for music file and return top colors."""
    try:
        music_dir = pathlib.Path.home() / "Music"
        full = music_dir / music_file if music_file else None
        if full is None or not full.exists():
            full = pathlib.Path(music_file) if music_file else None
            if full is None or not full.exists():
                return []
        art_path = None
        for name in ("cover.jpg", "cover.jpeg", "folder.jpg", "front.jpg", "Cover.jpg"):
            cover = full.parent / name
            if cover.exists():
                art_path = cover
                break
        if art_path is None:
            tmp = pathlib.Path("/tmp/sketchybar_art.jpg")
            art = extract_embedded(full, str(tmp))
            if art and art.exists():
                art_path = art
        if art_path and art_path.exists():
            return get_top_colors(art_path, n)
    except Exception:
        pass
    return []

def get_cache_path(music_file):
    import hashlib
    h = hashlib.sha256(music_file.encode()).hexdigest()[:16]
    base = pathlib.Path.home() / ".cache/sketchybar/gradients"
    base.mkdir(parents=True, exist_ok=True)
    return base / f"{h}.png", base / f"{h}.col", base / f"{h}.key"

def main():
    default = "0xff68A2C6"
    mpc_file = sys.argv[1] if len(sys.argv) > 1 else ""
    # real bracket width, passed by media.sh after label+viz are already set
    # for the current track (querying bounding_rects, not the static
    # bracket width= override, which never reflected the true footprint)
    try:
        target_width = int(sys.argv[2]) if len(sys.argv) > 2 else 520
        target_width = max(200, min(900, target_width))
    except (ValueError, IndexError):
        target_width = 520
    # check cache first (for local music, gradients are pre-cached)
    # cache is keyed on file+width together - a width mismatch (e.g. from a
    # config change) must NOT reuse an old, wrongly-sized gradient image
    if mpc_file and mpc_file not in ("null", "(null)"):
        try:
            cp, col_p, key_p = get_cache_path(mpc_file)
            if cp.exists() and col_p.exists() and key_p.exists():
                key_contents = key_p.read_text().strip().split("\n")
                cached_file = key_contents[0] if len(key_contents) > 0 else ""
                cached_width = key_contents[1] if len(key_contents) > 1 else ""
                if cached_file == mpc_file and cached_width == str(target_width):
                    cached_col = col_p.read_text().strip()
                    import shutil
                    shutil.copy(str(cp), GRADIENT_PATH)
                    print(cached_col if cached_col else default)
                    return
        except Exception:
            pass
    if not mpc_file or mpc_file in ("null", "(null)"):
        print(default)
        return
    music_dir = pathlib.Path.home() / "Music"
    full = music_dir / mpc_file
    if not full.exists():
        full = pathlib.Path(mpc_file)
        if not full.exists():
            print(default)
            return
    art_path = None
    for name in ("cover.jpg", "cover.jpeg", "folder.jpg", "front.jpg", "Cover.jpg"):
        cover = full.parent / name
        if cover.exists():
            art_path = cover
            break
    if art_path is None:
        tmp = pathlib.Path("/tmp/sketchybar_art.jpg")
        art = extract_embedded(full, str(tmp))
        if art and art.exists():
            art_path = art
    if art_path is None or not art_path.exists():
        print(default)
        return
    # dominant for text
    col = get_dominant(art_path)
    if col is None:
        col = (104,162,198)
    r,g,b = col
    if r+g+b < 150:
        r = min(255, int(r*1.5 + 40))
        g = min(255, int(g*1.5 + 40))
        b = min(255, int(b*1.5 + 40))
        col = (r,g,b)
    # also brighten for main (like media.sh does 1.25)
    r2 = min(255, int(col[0]*1.25))
    g2 = min(255, int(col[1]*1.25))
    b2 = min(255, int(col[2]*1.25))
    # print dominant brightened for media text
    print(f"0xff{r2:02x}{g2:02x}{b2:02x}")
    # generate gradient of top 3 and cache it - width matches actual bracket width for true pill both sides
    try:
        top = get_top_colors(art_path, 3)
        if top:
            # target_width is the REAL rendered bracket width for this track,
            # queried live by media.sh right after setting the current
            # label/viz state - this is what makes the image actually match
            # the pill's true on-screen footprint instead of guessing
            generate_gradient(top, GRADIENT_PATH, w=target_width, h=24)
            # also save to cache dir for future fast hits
            try:
                cp, col_p, key_p = get_cache_path(mpc_file)
                import shutil
                shutil.copy(GRADIENT_PATH, str(cp))
                pathlib.Path(col_p).write_text(f"0xff{r2:02x}{g2:02x}{b2:02x}")
                pathlib.Path(key_p).write_text(f"{mpc_file}\n{target_width}")
            except Exception:
                pass
    except Exception as e:
        pass

if __name__ == "__main__":
    main()

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
