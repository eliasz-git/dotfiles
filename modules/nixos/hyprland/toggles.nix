{ config, lib, pkgs, ... }:

{
  # Toggle scripts for Hyprland - can be bound to keys or run via CLI
  # These modify runtime state without rebuild

  # Animation toggle
  systemd.user.services.hypr-toggle-animations = {
    description = "Toggle Hyprland animations";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin \"hypr-toggle-animations\" ''\n        #!/usr/bin/env bash\n        CURRENT=$(hyprctl getoption animations:enabled -j | jq -r '.int')\n        if [ \"$CURRENT\" = \"1\" ]; then\n          hyprctl keyword animations:enabled 0\n          notify-send \"Animations disabled\"\n        else\n          hyprctl keyword animations:enabled 1\n          notify-send \"Animations enabled\"\n        fi\n      ''}/bin/hypr-toggle-animations";
    };
  };

  # Blur toggle
  systemd.user.services.hypr-toggle-blur = {
    description = "Toggle Hyprland blur";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin \"hypr-toggle-blur\" ''\n        #!/usr/bin/env bash\n        CURRENT=$(hyprctl getoption decoration:blur:enabled -j | jq -r '.int')\n        if [ \"$CURRENT\" = \"1\" ]; then\n          hyprctl keyword decoration:blur:enabled 0\n          notify-send \"Blur disabled\"\n        else\n          hyprctl keyword decoration:blur:enabled 1\n          notify-send \"Blur enabled\"\n        fi\n      ''}/bin/hypr-toggle-blur";
    };
  };

  # Gaps toggle
  systemd.user.services.hypr-toggle-gaps = {
    description = "Toggle Hyprland gaps";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin \"hypr-toggle-gaps\" ''\n        #!/usr/bin/env bash\n        CURRENT_IN=$(hyprctl getoption general:gaps_in -j | jq -r '.int')\n        if [ \"$CURRENT_IN\" = \"0\" ]; then\n          hyprctl keyword general:gaps_in 5\n          hyprctl keyword general:gaps_out 10\n          notify-send \"Gaps enabled\"\n        else\n          hyprctl keyword general:gaps_in 0\n          hyprctl keyword general:gaps_out 0\n          notify-send \"Gaps disabled\"\n        fi\n      ''}/bin/hypr-toggle-gaps";
    };
  };

  # Opacity toggle
  systemd.user.services.hypr-toggle-opacity = {
    description = "Toggle window opacity";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin \"hypr-toggle-opacity\" ''\n        #!/usr/bin/env bash\n        CURRENT=$(hyprctl getoption decoration:active_opacity -j | jq -r '.float')\n        if [ \"$CURRENT\" = \"1\" ]; then\n          hyprctl keyword decoration:active_opacity 0.9\n          hyprctl keyword decoration:inactive_opacity 0.8\n          notify-send \"Opacity reduced\"\n        else\n          hyprctl keyword decoration:active_opacity 1.0\n          hyprctl keyword decoration:inactive_opacity 0.9\n          notify-send \"Opacity normal\"\n        fi\n      ''}/bin/hypr-toggle-opacity";
    };
  };

  # VRR toggle
  systemd.user.services.hypr-toggle-vrr = {
    description = "Toggle VRR (FreeSync)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin \"hypr-toggle-vrr\" ''\n        #!/usr/bin/env bash\n        CURRENT=$(hyprctl getoption misc:vrr -j | jq -r '.int')\n        if [ \"$CURRENT\" = \"2\" ]; then\n          hyprctl keyword misc:vrr 0\n          notify-send \"VRR disabled\"\n        else\n          hyprctl keyword misc:vrr 2\n          notify-send \"VRR enabled (fullscreen only)\"\n        fi\n      ''}/bin/hypr-toggle-vrr";
    };
  };

  # Idle/suspend toggle
  systemd.user.services.hypr-toggle-idle = {
    description = "Toggle idle management";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin \"hypr-toggle-idle\" ''\n        #!/usr/bin/env bash\n        if systemctl --user is-active hypridle >/dev/null 2>&1; then\n          systemctl --user stop hypridle\n          notify-send \"Idle management stopped\"\n        else\n          systemctl --user start hypridle\n          notify-send \"Idle management started\"\n        fi\n      ''}/bin/hypr-toggle-idle";
    };
  };

  # Night light toggle (hyprsunset)
  systemd.user.services.hypr-toggle-nightlight = {
    description = "Toggle night light (hyprsunset)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScriptBin \"hypr-toggle-nightlight\" ''\n        #!/usr/bin/env bash\n        if systemctl --user is-active hyprsunset >/dev/null 2>&1; then\n          systemctl --user stop hyprsunset\n          notify-send \"Night light disabled\"\n        else\n          systemctl --user start hyprsunset\n          notify-send \"Night light enabled\"\n        fi\n      ''}/bin/hypr-toggle-nightlight";
    };
  };
}