{ config, pkgs, lib, ... }:

{
  # Sketchybar configuration - theme-aware with Omarchy-style workspaces
  home.file.".config/sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
      #!/bin/sh
      PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

      # Colors will be overridden by theme
      BG_COLOR=0xE6181825
      FG_COLOR=0xffc0caf5
      ACCENT_COLOR=0xff7aa2f7
      INACTIVE_COLOR=0x667E8A94
      BAR_HEIGHT=32
      MARGIN=4
      Y_OFFSET=4
      CORNER_RADIUS=16

      sketchybar --bar position=top height=$BAR_HEIGHT margin=$MARGIN y_offset=$Y_OFFSET corner_radius=$CORNER_RADIUS border_width=0 blur_radius=20 color=$BG_COLOR padding_left=8 padding_right=8 notch_width=0

      default=(padding_left=4 padding_right=4 icon.font="JetBrainsMono Nerd Font:Bold:12.0" label.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=$FG_COLOR label.color=$FG_COLOR background.height=22 background.corner_radius=11 icon.padding_left=6 icon.padding_right=6 label.padding_left=0 label.padding_right=6)

      sketchybar --default "''${default[@]}"

      # Workspaces (match AeroSpace config)
      sketchybar --add event aerospace_workspace_change
      for sid in 1-web 2-code 3-term 4-chat 5-media 6-games 7-docs 8-sys 9-vm 10-misc; do
        num="''${sid%%-*}"
        [ "$num" = "10" ] && display="0" || display="$num"
        sketchybar --add item "workspace.$sid" left \
          --set "workspace.$sid" icon="$display" label.drawing=off background.drawing=off background.color=0x40116FAE background.corner_radius=11 background.height=22 background.padding_left=2 background.padding_right=2 \
          script="$PLUGIN_DIR/aerospace.sh" click_script="aerospace workspace $sid" \
          --subscribe "workspace.$sid" aerospace_workspace_change
      done

      # Front app
      sketchybar --add item front_app center \
        --set front_app icon.drawing=off label.max_chars=28 label.color=0xff7E8A94 \
        script="$PLUGIN_DIR/front_app.sh" \
        --subscribe front_app front_app_switched

      # Media
      sketchybar --add item media center \
        --set media icon="" icon.color=$ACCENT_COLOR label.max_chars=30 scroll_texts=on label.scroll_duration=140 label.color=$ACCENT_COLOR drawing=off update_freq=2 \
        script="$PLUGIN_DIR/media.sh" click_script="$PLUGIN_DIR/media_click.sh"

      # Right side: cpu, mem, net, battery, volume, clock
      sketchybar --add item cpu right --set cpu update_freq=5 icon="" icon.color=$ACCENT_COLOR script="$PLUGIN_DIR/cpu.sh"
      sketchybar --add item mem right --set mem update_freq=10 icon="" icon.color=$ACCENT_COLOR script="$PLUGIN_DIR/memory.sh"
      sketchybar --add item net right --set net update_freq=15 icon="󰖩" icon.color=$ACCENT_COLOR script="$PLUGIN_DIR/network.sh"
      sketchybar --add item battery right --set battery update_freq=60 icon.color=$ACCENT_COLOR script="$PLUGIN_DIR/battery.sh" --subscribe battery system_woke power_source_change
      sketchybar --add item volume right --set volume icon.color=0xff305561 script="$PLUGIN_DIR/volume.sh" --subscribe volume volume_change
      sketchybar --add item clock right --set clock icon="" icon.color=$ACCENT_COLOR update_freq=30 script="$PLUGIN_DIR/clock.sh"

      sketchybar --update

      # Trigger initial workspace update
      FOCUSED="''$(aerospace list-workspaces --focused 2>/dev/null || echo "1-web")"
      sketchybar --trigger aerospace_workspace_change FOCUSED="$FOCUSED"
    '';
  };

  # Aerospace workspace plugin
  home.file.".config/sketchybar/plugins/aerospace.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -z "$FOCUSED" ]; then FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null)"; fi
      WORKSPACE="''${NAME#workspace.}"
      if [ "$WORKSPACE" = "$FOCUSED" ]; then
        sketchybar --set "$NAME" background.drawing=on background.color=0xff116FAE icon.color=0xff04182F
      else
        COUNT="$(aerospace list-windows --workspace "$WORKSPACE" --count 2>/dev/null || echo 0)"
        if [ "$COUNT" -eq 0 ]; then
          sketchybar --set "$NAME" background.drawing=off icon.color=0x667E8A94
        else
          sketchybar --set "$NAME" background.drawing=off icon.color=0xff68A2C6
        fi
      fi
    '';
  };

  # Clock plugin
  home.file.".config/sketchybar/plugins/clock.sh" = { executable = true; text = '' #!/bin/sh
sketchybar --set "$NAME" label="$(date '+%a %d  %I:%M %p')" ''; };

  # Front app plugin
  home.file.".config/sketchybar/plugins/front_app.sh" = { executable = true; text = '' #!/bin/sh
if [ "$SENDER" = "front_app_switched" ]; then sketchybar --set "$NAME" label="$INFO"; fi ''; };

  # Battery plugin
  home.file.".config/sketchybar/plugins/battery.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      PERCENTAGE="''$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)"
      CHARGING="''$(pmset -g batt | grep 'AC Power')"
      [ -z "$PERCENTAGE" ] && exit 0
      case "$PERCENTAGE" in
        9[0-9]|100) ICON="" ;;
        [6-8][0-9]) ICON="" ;;
        [3-5][0-9]) ICON="" ;;
        [1-2][0-9]) ICON="" ;;
        *) ICON="" ;;
      esac
      [ -n "$CHARGING" ] && ICON=""
      if [ "$PERCENTAGE" -lt 20 ] && [ -z "$CHARGING" ]; then COLOR="0xffff6b6b"
      elif [ "$PERCENTAGE" -lt 40 ] && [ -z "$CHARGING" ]; then COLOR="0xffe8a87c"
      else COLOR="0xff68A2C6"; fi
      sketchybar --set "$NAME" icon="$ICON" label="''${PERCENTAGE}%" icon.color="$COLOR" label.color="$COLOR"
    '';
  };

  # Volume plugin
  home.file.".config/sketchybar/plugins/volume.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ "$SENDER" = "volume_change" ]; then
        VOLUME="$INFO"
        case "$VOLUME" in
          [6-9][0-9]|100) ICON="󰕾" ;;
          [3-5][0-9]) ICON="󰖀" ;;
          [1-9]|[1-2][0-9]) ICON="󰕿" ;;
          *) ICON="󰖁" ;;
        esac
        sketchybar --set "$NAME" icon="$ICON" label="''${VOLUME}%"
      fi
    '';
  };

  # CPU plugin
  home.file.".config/sketchybar/plugins/cpu.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      CPU="''$(ps -A -o %cpu | awk '{s+=$1} END {printf "%d", s}')"
      CORES="''$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
      AVG=$((CPU / CORES))
      [ "$AVG" -gt 100 ] && AVG=100
      if [ "$AVG" -gt 80 ]; then COLOR="0xffe8a87c"
      elif [ "$AVG" -gt 50 ]; then COLOR="0xff68A2C6"
      else COLOR="0xff7E8A94"; fi
      sketchybar --set "$NAME" label="''${AVG}%" icon.color="$COLOR" label.color="$COLOR"
    '';
  };

  # Memory plugin (simplified)
  home.file.".config/sketchybar/plugins/memory.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Use memory_pressure for a simple percentage
      PRESSURE="''$(memory_pressure 2>&1 | grep "System-wide memory free percentage:" | awk '{print 100 - $5}' | tr -d '%' || echo 50)"
      if [ "$PRESSURE" -gt 80 ]; then COLOR="0xffff6b6b"
      elif [ "$PRESSURE" -gt 60 ]; then COLOR="0xffe8a87c"
      else COLOR="0xff68A2C6"; fi
      sketchybar --set "$NAME" label="''${PRESSURE}%" icon.color="$COLOR" label.color="$COLOR"
    '';
  };

  # Network plugin
  home.file.".config/sketchybar/plugins/network.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      WIFI_IP="''$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"
      WIFI_POWER="''$(networksetup -getairportpower en0 2>/dev/null)"
      echo "$WIFI_POWER" | grep -q "On" && POWER_ON=1 || POWER_ON=0

      if [ -n "$WIFI_IP" ]; then
        SSID="''$(networksetup -getairportnetwork en0 2>/dev/null | sed -n 's/.*: "\(.*\)".*/\1/p')"
        if [ -z "$SSID" ] || echo "$SSID" | grep -qi "not associated\|redacted"; then
          SSID="''$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Current Network Information:/{getline; gsub(/^[ \t]+/,"",$0); gsub(/:$/,"",$0); print; exit}')"
        fi
        if echo "$SSID" | grep -qi "redacted"; then SSID=""; fi
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

      # Tailscale indicator
      TS="''$(/Applications/Tailscale.app/Contents/MacOS/Tailscale status 2>&1 | head -n 5 || tailscale status 2>&1 | head -n 5)"
      if echo "$TS" | grep -q "Tailscale is stopped"; then TS_BADGE=""; else TS_BADGE=" 󰖂"; fi
      # WARP indicator
      if scutil --nc list 2>&1 | grep -q "WARP"; then WARP_BADGE=" 󰦝"; else WARP_BADGE=""; fi

      sketchybar --set "$NAME" icon="$ICON" label="''${LABEL}''${TS_BADGE}''${WARP_BADGE}" icon.color="$COLOR"
    '';
  };
}