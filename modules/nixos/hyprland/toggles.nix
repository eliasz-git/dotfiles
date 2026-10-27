{ config, lib, pkgs, ... }:

{
  # Toggle scripts for Hyprland - can be bound to keys or run via CLI
  # These modify runtime state without rebuild

  # Animation toggle
  systemd.user.services.hypr-toggle-animations = {
    Unit.Description = "Toggle Hyprland animations";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin "hypr-toggle-animations" ''
        #!/usr/bin/env bash
        CURRENT=$(hyprctl getoption animations:enabled -j | jq -r '.int')
        if [ "$CURRENT" = "1" ]; then
          hyprctl keyword animations:enabled 0
          notify-send "Animations disabled"
        else
          hyprctl keyword animations:enabled 1
          notify-send "Animations enabled"
        fi
      ''}/bin/hypr-toggle-animations";
    };
  };

  # Blur toggle
  systemd.user.services.hypr-toggle-blur = {
    Unit.Description = "Toggle Hyprland blur";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin "hypr-toggle-blur" ''
        #!/usr/bin/env bash
        CURRENT=$(hyprctl getoption decoration:blur:enabled -j | jq -r '.int')
        if [ "$CURRENT" = "1" ]; then
          hyprctl keyword decoration:blur:enabled 0
          notify-send "Blur disabled"
        else
          hyprctl keyword decoration:blur:enabled 1
          notify-send "Blur enabled"
        fi
      ''}/bin/hypr-toggle-blur";
    };
  };

  # Gaps toggle
  systemd.user.services.hypr-toggle-gaps = {
    Unit.Description = "Toggle Hyprland gaps";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin "hypr-toggle-gaps" ''
        #!/usr/bin/env bash
        CURRENT_IN=$(hyprctl getoption general:gaps_in -j | jq -r '.int')
        if [ "$CURRENT_IN" = "0" ]; then
          hyprctl keyword general:gaps_in 5
          hyprctl keyword general:gaps_out 10
          notify-send "Gaps enabled"
        else
          hyprctl keyword general:gaps_in 0
          hyprctl keyword general:gaps_out 0
          notify-send "Gaps disabled"
        fi
      ''}/bin/hypr-toggle-gaps";
    };
  };

  # Opacity toggle
  systemd.user.services.hypr-toggle-opacity = {
    Unit.Description = "Toggle window opacity";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin "hypr-toggle-opacity" ''
        #!/usr/bin/env bash
        CURRENT=$(hyprctl getoption decoration:active_opacity -j | jq -r '.float')
        if [ "$CURRENT" = "1" ]; then
          hyprctl keyword decoration:active_opacity 0.9
          hyprctl keyword decoration:inactive_opacity 0.8
          notify-send "Opacity reduced"
        else
          hyprctl keyword decoration:active_opacity 1.0
          hyprctl keyword decoration:inactive_opacity 0.9
          notify-send "Opacity normal"
        fi
      ''}/bin/hypr-toggle-opacity";
    };
  };

  # VRR toggle
  systemd.user.services.hypr-toggle-vrr = {
    Unit.Description = "Toggle VRR (FreeSync)";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin "hypr-toggle-vrr" ''
        #!/usr/bin/env bash
        CURRENT=$(hyprctl getoption misc:vrr -j | jq -r '.int')
        if [ "$CURRENT" = "2" ]; then
          hyprctl keyword misc:vrr 0
          notify-send "VRR disabled"
        else
          hyprctl keyword misc:vrr 2
          notify-send "VRR enabled (fullscreen only)"
        fi
      ''}/bin/hypr-toggle-vrr";
    };
  };

  # Idle/suspend toggle
  systemd.user.services.hypr-toggle-idle = {
    Unit.Description = "Toggle idle management";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin "hypr-toggle-idle" ''
        #!/usr/bin/env bash
        if systemctl --user is-active hypridle >/dev/null 2>&1; then
          systemctl --user stop hypridle
          notify-send "Idle management stopped"
        else
          systemctl --user start hypridle
          notify-send "Idle management started"
        fi
      ''}/bin/hypr-toggle-idle";
    };
  };

  # Night light toggle (hyprsunset)
  systemd.user.services.hypr-toggle-nightlight = {
    Unit.Description = "Toggle night light (hyprsunset)";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin "hypr-toggle-nightlight" ''
        #!/usr/bin/env bash
        if systemctl --user is-active hyprsunset >/dev/null 2>&1; then
          systemctl --user stop hyprsunset
          notify-send "Night light disabled"
        else
          systemctl --user start hyprsunset
          notify-send "Night light enabled"
        fi
      ''}/bin/hypr-toggle-nightlight";
    };
  };
}