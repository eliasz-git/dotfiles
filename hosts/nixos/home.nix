{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/nixos/terminal.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # NixOS-specific packages
  home.packages = with pkgs; [
    kitty
    # Power management TUIs
    powertop brightnessctl playerctl
    
    # Network/Bluetooth TUIs
    bluetuith netop
    
    # Wayland utilities
    wl-clipboard grim slurp swappy
    dunst rofi-wayland hyprpaper
    
    # GUI Applications
    librewolf thunderbird vscodium signal-desktop
    bitwarden obsidian libreoffice vlc lollypop
    tutanota-desktop yubioath-flutter
    
    # Cloud sync and iCloud alternatives
    nextcloud-client         # Cloud file sync (iCloud alternative)
    davmail                  # Exchange/iCloud calendar and contacts bridge
    gnome-online-accounts    # Calendar and contacts sync
    
    # Theming
    bibata-cursors
    papirus-icon-theme
    everforest-gtk-theme
  ];

  # NixOS-specific shell aliases
  programs.zsh.shellAliases = {
    nixos-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#laptop --impure";
    nixos-update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#laptop --impure";
  };

  # NixOS-specific update function
  programs.zsh.initContent = lib.mkOrder 600 ''
    update-all() {
        echo "Updating Nix flake..."
        cd /etc/nixos
        sudo nix flake update

        echo "Rebuilding NixOS system..."
        sudo nixos-rebuild switch --flake /etc/nixos#laptop --impure
    }
  '';

  # Cursor theme configuration
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # GTK theme and icon configuration
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Everforest-Dark-BL";
      package = pkgs.everforest-gtk-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Rofi - Everforest theme
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg = mkLiteral "#2d353b";
        bg-alt = mkLiteral "#343f44";
        fg = mkLiteral "#d3c6aa";
        fg-alt = mkLiteral "#9da9a0";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        margin = 0;
        padding = 0;
        spacing = 0;
      };
      "window" = {
        location = mkLiteral "center";
        width = 640;
        background-color = mkLiteral "@bg";
        border-radius = 8;
      };
      "inputbar" = {
        spacing = 8;
        padding = 12;
        background-color = mkLiteral "@bg-alt";
        border-radius = mkLiteral "8px 8px 0 0";
      };
      "prompt, entry, element-icon, element-text" = {
        vertical-align = mkLiteral "0.5";
      };
      "prompt" = {
        text-color = mkLiteral "#a7c080";
      };
      "textbox" = {
        padding = 8;
        background-color = mkLiteral "@bg-alt";
      };
      "listview" = {
        padding = mkLiteral "4px 0";
        lines = 8;
        columns = 1;
        fixed-height = false;
      };
      "element" = {
        padding = 8;
        spacing = 8;
      };
      "element normal normal" = {
        text-color = mkLiteral "@fg";
      };
      "element normal urgent" = {
        text-color = mkLiteral "#e67e80";
      };
      "element normal active" = {
        text-color = mkLiteral "#7fbbb3";
      };
      "element selected normal" = {
        background-color = mkLiteral "#a7c080";
        text-color = mkLiteral "@bg";
        border-radius = 4;
      };
      "element selected urgent" = {
        background-color = mkLiteral "#e67e80";
        text-color = mkLiteral "@bg";
        border-radius = 4;
      };
      "element selected active" = {
        background-color = mkLiteral "#7fbbb3";
        text-color = mkLiteral "@bg";
        border-radius = 4;
      };
      "element-icon" = {
        size = mkLiteral "1em";
      };
      "element-text" = {
        text-color = mkLiteral "inherit";
      };
    };
  };

  # Hyprpaper for wallpaper
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/.config/nix-config/wallpapers/wallpaper.jpg"
      ];
      wallpaper = [
        ",~/.config/nix-config/wallpapers/wallpaper.jpg"
      ];
      splash = false;
      ipc = "on";
    };
  };

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      exec-once = [
        "waybar"
        "dunst"
        "hyprpaper"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      input = {
        kb_layout = "us,us";
        kb_variant = "colemak,";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "rgba(a7c080ee) rgba(83c092ee) 45deg";
        "col.inactive_border" = "rgba(475258aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      gestures = {
        workspace_swipe = true;
      };

      misc = {
        force_default_wallpaper = 0;
      };

      windowrulev2 = [
        "opacity 0.85 0.75,class:^(kitty)$"
        "opacity 0.88 0.78,class:^(VSCodium)$"
        "opacity 0.92 0.85,class:^(librewolf)$"
        "opacity 0.85 0.75,class:^(thunar)$"
        "opacity 0.88 0.78,class:^(obsidian)$"
        "opacity 0.85 0.75,class:^(nemo)$"
      ];

      layerrule = [
        "blur,waybar"
        "ignorezero,waybar"
      ];

      "$mod" = "SUPER";
      bind = [
        "$mod, T, exec, kitty"
        "$mod, B, exec, librewolf"
        "$mod, I, exec, VSCodium"
        "$mod, M, exec, lollypop"
        "$mod, Return, exec, nemo"
        "$mod, Space, exec, rofi -show drun"
        "$mod, Q, killactive,"
        "$mod SHIFT, E, exit,"
        "$mod, F, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioStop, exec, playerctl stop"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        margin = "5px 10px 0px 10px";
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "mpris" "custom/printer" "custom/cloud" "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        "hyprland/window" = {
          max-length = 50;
        };

        clock = {
          format = "{:%a %d %b %I:%M %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "󰻠 {usage}%";
        };

        memory = {
          format = "󰍛 {percentage}%";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        network = {
          format-wifi = "󰖨 {signalStrength}%";
          format-ethernet = "󰈀 Connected";
          format-disconnected = "󰖪 Disconnected";
        };

        "mpris" = {
          format = "{player_icon} {title} - {artist}";
          format-paused = "{status_icon} {title} - {artist}";
          player-icons = {
            default = "󰐊";
            mpv = "󰝚";
            spotify = "󰓇";
          };
          status-icons = {
            paused = "󰏤";
          };
          max-length = 40;
          on-click = "playerctl play-pause";
          on-click-right = "playerctl next";
          on-click-middle = "playerctl previous";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 Muted";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
        };

        "custom/printer" = {
          format = "󰐪 {}";
          interval = 30;
          exec = ''
            if command -v lpstat &>/dev/null; then
              jobs=$(lpstat -o 2>/dev/null | wc -l)
              if [ "$jobs" -gt 0 ]; then
                echo "$jobs"
              else
                echo ""
              fi
            else
              echo ""
            fi
          '';
          on-click = "system-config-printer";
          tooltip-format = "Click to manage printers";
        };

        "custom/cloud" = {
          format = "󰅟 {}";
          interval = 60;
          exec = ''
            if pgrep -x "nextcloud" >/dev/null || pgrep -f "nextcloud" >/dev/null; then
              echo "Synced"
            elif pgrep -x davmail >/dev/null; then
              echo "Connected"
            else
              echo "Offline"
            fi
          '';
          on-click = "nextcloud";
          tooltip-format = "Cloud sync status";
        };
      };
    };
    style = ''
      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 14px;
      }

      window#waybar {
        background-color: transparent;
        color: #d3c6aa;
      }

      #workspaces button {
        padding: 0 10px;
        color: #d3c6aa;
        background-color: rgba(71, 82, 88, 0.5);
        margin: 3px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
      }

      #workspaces button.active {
        background-color: rgba(167, 192, 128, 0.9);
        color: #2d353b;
        box-shadow: 0 3px 6px rgba(167, 192, 128, 0.4);
      }

      #window,
      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #mpris,
      #tray,
      #custom-printer,
      #custom-cloud {
        padding: 0 12px;
        margin: 3px;
        background-color: rgba(71, 82, 88, 0.5);
        color: #d3c6aa;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
      }

      #mpris {
        padding: 0 12px;
        margin: 3px;
        background-color: rgba(131, 192, 146, 0.7);
        color: #2d353b;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(131, 192, 146, 0.4);
      }

      #custom-printer {
        background-color: rgba(127, 187, 179, 0.6);
        color: #d3c6aa;
      }

      #custom-cloud {
        background-color: rgba(131, 192, 146, 0.6);
        color: #d3c6aa;
      }

      #battery.charging {
        background-color: rgba(167, 192, 128, 0.9);
        color: #2d353b;
        box-shadow: 0 2px 4px rgba(167, 192, 128, 0.4);
      }

      #battery.warning:not(.charging) {
        background-color: rgba(219, 188, 127, 0.9);
        color: #2d353b;
        box-shadow: 0 2px 4px rgba(219, 188, 127, 0.4);
      }

      #battery.critical:not(.charging) {
        background-color: rgba(230, 126, 128, 0.9);
        color: #2d353b;
        box-shadow: 0 2px 4px rgba(230, 126, 128, 0.4);
      }
    '';
  };
}
