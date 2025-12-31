{ pkgs, ... }:

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
    mtr speedtest-cli librewolf 
		#i2pd
    
    # Media tools
    ffmpeg mediainfo
    
    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "{username}";
    userEmail = "{email}";
  };

	# Alacritty
	programs.alacritty = {
		enable = true;
		settings = {
			colors = {
				bright = {
					black = "#1e3a5f";
					blue = "#82c4ff";
					cyan = "#6ee7ff";
					green = "#81ffb8";
					magenta = "#ce93d8";
					red = "#ff8fab";
					white = "#f5f7ff";
					yellow = "#ffe66d";
				};
				cursor = {
					cursor = "#64b5f6";
					text = "#0a1628";
				};
				normal = {
					black = "#0d1b2a";
					blue = "#64b5f6";
					cyan = "#4dd0e1";
					green = "#69f0ae";
					magenta = "#ba68c8";
					red = "#ff6b9d";
					white = "#e0e7ff";
					yellow = "#ffd93d";
				};
				primary = {
					background = "#0a1628";
					foreground = "#e0e7ff";
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
				opacity = 0.45;
				option_as_alt = "Both";
				padding = {
					x = 20;
					y = 20;
				};
			};
		};
	};

	# Starship
	programs.starship = {
		enable = true;
		settings = {
			add_newline = true;
			format = "$username$hostname$directory$git_branch$git_status$nix_shell$character";
			character = {
				error_symbol = "[➜](bold #ff6b9d)";
				success_symbol = "[➜](bold #64b5f6)";
			};
			directory = {
				style = "bold #4dd0e1";
				truncate_to_repo = true;
				truncation_length = 3;
			};
			git_branch = {
				style = "bold #ba68c8";
				symbol = " ";
			};
			git_status = {
				ahead = "⇡$${count}";
				behind = "⇣$${count}";
				diverged = "⇕⇡$${ahead_count}⇣$${behind_count}";
				style = "bold #ffd93d";
			};
			hostname = {
				format = "[$hostname]($style) ";
				ssh_only = false;
				style = "bold #4dd0e1";
			};
			nix_shell = {
				format = "via [$symbol$state]($style) ";
				style = "bold #64b5f6";
				symbol = " ";
			};
			username = {
				format = "[$user]($style)@";
				show_always = false;
				style_user = "bold #64b5f6";
			};
		};
	};

	# Tmux
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
# Night Fury theme
set -g status-style "bg=#0a1628,fg=#e0e7ff"
set -g status-left-style "bg=#1e3a5f,fg=#64b5f6"
set -g status-right-style "bg=#1e3a5f,fg=#64b5f6"
set -g window-status-current-style "bg=#64b5f6,fg=#0a1628,bold"
set -g window-status-style "bg=#1e3a5f,fg=#e0e7ff"
set -g pane-border-style "fg=#1e3a5f"
set -g pane-active-border-style "fg=#64b5f6"
set -g message-style "bg=#1e3a5f,fg=#64b5f6"
set -g message-command-style "bg=#1e3a5f,fg=#64b5f6"
# Status bar content
set -g status-left "#[fg=#64b5f6,bg=#1e3a5f,bold] #S #[fg=#1e3a5f,bg=#0a1628]"
set -g status-right "#[fg=#1e3a5f,bg=#0a1628]#[fg=#64b5f6,bg=#1e3a5f] %H:%M #[fg=#4dd0e1] %Y-%m-%d "
set -g status-left-length 20
set -g status-right-length 50
# Window status format
set -g window-status-format "#[fg=#0a1628,bg=#1e3a5f]#[fg=#e0e7ff,bg=#1e3a5f] #I #W #[fg=#1e3a5f,bg=#0a1628]"
set -g window-status-current-format "#[fg=#0a1628,bg=#64b5f6]#[fg=#0a1628,bg=#64b5f6,bold] #I #W #[fg=#64b5f6,bg=#0a1628]"
	'';
	};

  # Lazygit
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "#64b5f6" "bold" ];
          inactiveBorderColor = [ "#1e3a5f" ];
          selectedLineBgColor = [ "#1e3a5f" ];
          selectedRangeBgColor = [ "#1e3a5f" ];
          cherryPickedCommitBgColor = [ "#4dd0e1" ];
          cherryPickedCommitFgColor = [ "#0a1628" ];
          unstagedChangesColor = [ "#ff6b9d" ];
        };
      };
    };
  };

  # Bat
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
    config = {
      theme = "Nord";
      pager = "less -FR";
    };
  };

  # FZF
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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

			#i2pd = "open /Applications/LibreWolf-I2P.app && i2pd";
			end-i2pd = "ps aux | grep i2pd &&  ps aux | grep i2p && killall i2pd && killall i2p";

			# macOS nix-darwin shortcuts
			darwin-rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook";
		};
		
		initContent = ''
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