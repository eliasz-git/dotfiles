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

  home.packages = with pkgs; [
    kitty
    powertop brightnessctl playerctl
    bluetuith netop
    wl-clipboard grim slurp swappy
    dunst rofi-wayland swaybg
    librewolf brave thunderbird vscodium signal-desktop
    bitwarden obsidian libreoffice vlc lollypop
    tutanota-desktop yubioath-flutter prismlauncher
    nextcloud-client
    jetbrains-toolbox
    davmail
    gnome-online-accounts
    bibata-cursors
    papirus-icon-theme
    everforest-gtk-theme
  ];

  programs.zsh.shellAliases = {
    rb = "sudo nixos-rebuild switch --flake /etc/nixos#laptop --impure";
    nixos-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#laptop --impure";
    nixos-update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#laptop --impure";
  };

  programs.zsh.initContent = lib.mkOrder 600 ''
    eval "$(zoxide init zsh)"
    eval "$(thefuck --alias)"
    export PATH="$HOME/.npm-global/bin:$PATH"

    update-all() {
        echo "Updating Nix flake..."
        cd /etc/nixos
        sudo nix flake update

        echo "Rebuilding NixOS system..."
        sudo nixos-rebuild switch --flake /etc/nixos#laptop --impure
    }
  '';

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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

  programs.niri = {
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us,us";
            variant = "colemak,";
            options = "grp:alt_shift_toggle";
          };
        };
        touchpad = {
          natural-scroll = false;
          click-method = "clickfinger";
        };
      };

      layout = {
        gaps = 10;
        center-focused-column = "never";
        focus-ring = {
          width = 3;
          active-color = "#a7c080ff";
          inactive-color = "#475258aa";
        };
        border.enable = false;
      };

      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
      };

      environment = {
        XCURSOR_SIZE = "24";
        XCURSOR_THEME = "Bibata-Modern-Classic";
      };

      prefer-no-csd = true;

      spawn-at-startup = [
        { command = [ "waybar" ]; }
        { command = [ "dunst" ]; }
        { command = [ "sh" "-c" "swaybg -i ~/.config/nix-config/wallpapers/wallpaper.jpg -m fill" ]; }
        { command = [ "signal-desktop" ]; }
      ];

      window-rules = [
        { matches = [ { app-id = "^kitty$"; } ]; opacity = 0.85; }
        { matches = [ { app-id = "^VSCodium$"; } ]; opacity = 0.88; }
        { matches = [ { app-id = "^librewolf$"; } ]; opacity = 0.92; }
        { matches = [ { app-id = "^thunar$"; } ]; opacity = 0.85; }
        { matches = [ { app-id = "^obsidian$"; } ]; opacity = 0.88; }
      ];

      # Keybindings use colemak logical key names so physical positions match
      # the original hyprland code: bindings (e.g. physical T = colemak G).
      binds = with config.lib.niri.actions; {
        # App launchers
        "Mod+G".action = spawn "kitty";           # physical T key
        "Mod+B".action = spawn "brave";
        "Mod+U".action = spawn "vscodium";         # physical I key
        "Mod+M".action = spawn "lollypop";
        "Mod+Return".action = spawn "thunar";
        "Mod+Space".action = spawn "rofi" [ "-show" "drun" ];

        # Window / session management
        "Mod+Q".action = close-window;
        "Mod+Shift+F".action = quit;               # physical E key, colemak F
        "Mod+T".action = toggle-window-floating;   # physical F key, colemak T
        "Mod+Shift+Return".action = fullscreen-window;

        # Focus movement (arrow keys + colemak home-row)
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Up".action = focus-window-up;
        "Mod+Down".action = focus-window-down;
        "Mod+H".action = focus-column-left;
        "Mod+I".action = focus-column-right;       # physical L key, colemak I
        "Mod+E".action = focus-window-up;          # physical K key, colemak E
        "Mod+N".action = focus-window-down;        # physical J key, colemak N

        # Move windows
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+I".action = move-column-right;
        "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
        "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;

        # Workspaces
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        "Mod+Shift+1".action = move-window-to-workspace 1;
        "Mod+Shift+2".action = move-window-to-workspace 2;
        "Mod+Shift+3".action = move-window-to-workspace 3;
        "Mod+Shift+4".action = move-window-to-workspace 4;
        "Mod+Shift+5".action = move-window-to-workspace 5;
        "Mod+Shift+6".action = move-window-to-workspace 6;
        "Mod+Shift+7".action = move-window-to-workspace 7;
        "Mod+Shift+8".action = move-window-to-workspace 8;
        "Mod+Shift+9".action = move-window-to-workspace 9;

        # Brightness
        "XF86MonBrightnessUp".action = spawn "brightnessctl" [ "set" "+5%" ];
        "XF86MonBrightnessDown".action = spawn "brightnessctl" [ "set" "5%-" ];

        # Volume
        "XF86AudioRaiseVolume".action = spawn "wpctl" [ "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
        "XF86AudioLowerVolume".action = spawn "wpctl" [ "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
        "XF86AudioMute".action = spawn "wpctl" [ "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        "XF86AudioMicMute".action = spawn "wpctl" [ "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];

        # Media
        "XF86AudioPlay".action = spawn "playerctl" [ "play-pause" ];
        "XF86AudioPause".action = spawn "playerctl" [ "play-pause" ];
        "XF86AudioNext".action = spawn "playerctl" [ "next" ];
        "XF86AudioPrev".action = spawn "playerctl" [ "previous" ];
        "XF86AudioStop".action = spawn "playerctl" [ "stop" ];
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        margin = "5px 10px 0px 10px";
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "mpris" "custom/printer" "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

        "niri/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        "niri/window" = {
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
      #mpris {
        padding: 0 12px;
        margin: 3px;
        background-color: rgba(131, 192, 146, 0.7);
        color: #2d353b;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(131, 192, 146, 0.4);
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