{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 0;
      gaps_out = 0;
      border_size = 2;
      col.active_border = "rgb(c0caf5)";   # Will be overridden by theme
      col.inactive_border = "rgb(181825)"; # Will be overridden by theme
      layout = "dwindle";
      allow_tearing = false;
      no_cursor_warps = false;
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
      drop_shadow = true;
      shadow_range = 10;
      shadow_render_power = 3;
      col.shadow = "rgb(181825)";
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
      xwayland = {
        force_zero_scaling = true;
      };
    };

    # Window rules
    windowrulev2 = [
      # Floating apps
      "float, class:^(pavucontrol|blueman-manager|nm-connection-editor|gnome-calculator|org.gnome.Characters)$"
      "float, title:^(Picture-in-Picture)$"
      "float, class:^(steam_app_0)$"

      # Opacity
      "opacity 0.85, class:^(foot)$"
      "opacity 0.88, class:^(VSCodium)$"
      "opacity 0.92, class:^(zen-beta)$"
      "opacity 0.85, class:^(thunar)$"
      "opacity 0.88, class:^(obsidian)$"

      # Workspace assignments
      "workspace 1, class:^(zen-beta|firefox|chromium)$"
      "workspace 2, class:^(code|VSCodium|vscodium)$"
      "workspace 3, class:^(foot|ghostty|alacritty|kitty)$"
      "workspace 4, class:^(discord|signal|telegram|beeper)$"
      "workspace 5, class:^(obsidian|thunar|libreoffice)$"
      "workspace 6, class:^(spotify|mpv|iina|vlc)$"
      "workspace 7, class:^(steam|heroic|bottles|lutris|prismlauncher)$"
      "workspace 8, class:^(keepassxc|bitwarden|veracrypt)$"
      "workspace 9, class:^(virt-manager|UTM|docker|qemu)$"

      # Size/position rules
      "size 800 600, class:^(pavucontrol|blueman-manager)$"
      "center, class:^(pavucontrol|blueman-manager)$"
    ];
  };
}