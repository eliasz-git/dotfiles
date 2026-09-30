{ config, lib, pkgs, ... }:

let
  palette = config.tundra.palette;
in
{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 0;
      gaps_out = 0;
      border_size = 2;
      "col.active_border" = "rgb(${lib.removePrefix "#" palette.blue})";
      "col.inactive_border" = "rgb(${lib.removePrefix "#" palette.surface0})";
      layout = "dwindle";
      allow_tearing = false;
      resize_on_border = true;
    };

    decoration = {
      rounding = 8;
      active_opacity = 1.0;
      inactive_opacity = 0.9;
      fullscreen_opacity = 1.0;
      blur = {
        enabled = true;
        size = 10;
        passes = 2;
        new_optimizations = true;
        xray = false;
      };
      shadow = {
        enabled = true;
        range = 10;
        render_power = 3;
        color = "rgba(${lib.removePrefix "#" palette.base}cc)";
      };
    };

    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, myBezier, popin 80%"
        "border, 1, 10, myBezier"
        "borderangle, 1, 8, myBezier"
        "fade, 1, 7, myBezier"
        "workspaces, 1, 6, myBezier"
      ];
    };

    misc = {
      vrr = 2; # FreeSync only while a window is fullscreen
      disable_hyprland_logo = true;
    };

    cursor.no_warps = false;
    xwayland.force_zero_scaling = true;

    # Window rules
    windowrule = [
      # Floating apps
      "float on, match:class ^(pavucontrol|blueman-manager|nm-connection-editor|gnome-calculator|org.gnome.Characters)$"
      "float on, match:title ^Picture-in-Picture$"
      "float on, match:class ^steam_app_0$"

      # Opacity
      "opacity 0.85, match:class ^foot$"
      "opacity 0.88, match:class ^VSCodium$"
      "opacity 0.92, match:class ^zen-beta$"
      "opacity 0.85, match:class ^thunar$"
      "opacity 0.88, match:class ^obsidian$"

      # Workspace assignments
      "workspace 1 silent, match:class ^(zen-beta|firefox|chromium)$"
      "workspace 2 silent, match:class ^(code|VSCodium|vscodium)$"
      "workspace 3 silent, match:class ^(foot|ghostty|alacritty|kitty)$"
      "workspace 4 silent, match:class ^(discord|signal|telegram|beeper)$"
      "workspace 5 silent, match:class ^(obsidian|thunar|libreoffice)$"
      "workspace 6 silent, match:class ^(spotify|mpv|iina|vlc)$"
      "workspace 7 silent, match:class ^(steam|heroic|bottles|lutris|prismlauncher)$"
      "workspace 8 silent, match:class ^(keepassxc|bitwarden|veracrypt)$"
      "workspace 9 silent, match:class ^(virt-manager|UTM|docker|qemu)$"

      # Size/position rules
      "size 800 600, match:class ^(pavucontrol|blueman-manager)$"
      "center on, match:class ^(pavucontrol|blueman-manager)$"
    ];
  };
}
