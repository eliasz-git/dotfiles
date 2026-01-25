{ pkgs, lib, ... }:

{
  home.stateVersion = "25.05";
  
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Shell utilities
    eza bat fzf zoxide zsh-syntax-highlighting
    fastfetch nano yq ripgrep thefuck tree
    curl wget git htop
    
    # Terminal & multiplexer
    tmux alacritty
    
    # Development tools
    gh lazygit
    python312 nodejs_22 go rustup
    
    # Network tools
    wakeonlan wireguard-tools nmap tcpdump 
    mtr speedtest-cli 
    
    # Media tools
    ffmpeg mediainfo
    
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
        blur = false;
        decorations = "buttonless";
        dynamic_title = true;
        opacity = 0.95;
        option_as_alt = "Both";
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

  # Bat
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

      # macOS nix-darwin shortcuts
      darwin-rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook";
    };
    
    initContent = lib.mkOrder 550 ''
      # Ensure Home Manager CLI is in PATH
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # Initialize zoxide
      eval "$(zoxide init zsh)"
      eval "$(thefuck --alias)"

      # FZF keybindings (Ctrl+T uses FZF_DEFAULT_COMMAND)
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # Custom functions

      # Update all the things
      update-all() {
          echo "Updating Nix flake..."
          nix flake update --flake ~/.config/nix-config

          if [[ "$(uname)" == "Darwin" ]]; then
              if command -v brew &> /dev/null; then
                  echo "Updating Homebrew..."
                  brew update && brew upgrade
              else
                  echo "Homebrew not found, skipping..."
              fi
              echo "Rebuilding macOS system..."
              sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook
          else
              echo "Rebuilding NixOS system..."
              sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)
          fi
      }
    '';
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}