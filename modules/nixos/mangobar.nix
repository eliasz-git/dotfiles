{ config, lib, pkgs, mangobar, ... }:

# Top bar (mangobar).
#
# Home Manager cannot generate the CSS that mangobar itself does not declare, so
# the module ships structure here and colour in a runtime fragment, exactly like
# waybar did:
#
#   - config.jsonc is produced by services.mangobar.settings;
#   - style.css is produced by xdg.configFile just below, and imports the
#     theme fragment as its first statement. mangobar's CSS parser inlines an
#     @import at the point it appears, so the fragment's @define-color lines
#     are registered before any rule that references them with @name syntax.
#   - the fragment (~/.config/tundra/colors/mangobar.css) is written by
#     tundra-theme-apply; a missing import is logged and skipped, it does not
#     kill the bar the way an unresolvable waybar @import did.
#
# mangobar's @import only accepts paths that start with / or ~ (expand_tilde),
# not file:// URLs, so the url is a tilde path.
{
  services.mangobar = {
    enable = true;

    # Teach mangobar to substitute `{}` in workspace click commands with the
    # 1-based tag. Clicks then go through tundra-focus-tag instead of the
    # built-in `dispatch view,N`, which can duplicate an index across outputs.
    package = mangobar.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ./patches/mangobar-focus-tag.patch ];
    });

    # The mangos hm module owns the session target, so the bar lives there.
    systemdTarget = "mango-session.target";
    settings = {
      layer = "top";
      position = "top";
      height = 32;
      buffer-scale = 1;
      "modules-left" = [ "workspaces" ];
      "modules-center" = [ "window" "custom/media" ];
      "modules-right" = [ "cpu" "memory" "network" "tray" "pulseaudio" "clock" ];

      # Show only workspaces in use, with an OVERVIEW label for the overview
      # toggled by SUPER+TAB. Clicks go through tundra-focus-tag, so a
      # workspace index is only ever active on one output: left focuses it
      # wherever it lives, right sends the focused window there. The `{}`
      # substitution comes from the patch above.
      workspaces = {
        "hide-empty" = true;
        "overview-label" = "OVERVIEW";
        "on-click" = "${config.home.homeDirectory}/.local/bin/tundra-focus-tag {}";
        "on-click-right" = "${config.home.homeDirectory}/.local/bin/tundra-focus-tag -m {}";
      };

      window.format = "{}"; # titles truncate to 50 chars built-in

      clock.format = "󰥔 {:L%a %d  %I:%M %p}";

      cpu = {
        format = " {load}%";
        interval = 5;
      };
      memory = {
        format = "󰍛 {}%";
        interval = 5;
      };
      network = {
        format = "{icon}";
        "format-wifi" = "󰖩";
        "format-ethernet" = "󰈀";
        "format-disconnected" = "󰖪";
        "icon-wifi" = "󰖩";
        "icon-ethernet" = "󰈀";
        "icon-disconnected" = "󰖪";
        interval = 10;
      };
      pulseaudio = {
        format = "󰕾 {volume}%";
        "format-muted" = "󰖁 muted";
        on-click = "pavucontrol";
      };
      "custom/media" = {
        format = "{}";
        # Match the SketchyBar media item: label only, hidden while stopped.
        exec = ''
          status=$(playerctl status 2>/dev/null) || exit 0
          case "$status" in
            Playing|Paused) ;;
            *) exit 0 ;;
          esac
          title=$(playerctl metadata title 2>/dev/null)
          artist=$(playerctl metadata artist 2>/dev/null)
          [ -n "$title" ] || title="Unknown title"
          if [ -n "$artist" ] && [ "$artist" != "$title" ]; then
            printf "%s — %s" "$title" "$artist"
          else
            printf "%s" "$title"
          fi
        '';
        interval = 5;
        on-click = "playerctl play-pause";
        on-click-right = "playerctl next";
      };
    };
  };

  xdg.configFile."mangobar/style.css".text = ''
    @import url("~/.config/tundra/colors/mangobar.css");

    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 12px;
      font-weight: 700;
      color: @tundra-text;
      background-color: transparent;
      padding: 0 8px;
      margin: 0;
      border-radius: 8px;
    }

    #bar {
      background-color: transparent;
      border-radius: 16px;
      margin: 4px;
      padding: 0 8px;
    }

    #tags {
      background-color: transparent;
      border-radius: 11px;
      margin: 0 1px;
      padding: 0 8px;
    }
    #tags.empty {
      color: @tundra-subtext0;
    }
    #tags.occupied {
      color: @tundra-subtext1;
    }
    #tags.active {
      background-color: @tundra-blue;
      color: @tundra-base;
    }
    #tags.urgent {
      background-color: @tundra-red;
      color: @tundra-base;
    }
    #tags:hover {
      background-color: alpha(@tundra-blue, 0.35);
    }

    #layout {
      color: @tundra-blue;
      min-width: 20px;
    }
    #title {
      color: @tundra-subtext0;
    }
    #clock {
      color: @tundra-text;
      padding: 0 4px 0 10px;
    }
    #clock.date {
      color: @tundra-subtext1;
    }

    #cpu {
      color: @tundra-blue;
    }
    #mem {
      color: @tundra-green;
    }
    #network {
      color: @tundra-green;
    }
    #volume {
      color: @tundra-teal;
    }
    #custom-media {
      color: @tundra-text;
    }
    #network.wifi {
      color: @tundra-green;
    }
    #network.ethernet {
      color: @tundra-blue;
    }
    #network.disconnected {
      color: @tundra-red;
    }
    #tray {
      padding: 0 4px;
    }
    #cpu.critical,
    #mem.critical {
      color: @tundra-red;
    }

    menu {
      background-color: alpha(@tundra-base, 0.96);
      border-color: @tundra-surface1;
      border-radius: 10px;
      font-size: 12px;
    }
    menuitem {
      color: @tundra-text;
    }
    menuitem:hover {
      background-color: @tundra-surface1;
      color: @tundra-text;
    }
  '';
}