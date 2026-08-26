{ config, pkgs, lib, ... }:

{
  # Minimalist SketchyBar — everforest pill, ADHD-friendly
  # Single accent (#5ba3c9 blue), no reds, dim empty workspaces
  # Coexists with Vorssaint (volume/monitor) + Boring Notch (notch)

  home.file.".config/sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
      #!/bin/sh
      PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

      # ── Bar — floating pill, 44px clear via aerospace gaps.outer.top ──
      sketchybar --bar \
        position=top height=32 margin=8 y_offset=4 corner_radius=9 \
        border_width=0 blur_radius=20 color=0xE60d1b2a \
        padding_left=8 padding_right=8 notch_width=0

      default=(
        padding_left=4 padding_right=4
        icon.font="JetBrainsMono Nerd Font:Bold:12.0"
        label.font="JetBrainsMono Nerd Font:Bold:12.0"
        icon.color=0xffcdd9e5 label.color=0xffcdd9e5
        background.height=22 background.corner_radius=6
        icon.padding_left=6 icon.padding_right=6
        label.padding_left=0 label.padding_right=6
      )
      sketchybar --default "''${default[@]}"

      sketchybar --add event aerospace_workspace_change

      # ── Left: AeroSpace workspaces 1..0 (polybar-style) ──
      for sid in 1-browsers 2-chat 3-mail 4-code 5-terminal 6-docs 7-media 8-games 9-security 10-vms; do
        num="''${sid%%-*}"; [ "$num" = "10" ] && display="0" || display="$num"
        sketchybar --add item "workspace.$sid" left \
          --set "workspace.$sid" icon="$display" label.drawing=off \
            background.drawing=off background.color=0x405ba3c9 \
            background.corner_radius=6 background.height=22 \
            background.padding_left=2 background.padding_right=2 \
            script="$PLUGIN_DIR/aerospace.sh" \
            click_script="aerospace workspace $sid" \
          --subscribe "workspace.$sid" aerospace_workspace_change
      done

      # ── Center: focused app (helps ADHD context) ──
      sketchybar --add item front_app center \
        --set front_app icon.drawing=off label.max_chars=28 \
          label.color=0xffa8c8e8 \
          script="$PLUGIN_DIR/front_app.sh" \
        --subscribe front_app front_app_switched

      # ── Right: battery, volume, clock (volume from Vorssaint domain but shown here if you want unified) ──
      sketchybar --add item battery right \
        --set battery update_freq=60 \
          icon.color=0xffcdd9e5 \
          script="$PLUGIN_DIR/battery.sh" \
        --subscribe battery system_woke power_source_change

      sketchybar --add item volume right \
        --set volume icon.color=0xff6ec6c6 \
          script="$PLUGIN_DIR/volume.sh" \
        --subscribe volume volume_change

      sketchybar --add item clock right \
        --set clock icon="" icon.color=0xff8eafd4 \
          update_freq=30 script="$PLUGIN_DIR/clock.sh"

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
      if [ "$WORKSPACE" = "$FOCUSED" ]; then
        sketchybar --set "$NAME" background.drawing=on background.color=0xff5ba3c9 icon.color=0xff0d1b2a
      else
        COUNT="$(aerospace list-windows --workspace "$WORKSPACE" --count 2>/dev/null || echo 0)"
        if [ "$COUNT" -eq 0 ]; then
          sketchybar --set "$NAME" background.drawing=off icon.color=0x66cdd9e5
        else
          sketchybar --set "$NAME" background.drawing=off icon.color=0xffcdd9e5
        fi
      fi
    '';
  };

  home.file.".config/sketchybar/plugins/clock.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # AM/PM 12h — ADHD-friendly, no 24h mental math
      sketchybar --set "$NAME" label="$(date '+%a %d  %I:%M %p')"
    '';
  };

  home.file.".config/sketchybar/plugins/front_app.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ "$SENDER" = "front_app_switched" ]; then
        # Trim bundle noise, show app name
        sketchybar --set "$NAME" label="$INFO"
      fi
    '';
  };

  home.file.".config/sketchybar/plugins/battery.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      PERCENTAGE="$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)"
      CHARGING="$(pmset -g batt | grep 'AC Power')"
      [ -z "$PERCENTAGE" ] && exit 0
      case "$PERCENTAGE" in
        9[0-9]|100) ICON="" ;;
        [6-8][0-9]) ICON="" ;;
        [3-5][0-9]) ICON="" ;;
        [1-2][0-9]) ICON="" ;;
        *) ICON="" ;;
      esac
      [ -n "$CHARGING" ] && ICON=""
      # ADHD: dim battery when >30% and charging, highlight only when low
      if [ "$PERCENTAGE" -lt 20 ] && [ -z "$CHARGING" ]; then
        COLOR="0xffff6b6b"
      elif [ "$PERCENTAGE" -lt 40 ] && [ -z "$CHARGING" ]; then
        COLOR="0xffe8a87c"
      else
        COLOR="0xffcdd9e5"
      fi
      sketchybar --set "$NAME" icon="$ICON" label="''${PERCENTAGE}%" icon.color="$COLOR" label.color="$COLOR"
    '';
  };

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
        # Muted check — if you have muted, SketchyBar sends 0 with muted flag elsewhere, keep simple
        sketchybar --set "$NAME" icon="$ICON" label="''${VOLUME}%"
      fi
    '';
  };
}
