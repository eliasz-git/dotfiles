{ config, lib, pkgs, ... }:

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
    # The mangos hm module owns the session target, so the bar lives there.
    systemdTarget = "mango-session.target";
    settings = {
      layer = "top";
      position = "top";
      height = 32;
      buffer-scale = 1;
      "modules-left" = [ "workspaces" "window" ];
      "modules-center" = [ "clock" ];
      "modules-right" = [ "custom/media" "cpu" "memory" "network" "pulseaudio" "tray" ];

      # Same behaviour as the old hyprland/workspaces: hiding empty tags,
      # an OVERVIEW label for the overview toggled by SUPER+TAB, click to
      # activate a view and right-click to toggle it.
      workspaces = {
        "hide-empty" = true;
        "overview-label" = "OVERVIEW";
        "on-click" = "activate";
        "on-click-right" = "toggle";
      };

      window.format = "{}"; # titles truncate to 50 chars built-in

      clock.format = "{:%a %b %d  %I:%M %p}";

      cpu = {
        format = "󰻠 {load}%";
        interval = 5;
      };
      memory = {
        format = "󰍛 {}%";
        interval = 5;
      };
      network = {
        format = "{icon} {ifname}";
        "format-wifi" = "󰖩 {strength}%";
        "format-ethernet" = "󰈀 {ipaddr}";
        "format-disconnected" = "󰖪";
        "icon-wifi" = "󰖩";
        "icon-ethernet" = "󰈀";
        "icon-disconnected" = "󰖪";
        interval = 10;
      };
      pulseaudio = {
        format = "vol {volume}%";
        "format-muted" = "muted";
        on-click = "pavucontrol";
      };
      "custom/media" = {
        format = "{}";
        # Identical to the old waybar block: playerctl status decides the icon
        # and the title/artist is printed afterwards. A stopped player exits 0
        # with no output, which renders as an empty module.
        exec = ''
          status=$(playerctl status 2>/dev/null) || exit 0
          case "$status" in
            Playing) icon="󰐊" ;;
            Paused) icon="󰏔" ;;
            *) exit 0 ;;
          esac
          title=$(playerctl metadata title 2>/dev/null)
          artist=$(playerctl metadata artist 2>/dev/null)
          [ -n "$title" ] || title="Unknown title"
          if [ -n "$artist" ] && [ "$artist" != "$title" ]; then
            printf "%s  %s — %s" "$icon" "$title" "$artist"
          else
            printf "%s  %s" "$icon" "$title"
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
      font-size: 13px;
    }
    #bar {
      background-color: @tundra-mantle;
      padding: 0 8px;
    }
    #tags {
      padding: 0 4px;
      margin: 0 2px;
    }
    #tags.active {
      background-color: @tundra-blue;
      color: @tundra-base;
      border-radius: 6px;
    }
    #layout,
    #title,
    #clock,
    #cpu,
    #mem,
    #network,
    #volume,
    #custom-media,
    #tray {
      padding: 0 12px;
    }
    #cpu.critical,
    #mem.critical {
      color: @tundra-red;
    }
  '';
}