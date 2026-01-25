{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.05";
  
  programs.home-manager.enable = true;

  # Cursor theme configuration (Bibata Modern Classic)
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    # Shell utilities
    eza bat fzf zoxide zsh-syntax-highlighting
    fastfetch nano yq ripgrep thefuck tree
    curl wget git htop
    
    # Terminal & multiplexer & TUIs
    tmux alacritty netop bluetuith mpd-small rmpc
    
    # Development tools
    gh lazygit
    python312 nodejs_22 go rustup 
    
    # Network tools
    wakeonlan wireguard-tools nmap tcpdump 
    mtr speedtest-cli librewolf i2pd
    
    # Media tools
    ffmpeg mediainfo
    
    # GUI Applications
    thunderbird
    vscodium
    signal-desktop
    bitwarden
    obsidian
    libreoffice
    vlc
    grayjay
    
    # Wayland utilities
    wl-clipboard
    grim
    slurp
    swappy
    dunst
    rofi-wayland
    hyprpaper
    bibata-cursors
    
    # Theming
    papirus-icon-theme
    everforest-gtk-theme
    
    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "tundra-node";
    userEmail = "eliaspublic@icloud.com";
  };

  # Alacritty - Everforest Dark Medium
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        bright = {
          black = "#5a524c";
          blue = "#7fbbb3";
          cyan = "#83c092";
          green = "#a7c080";
          magenta = "#d699b6";
          red = "#e67e80";
          white = "#d3c6aa";
          yellow = "#dbbc7f";
        };
        cursor = {
          cursor = "#d3c6aa";
          text = "#2d353b";
        };
        normal = {
          black = "#475258";
          blue = "#7fbbb3";
          cyan = "#83c092";
          green = "#a7c080";
          magenta = "#d699b6";
          red = "#e67e80";
          white = "#d3c6aa";
          yellow = "#dbbc7f";
        };
        primary = {
          background = "#2d353b";
          foreground = "#d3c6aa";
        };
      };
      cursor = {
        blink_interval = 750;
        style = {
          blinking = "On";
          shape = "Beam";
        };
      };
      env = {
        TERM = "xterm-256color";
      };
      font = {
        size = 14.0;
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
      };
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      selection = {
        save_to_clipboard = true;
      };
      window = {
        decorations = "full";
        dynamic_title = true;
        opacity = 0.95;
        padding = {
          x = 20;
          y = 20;
        };
      };
    };
  };

  # Starship - Everforest theme
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$username$hostname$directory$git_branch$git_status$nix_shell$character";
      character = {
        error_symbol = "[➜](bold #e67e80)";
        success_symbol = "[➜](bold #a7c080)";
      };
      directory = {
        style = "bold #7fbbb3";
        truncate_to_repo = true;
        truncation_length = 3;
      };
      git_branch = {
        style = "bold #d699b6";
        symbol = " ";
      };
      git_status = {
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        style = "bold #dbbc7f";
      };
      hostname = {
        format = "[$hostname]($style) ";
        ssh_only = false;
        style = "bold #83c092";
      };
      nix_shell = {
        format = "via [$symbol$state]($style) ";
        style = "bold #7fbbb3";
        symbol = " ";
      };
      username = {
        format = "[$user]($style)@";
        show_always = false;
        style_user = "bold #a7c080";
      };
    };
  };

  # Tmux - Everforest theme
  programs.tmux = {
    enable = true;
    extraConfig = ''
set  -g default-terminal "screen-256color"
set  -g base-index      0
setw -g pane-base-index 0
set -g status-keys vi
set -g mode-keys   vi
set  -g mouse             on
set  -g focus-events      off
setw -g aggressive-resize off
setw -g clock-mode-style  12
set  -s escape-time       0
set  -g history-limit     50000
# Better prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix
# Easy config reload
bind r source-file ~/.tmux.conf \; display "Reloaded!"
# Better splits
bind | split-window -h
bind - split-window -v
# Vim-like pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
# Everforest theme
set -g status-style "bg=#2d353b,fg=#d3c6aa"
set -g status-left-style "bg=#475258,fg=#a7c080"
set -g status-right-style "bg=#475258,fg=#a7c080"
set -g window-status-current-style "bg=#a7c080,fg=#2d353b,bold"
set -g window-status-style "bg=#475258,fg=#d3c6aa"
set -g pane-border-style "fg=#475258"
set -g pane-active-border-style "fg=#a7c080"
set -g message-style "bg=#475258,fg=#a7c080"
set -g message-command-style "bg=#475258,fg=#a7c080"
# Status bar content
set -g status-left "#[fg=#a7c080,bg=#475258,bold] #S #[fg=#475258,bg=#2d353b]"
set -g status-right "#[fg=#475258,bg=#2d353b]#[fg=#a7c080,bg=#475258] %H:%M #[fg=#83c092] %Y-%m-%d "
set -g status-left-length 20
set -g status-right-length 50
# Window status format
set -g window-status-format "#[fg=#2d353b,bg=#475258]#[fg=#d3c6aa,bg=#475258] #I #W #[fg=#475258,bg=#2d353b]"
set -g window-status-current-format "#[fg=#2d353b,bg=#a7c080]#[fg=#2d353b,bg=#a7c080,bold] #I #W #[fg=#a7c080,bg=#2d353b]"
    '';
  };

  # Lazygit - Everforest theme
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "#a7c080" "bold" ];
          inactiveBorderColor = [ "#475258" ];
          selectedLineBgColor = [ "#343f44" ];
          selectedRangeBgColor = [ "#475258" ];
          cherryPickedCommitBgColor = [ "#7fbbb3" ];
          cherryPickedCommitFgColor = [ "#2d353b" ];
          unstagedChangesColor = [ "#e67e80" ];
        };
      };
    };
  };

  # Bat - Everforest compatible theme
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
    config = {
      theme = "gruvbox-dark";
      pager = "less -FR";
    };
  };

  # FZF - Everforest colors
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      bg = "#2d353b";
      "bg+" = "#475258";
      fg = "#d3c6aa";
      "fg+" = "#d3c6aa";
      hl = "#a7c080";
      "hl+" = "#a7c080";
      info = "#dbbc7f";
      marker = "#e67e80";
      prompt = "#7fbbb3";
      spinner = "#83c092";
      pointer = "#d699b6";
      header = "#83c092";
    };
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      # System
      ls = "eza --icons";
      ll = "eza -la --icons";
      cat = "bat";
      cd = "z";
      
      # Git
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";

      # NixOS shortcuts
      nixos-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#laptop --impure";
      nixos-update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#laptop --impure";
    };
    
    initContent = lib.mkOrder 550 ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"
      eval "$(thefuck --alias)"

      # FZF keybindings
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # Update function for NixOS
      update-all() {
          echo "Updating Nix flake..."
          cd /etc/nixos
          sudo nix flake update

          echo "Rebuilding NixOS system..."
          sudo nixos-rebuild switch --flake /etc/nixos#laptop --impure
      }
    '';
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
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
      # Monitor configuration
      monitor = ",preferred,auto,1";

      # Autostart
      exec-once = [
        "waybar"
        "dunst"
        "hyprpaper"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 0;
      };

      # General settings - Everforest theme
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "rgba(a7c080ee) rgba(83c092ee) 45deg";
        "col.inactive_border" = "rgba(475258aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      # Decoration - Everforest transparency
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

      # Animations
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

      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
      };

      # Misc
      misc = {
        force_default_wallpaper = 0;
      };

      # Window rules - Everforest opacity with layerrule for transparency
      windowrulev2 = [
        "opacity 0.85 0.75,class:^(Alacritty)$"
        "opacity 0.88 0.78,class:^(VSCodium)$"
        "opacity 0.92 0.85,class:^(librewolf)$"
        "opacity 0.85 0.75,class:^(thunar)$"
        "opacity 0.88 0.78,class:^(obsidian)$"
      ];

      # Make waybar translucent
      layerrule = [
        "blur,waybar"
        "ignorezero,waybar"
      ];

      # Key bindings
      "$mod" = "SUPER";
      bind = [
        # Programs
        "$mod, T, exec, alacritty"
        "$mod, B, exec, librewolf"
        "$mod, I, exec, vscodium"
        "$mod, Return, exec, kdePackages.dolphin"
        "$mod, Space, exec, rofi -show drun"
        "$mod, Q, killactive,"
        "$mod SHIFT, E, exit,"
        "$mod, F, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # Focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Workspaces
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

        # Move to workspace
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

        # Special workspace
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Scroll workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # Waybar configuration - Everforest theme
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

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
        background-color: rgba(45, 53, 59, 0.75);
        color: #d3c6aa;
      }

      #workspaces button {
        padding: 0 10px;
        color: #d3c6aa;
        background-color: rgba(71, 82, 88, 0.6);
        margin: 3px;
        border-radius: 5px;
      }

      #workspaces button.active {
        background-color: rgba(167, 192, 128, 0.85);
        color: #2d353b;
      }

      #window,
      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
        margin: 3px;
        background-color: rgba(71, 82, 88, 0.6);
        color: #d3c6aa;
        border-radius: 5px;
      }

      #battery.charging {
        background-color: rgba(167, 192, 128, 0.9);
        color: #2d353b;
      }

      #battery.warning:not(.charging) {
        background-color: rgba(219, 188, 127, 0.9);
        color: #2d353b;
      }

      #battery.critical:not(.charging) {
        background-color: rgba(230, 126, 128, 0.9);
        color: #2d353b;
      }
    '';
  };

  # GTK theme and icon configuration for consistent theming
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
}