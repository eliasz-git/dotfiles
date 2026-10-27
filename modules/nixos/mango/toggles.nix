{ config, lib, pkgs, ... }:

let
  # Toggle scripts for Mango - can be bound to keys or run via CLI.
  # These modify runtime state without rebuild.
  #
  # mango has no IPC equivalent of hyprctl getoption, so each toggle keeps its
  # own state file under ~/.cache/tundra. The scripts flip options with
  #   mmsg dispatch setoption,<key>,<value>
  # which is the runtime-only equivalent of a config keyword (see bind.c:
  # setoption -> parse_option + override_config).
  toggledir = "$HOME/.cache/tundra";

  # A user unit gets a minimal PATH. The scripts start with `#!/usr/bin/env
  # bash` and call mmsg (user profile, from the mango hm module), notify-send,
  # sed, grep, cat and systemctl, so each of those locations is named here.
  togglePath =
    lib.makeBinPath [
      pkgs.bash
      pkgs.coreutils
      pkgs.gnused
      pkgs.gnugrep
      pkgs.libnotify
      pkgs.systemd
    ]
    + ":"
    + "${config.home.profileDirectory}/bin";
in
{
  # Animation toggle
  systemd.user.services.mango-toggle-animations = {
    Unit.Description = "Toggle Mango animations";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${togglePath}";
      ExecStart = "${pkgs.writeScriptBin "mango-toggle-animations" ''
        #!/usr/bin/env bash
        CURRENT=1
        [ -f ${toggledir}/animations ] && CURRENT=$(cat ${toggledir}/animations)
        if [ "$CURRENT" = "1" ]; then
          mmsg dispatch setoption,animations,0
          echo 0 > ${toggledir}/animations
          notify-send "Animations disabled"
        else
          mmsg dispatch setoption,animations,1
          echo 1 > ${toggledir}/animations
          notify-send "Animations enabled"
        fi
      ''}/bin/mango-toggle-animations";
    };
  };

  # Blur toggle (flips the global window blur; the optimized preset stays on)
  systemd.user.services.mango-toggle-blur = {
    Unit.Description = "Toggle Mango blur";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${togglePath}";
      ExecStart = "${pkgs.writeScriptBin "mango-toggle-blur" ''
        #!/usr/bin/env bash
        CURRENT=1
        [ -f ${toggledir}/blur ] && CURRENT=$(cat ${toggledir}/blur)
        if [ "$CURRENT" = "1" ]; then
          mmsg dispatch setoption,blur,0
          echo 0 > ${toggledir}/blur
          notify-send "Blur disabled"
        else
          mmsg dispatch setoption,blur,1
          echo 1 > ${toggledir}/blur
          notify-send "Blur enabled"
        fi
      ''}/bin/mango-toggle-blur";
    };
  };

  # Gaps toggle (0 <-> inner 5 / outer 10)
  systemd.user.services.mango-toggle-gaps = {
    Unit.Description = "Toggle Mango gaps";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${togglePath}";
      ExecStart = "${pkgs.writeScriptBin "mango-toggle-gaps" ''
        #!/usr/bin/env bash
        CURRENT=0
        [ -f ${toggledir}/gaps ] && CURRENT=$(cat ${toggledir}/gaps)
        if [ "$CURRENT" = "0" ]; then
          mmsg dispatch setoption,gap_inner_horizontal,5
          mmsg dispatch setoption,gap_inner_vertical,5
          mmsg dispatch setoption,gap_outer_horizontal,10
          mmsg dispatch setoption,gap_outer_vertical,10
          echo 1 > ${toggledir}/gaps
          notify-send "Gaps enabled"
        else
          mmsg dispatch setoption,gap_inner_horizontal,0
          mmsg dispatch setoption,gap_inner_vertical,0
          mmsg dispatch setoption,gap_outer_horizontal,0
          mmsg dispatch setoption,gap_outer_vertical,0
          echo 0 > ${toggledir}/gaps
          notify-send "Gaps disabled"
        fi
      ''}/bin/mango-toggle-gaps";
    };
  };

  # Opacity toggle (normal 1.0/0.9 <-> reduced 0.9/0.8)
  systemd.user.services.mango-toggle-opacity = {
    Unit.Description = "Toggle window opacity";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${togglePath}";
      ExecStart = "${pkgs.writeScriptBin "mango-toggle-opacity" ''
        #!/usr/bin/env bash
        CURRENT=1
        [ -f ${toggledir}/opacity ] && CURRENT=$(cat ${toggledir}/opacity)
        if [ "$CURRENT" = "1" ]; then
          mmsg dispatch setoption,focused_opacity,0.9
          mmsg dispatch setoption,unfocused_opacity,0.8
          echo 0 > ${toggledir}/opacity
          notify-send "Opacity reduced"
        else
          mmsg dispatch setoption,focused_opacity,1.0
          mmsg dispatch setoption,unfocused_opacity,0.9
          echo 1 > ${toggledir}/opacity
          notify-send "Opacity normal"
        fi
      ''}/bin/mango-toggle-opacity";
    };
  };

  # VRR toggle (FreeSync). mango only knows VRR per-monitor via monitor_rule,
  # so we rewrite the sourced ~/.config/tundra/mango-vrr.conf (which carries
  # the full Philips rule, seeded by home.nix) and reload the config.
  systemd.user.services.mango-toggle-vrr = {
    Unit.Description = "Toggle VRR (FreeSync)";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${togglePath}";
      ExecStart = "${pkgs.writeScriptBin "mango-toggle-vrr" ''
        #!/usr/bin/env bash
        VRR_CONF="$HOME/.config/tundra/mango-vrr.conf"
        if grep -q ',vrr:1\$' "$VRR_CONF" 2>/dev/null; then
          sed -i 's/,vrr:1/,vrr:0/' "$VRR_CONF"
          notify-send "VRR disabled"
        else
          sed -i 's/,vrr:0/,vrr:1/' "$VRR_CONF"
          notify-send "VRR enabled"
        fi
        mmsg dispatch reload_config
      ''}/bin/mango-toggle-vrr";
    };
  };

  # Idle/suspend toggle
  systemd.user.services.mango-toggle-idle = {
    Unit.Description = "Toggle idle management";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${togglePath}";
      ExecStart = "${pkgs.writeScriptBin "mango-toggle-idle" ''
        #!/usr/bin/env bash
        if systemctl --user is-active swayidle >/dev/null 2>&1; then
          systemctl --user stop swayidle
          notify-send "Idle management stopped"
        else
          systemctl --user start swayidle
          notify-send "Idle management started"
        fi
      ''}/bin/mango-toggle-idle";
    };
  };

  # Night light toggle (wlsunset)
  systemd.user.services.mango-toggle-nightlight = {
    Unit.Description = "Toggle night light (wlsunset)";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${togglePath}";
      ExecStart = "${pkgs.writeScriptBin "mango-toggle-nightlight" ''
        #!/usr/bin/env bash
        if systemctl --user is-active wlsunset >/dev/null 2>&1; then
          systemctl --user stop wlsunset
          notify-send "Night light disabled"
        else
          systemctl --user start wlsunset
          notify-send "Night light enabled"
        fi
      ''}/bin/mango-toggle-nightlight";
    };
  };
}