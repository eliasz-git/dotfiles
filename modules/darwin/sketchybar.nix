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
      # Right: cpu, mem, net (tailscale/warp), battery, volume, clock
      sketchybar --add item cpu right --set cpu update_freq=5 icon="" icon.color=0xff68A2C6 script="$PLUGIN_DIR/cpu.sh"
      sketchybar --add item mem right --set mem update_freq=10 icon="" icon.color=0xff68A2C6 script="$PLUGIN_DIR/memory.sh"
      sketchybar --add item net right --set net update_freq=30 icon="󰖩" icon.color=0xff305561 script="$PLUGIN_DIR/network.sh"
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
      # Tailscale + WARP dot
      TS="$(/Applications/Tailscale.app/Contents/MacOS/Tailscale status 2>&1 | head -n 5 || tailscale status 2>&1 | head -n 5)"
      if echo "$TS" | grep -q "Tailscale is stopped"; then TS_ICON="󰖪"; TS_COLOR="0x667E8A94"; else TS_ICON="󰖩"; TS_COLOR="0xff68A2C6"; fi
      # WARP check
      if scutil --nc list 2>&1 | grep -q "WARP"; then W_ICON="󰖂"; else W_ICON=""; fi
      sketchybar --set "$NAME" icon="$TS_ICON" label="$W_ICON" icon.color="$TS_COLOR"
    '';
  };
}
