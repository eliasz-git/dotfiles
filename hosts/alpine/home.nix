{ config, pkgs, lib, ... }:

# ─────────────────────────────────────────────────────────────────
#  Gruvbox Dark palette
#  All colour references go through `gb` so a single change here
#  propagates across every app config below.
# ─────────────────────────────────────────────────────────────────
let
  gb = {
    # backgrounds
    bg0h = "#1d2021";   # hard dark  — bar background, popup bg
    bg   = "#282828";   # main bg
    bg1  = "#3c3836";   # raised surface
    bg2  = "#504945";   # higher surface
    bg3  = "#665c54";
    bg4  = "#7c6f64";
    # foregrounds
    fg   = "#ebdbb2";
    fg1  = "#ebdbb2";
    fg4  = "#a89984";   # muted / inactive
    # accent colours
    red  = "#cc241d";   bred  = "#fb4934";
    grn  = "#98971a";   bgrn  = "#b8bb26";
    yel  = "#d79921";   byel  = "#fabd2f";
    blu  = "#458588";   bblu  = "#83a598";
    pur  = "#b16286";   bpur  = "#d3869b";
    aqu  = "#689d6a";   baqu  = "#8ec07c";
    ora  = "#d65d0e";   bora  = "#fe8019";
  };

  # Remove leading # — needed by foot, fuzzel, mako colour fields
  h = c: lib.removePrefix "#" c;

  # Convenience: build a foot/fuzzel-style hex pair "RRGGBB RRGGBB"
  pair = a: b: "${h a} ${h b}";

in {
  # ── Shared modules (colour-agnostic utilities + packages) ───────
  imports = [
    ../../modules/shared/programs.nix   # eza bat fzf zoxide ripgrep etc.
    ../../modules/shared/fastfetch.nix  # system info on shell open
  ];

  # ── Identity ────────────────────────────────────────────────────
  home.username      = "elias";
  home.homeDirectory = "/home/elias";
  home.stateVersion  = "25.05";
  programs.home-manager.enable = true;

  # ── Packages (user environment — NOT system/apk) ────────────────
  # System layer (Sway, pipewire, drivers, PAM) is managed by APK.
  # Everything a user touches day-to-day lives here.
  home.packages = with pkgs; [
    # ---- TUI: daily tools
    nano
    #lf              # terminal file manager
    btop            # system monitor (gruvbox theme built-in)
    zathura         # pdf viewer, keyboard-driven
    imv             # image viewer, minimal
    ncmpcpp         # music player TUI (pairs with mpd from apk)
    newsboat        # RSS reader
    calcurse        # calendar / todo
    pulsemixer      # audio mixer TUI

    # ---- TUI: network management
    impala          # TUI wifi manager (nmcli backend)

    # ---- Security / passwords
    pass
    gnupg
    yubikey-manager

    # ---- Shell utilities (some duplicated from programs.nix for clarity)
    fd
    delta           # git diff with syntax highlighting
    jq
    tree
    entr            # run commands on file change (useful for dev)
    just            # command runner (better make)

    # ---- Dev
    python3
    nodejs
    go
    gcc
    gnumake

    # ---- GUI (minimal — terminal is primary)
    librewolf       # browser with sync
    keepassxc       # password vault GUI
    xfce.thunar

    # ---- Fonts  (apk has jetbrains-mono-nerd for Sway/Waybar boot;
    #              Nix provides it for apps launched after HM activates)
    nerd-fonts.jetbrains-mono
    noto-fonts-emoji

    # ---- Nix utilities
    nix-tree              # visualise the store
    nixpkgs-fmt           # format .nix files
    nix-output-monitor    # nicer nix build output (nom)
  ];

  # ── XDG directories ─────────────────────────────────────────────
  xdg.enable = true;
  xdg.userDirs = {
    enable            = true;
    createDirectories = true;
    desktop     = "${config.home.homeDirectory}/Desktop";
    documents   = "${config.home.homeDirectory}/Documents";
    download    = "${config.home.homeDirectory}/Downloads";
    music       = "${config.home.homeDirectory}/Music";
    pictures    = "${config.home.homeDirectory}/Pictures";
    videos      = "${config.home.homeDirectory}/Videos";
    extraConfig = {
      XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
    };
  };

  # ── Fonts ────────────────────────────────────────────────────────
  fonts.fontconfig.enable = true;

  # ── ~/.profile — loaded by login shells, sets up environment ─────
  # Sway reads this via the login shell before launching.
  home.file.".profile".text = ''
    # Seat backend — required for Sway/wlroots device access
    export LIBSEAT_BACKEND=seatd

    # XDG runtime dir — Alpine with OpenRC doesn't create this automatically
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    if [ ! -d "''${XDG_RUNTIME_DIR}" ]; then
      doas mkdir -p  "''${XDG_RUNTIME_DIR}"
      doas chown "$(id -un):$(id -gn)" "''${XDG_RUNTIME_DIR}"
      doas chmod 0700 "''${XDG_RUNTIME_DIR}"
    fi

    # GPG / YubiKey SSH agent
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null || true)
    gpgconf --launch gpg-agent 2>/dev/null || true

    # Nix profile
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    # NOTE: Sway is launched by Ly display manager (tty2), NOT auto-started
    # from the shell profile. Ly reads /usr/share/wayland-sessions/sway.desktop.
  '';

  # ── Zsh ──────────────────────────────────────────────────────────
  programs.zsh = {
    enable    = true;
    dotDir    = ".config/zsh";
    enableCompletion         = true;
    autosuggestion.enable    = true;
    syntaxHighlighting.enable = true;
    defaultKeymap            = "viins";

    history = {
      path       = "${config.home.homeDirectory}/.config/zsh/history";
      size       = 10000;
      save       = 10000;
      ignoreDups = true;
      share      = true;
    };

    shellAliases = {
      # ---- file listing (from programs.nix eza, overriding for consistency)
      ls  = "eza --icons --group-directories-first";
      ll  = "eza -la --icons --group-directories-first --git";
      lt  = "eza --tree --icons --level=2";
      # ---- replacements
      cat = "bat";
      vim = "nvim";
      vi  = "nvim";
      grep = "grep --color=auto";
      # ---- safe ops
      cp  = "cp -iv";
      mv  = "mv -iv";
      rm  = "rm -iv";
      # ---- git
      g   = "git";
      gs  = "git status";
      gd  = "git diff";
      ga  = "git add";
      gc  = "git commit";
      gp  = "git push";
      gl  = "git log --oneline --graph --decorate";
      # ---- dotfiles bare repo
      dotfiles = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
      # ---- scripts
      wifi = "bash ~/wifi-setup.sh";
      usb  = "bash ~/usb-mount.sh";
      net  = "impala";                   # TUI wifi manager
      # ---- Nix / home-manager
      hms  = "home-manager switch --flake ~/.config/nix-config#alpine";
      hmu  = "cd ~/.config/nix-config && nix flake update nixpkgs-unstable && home-manager switch --flake .#alpine";
      nsp  = "nix shell nixpkgs#";       # quick nix shell: nsp python3
      ndev = "nix develop";
    };

    initExtra = ''
      # Pull in environment (LIBSEAT, XDG_RUNTIME_DIR, GPG agent, Nix)
      [ -f ~/.profile ] && . ~/.profile

      # zoxide (smart cd) — from programs.nix
      eval "$(zoxide init zsh)"

      # FZF key bindings (Ctrl+R history, Ctrl+T file, Alt+C cd)
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh 2>/dev/null || true
      source ${pkgs.fzf}/share/fzf/completion.zsh   2>/dev/null || true

      # Auto-attach tmux on SSH sessions
      if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then
        tmux attach-session 2>/dev/null || tmux new-session
      fi
    '';
  };

  # ── FZF — Gruvbox Dark colours ───────────────────────────────────
  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--color=bg+:${gb.bg1},bg:${gb.bg},spinner:${gb.yel},hl:${gb.bred}"
      "--color=fg:${gb.fg},header:${gb.bred},info:${gb.byel},pointer:${gb.yel}"
      "--color=marker:${gb.yel},fg+:${gb.fg},prompt:${gb.byel},hl+:${gb.bred}"
      "--border=none"
      "--prompt='❯ '"
      "--pointer='▶'"
      "--marker='✓'"
    ];
  };

  # ── Zoxide ───────────────────────────────────────────────────────
  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ── Starship prompt — Gruvbox powerline ──────────────────────────
  programs.starship = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      palette = "gruvbox_dark";

      palettes.gruvbox_dark = {
        bg      = gb.bg;    bg1     = gb.bg1;
        fg      = gb.fg;    fg4     = gb.fg4;
        yellow  = gb.yel;   byellow = gb.byel;
        blue    = gb.blu;   bblue   = gb.bblu;
        red     = gb.red;   bred    = gb.bred;
        green   = gb.grn;   bgreen  = gb.bgrn;
        orange  = gb.ora;   borange = gb.bora;
        purple  = gb.pur;   bpurple = gb.bpur;
        aqua    = gb.aqu;   baqua   = gb.baqu;
      };

      # Powerline-style segments — vim-airline look
      format = lib.concatStrings [
        "[](yellow)"
        "$os"
        "$directory"
        "[](fg:yellow bg:bblue)"
        "$git_branch"
        "$git_status"
        "[](fg:bblue bg:bg1)"
        "$python$nodejs$rust$go"
        "$nix_shell"
        "[](fg:bg1)"
        "$character"
      ];

      add_newline = false;

      os        = { style = "bg:yellow fg:bg bold"; disabled = false; };
      directory = {
        style             = "bg:yellow fg:bg bold";
        read_only         = " 󰌾";
        truncation_length = 3;
        truncate_to_repo  = true;
      };
      git_branch = {
        symbol = " ";
        style  = "bg:bblue fg:bg";
        format = "[ $symbol$branch ]($style)";
      };
      git_status = {
        style  = "bg:bblue fg:bg";
        format = "[$all_status$ahead_behind]($style)";
      };
      python   = { style = "bg:bg1 fg:byellow"; format = "[ $symbol$version ]($style)"; };
      nodejs   = { style = "bg:bg1 fg:bgreen";  format = "[ $symbol$version ]($style)"; };
      rust     = { style = "bg:bg1 fg:borange"; format = "[ $symbol$version ]($style)"; };
      go       = { style = "bg:bg1 fg:bblue";   format = "[ $symbol$version ]($style)"; };
      nix_shell = {
        style  = "bg:bg1 fg:bblue";
        symbol = " ";
        format = "[ $symbol$name ]($style)";
      };
      character = {
        success_symbol = "[❯](bold yellow)";
        error_symbol   = "[❯](bold red)";
        vimcmd_symbol  = "[❮](bold yellow)";
      };
    };
  };

  # ── Tmux — Gruvbox, tmux-powerline aesthetic ─────────────────────
  programs.tmux = {
    enable       = true;
    prefix       = "C-Space";
    baseIndex    = 1;
    mouse        = true;
    terminal     = "tmux-256color";
    keyMode      = "vi";
    historyLimit = 10000;
    extraConfig  = ''
      set -g pane-base-index 1
      set -g renumber-windows on
      set -ag terminal-overrides ",xterm-256color:RGB"

      # ── Vi copy mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # ── Splits (intuitive symbols)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ── Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ── Resize
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ── Quick reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "⟳ tmux.conf"

      # ── Status bar — Gruvbox powerline (matches vim-airline look)
      set -g status-position top
      set -g status-style          "bg=${gb.bg},fg=${gb.fg}"

      set -g status-left           "#[bg=${gb.yel},fg=${gb.bg},bold] #S #[bg=${gb.bg1},fg=${gb.yel}]#[bg=${gb.bg1},fg=${gb.fg4}] #{?client_prefix,⌨ ,  }#[bg=${gb.bg},fg=${gb.bg1}] "
      set -g status-right          "#[bg=${gb.bg},fg=${gb.bg1}]#[bg=${gb.bg1},fg=${gb.fg4}] %d %b #[bg=${gb.bg1},fg=${gb.yel}]#[bg=${gb.yel},fg=${gb.bg},bold] %H:%M "
      set -g status-left-length    50
      set -g status-right-length   40

      set -g window-status-format         " #I:#W#{?window_flags,#{window_flags}, } "
      set -g window-status-current-format "#[bg=${gb.bg1},fg=${gb.byel},bold]  #I:#W#{?window_flags,#{window_flags}, } #[bg=${gb.bg},fg=${gb.bg1}]"

      set -g pane-border-style           "fg=${gb.bg1}"
      set -g pane-active-border-style    "fg=${gb.yel}"
      set -g message-style               "bg=${gb.bg1},fg=${gb.fg}"
      set -g message-command-style       "bg=${gb.bg1},fg=${gb.byel}"
      set -g mode-style                  "bg=${gb.yel},fg=${gb.bg}"
    '';
  };

  # ── Git ──────────────────────────────────────────────────────────
  programs.git = {
    enable    = true;
    userName  = "elias";
    userEmail = "your@email.com";   # update via: dotfiles add ~/.config/git/config
    delta = {
      enable  = true;
      options = {
        syntax-theme  = "gruvbox-dark";
        line-numbers  = true;
        navigate      = true;
        side-by-side  = false;
        # Terminal-style delta with Gruvbox
        minus-style                   = "syntax ${gb.bg}";
        minus-emph-style              = "syntax ${gb.bg1}";
        plus-style                    = "syntax ${gb.bg}";
        plus-emph-style               = "syntax ${gb.bg1}";
        line-numbers-minus-style      = gb.bred;
        line-numbers-plus-style       = gb.bgrn;
        line-numbers-zero-style       = gb.bg4;
      };
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "nvim";
      diff.colorMoved    = "default";
    };
  };

  # ── GPG agent (YubiKey SSH/GPG) ──────────────────────────────────
  services.gpg-agent = {
    enable           = true;
    enableSshSupport = true;
    pinentryPackage  = pkgs.pinentry-curses;
  };

  # ── GTK dark mode ────────────────────────────────────────────────
  gtk = {
    enable = true;
    font = {
      name    = "JetBrainsMono Nerd Font";
      size    = 11;
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    iconTheme  = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };

  # ═══════════════════════════════════════════════════════════════
  #  CONFIG FILES  (Sway stays in APK; we own the config)
  # ═══════════════════════════════════════════════════════════════

  # ── Sway ─────────────────────────────────────────────────────────
  home.file.".config/sway/config".text = ''
    # ── Gruvbox Dark
    set $bg0h   ${gb.bg0h}
    set $bg     ${gb.bg}
    set $bg1    ${gb.bg1}
    set $bg2    ${gb.bg2}
    set $bg4    ${gb.bg4}
    set $fg     ${gb.fg}
    set $fg4    ${gb.fg4}
    set $yel    ${gb.yel}
    set $byel   ${gb.byel}
    set $bblu   ${gb.bblu}
    set $bred   ${gb.bred}
    set $baqu   ${gb.baqu}

    set $mod  Mod4
    font pango:JetBrainsMono Nerd Font 10
    set $term     foot
    set $menu     fuzzel
    set $browser  librewolf
    set $files    thunar
    set $net      foot -e impala

    output * bg ${config.home.homeDirectory}/Pictures/wallpapers/gruvbox.png fill
    # fallback solid: output * bg $bg solid_color

    # ── Borders / gaps (terminal-window aesthetic)
    default_border pixel 1
    default_floating_border pixel 1
    gaps inner 6
    gaps outer 2
    hide_edge_borders smart

    # border    bg      text    indicator child_border
    client.focused          $yel  $bg1  $fg   $byel  $yel
    client.unfocused        $bg1  $bg   $fg4  $bg1   $bg1
    client.focused_inactive $bg2  $bg1  $fg4  $bg2   $bg2
    client.urgent           $bred $bg   $fg   $bred  $bred

    # ── Core binds
    bindsym $mod+Return       exec $term
    bindsym $mod+d            exec $menu
    bindsym $mod+b            exec $browser
    bindsym $mod+e            exec $files
    bindsym $mod+n            exec $net
    bindsym $mod+q            kill
    bindsym $mod+Shift+c      reload
    bindsym $mod+Shift+e      exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'

    # ── Focus (vim keys)
    bindsym $mod+h  focus left
    bindsym $mod+j  focus down
    bindsym $mod+k  focus up
    bindsym $mod+l  focus right

    # ── Move windows
    bindsym $mod+Shift+h  move left
    bindsym $mod+Shift+j  move down
    bindsym $mod+Shift+k  move up
    bindsym $mod+Shift+l  move right

    # ── Layout
    bindsym $mod+backslash    splith
    bindsym $mod+v            splitv
    bindsym $mod+f            fullscreen
    bindsym $mod+Shift+space  floating toggle
    bindsym $mod+s            layout stacking
    bindsym $mod+w            layout tabbed
    bindsym $mod+Shift+w      layout toggle split

    # ── Workspaces
    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9

    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9

    # ── Hardware keys
    bindsym XF86MonBrightnessUp   exec brightnessctl set +5%
    bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
    bindsym XF86AudioRaiseVolume  exec pulsemixer --change-volume +5
    bindsym XF86AudioLowerVolume  exec pulsemixer --change-volume -5
    bindsym XF86AudioMute         exec pulsemixer --toggle-mute

    # ── Lock / screenshot
    bindsym $mod+Escape exec swaylock -f -c ${h gb.bg0h}
    bindsym $mod+Print  exec grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

    # ── Lid close: lock then suspend (doas zzz — see /etc/doas.d/zzz.conf)
    bindswitch --reload lid:on  exec 'swaylock -f -c ${h gb.bg0h} && doas zzz'
    bindswitch --reload lid:off exec 'swaymsg "output * dpms on"'

    # ── Resize mode
    mode "resize" {
        bindsym h resize shrink width  10px
        bindsym j resize grow   height 10px
        bindsym k resize shrink height 10px
        bindsym l resize grow   width  10px
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"

    # ── Autostart
    exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP=sway
    exec_always waybar
    exec_always gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    exec mako
    exec pipewire
    exec wireplumber
    exec swayidle -w \
        timeout 300  'swaylock -f -c ${h gb.bg0h}' \
        timeout 330  'swaymsg "output * dpms off"' \
        resume       'swaymsg "output * dpms on"'  \
        before-sleep 'swaylock -f -c ${h gb.bg0h}'

    floating_modifier $mod normal

    # ── Touchpad
    input type:touchpad {
        dwt              enabled
        tap              enabled
        natural_scroll   enabled
        middle_emulation enabled
    }

    # ── Float small dialogs
    for_window [app_id="org.keepassxc.KeePassXC"]   floating enable
    for_window [title="^Picture.in.Picture$"]        floating enable, sticky enable
  '';

  # ── Waybar — tmux-statusline / vim-airline aesthetic ─────────────
  # Flat bar, no floating, no radius, powerline glyphs, monospace.
  home.file.".config/waybar/config".text = builtins.toJSON {
    layer    = "top";
    position = "top";
    height   = 24;
    spacing  = 0;
    exclusive = true;

    "modules-left"   = [ "sway/workspaces" "custom/sep" "sway/mode" ];
    "modules-center" = [ "sway/window" ];
    "modules-right"  = [ "network" "pulseaudio" "battery" "clock" "tray" ];

    "sway/workspaces" = {
      disable-scroll  = true;
      all-outputs     = true;
      format          = "{name}";
    };

    "sway/mode" = {
      format = "<span style='italic'>{}</span>";
    };

    "sway/window" = {
      max-length = 60;
      format     = "{}";
    };

    "custom/sep" = {
      format = "";     # powerline right-arrow glyph
      tooltip = false;
    };

    network = {
      format-wifi        = "󰖩 {essid} {signalStrength}%";
      format-ethernet    = "󰈀 {ipaddr}";
      format-disconnected = "󰖪 offline";
      tooltip-format     = "{ifname}: {ipaddr}\n{gwaddr}";
      on-click           = "foot -e impala";   # open TUI wifi manager
      interval           = 5;
    };

    pulseaudio = {
      format        = "{icon} {volume}%";
      format-muted  = "󰝟 mute";
      format-icons  = { default = [ "󰕿" "󰖀" "󰕾" ]; };
      on-click      = "foot -e pulsemixer";
      scroll-step   = 5;
    };

    battery = {
      states           = { warning = 30; critical = 15; };
      format           = "{icon} {capacity}%";
      format-charging  = "󰂄 {capacity}%";
      format-icons     = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      interval         = 30;
    };

    clock = {
      format         = " {:%a %d %b  %H:%M}";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
    };

    tray = { spacing = 6; icon-size = 14; };
  };

  home.file.".config/waybar/style.css".text = ''
    /* ── Reset ─────────────────────────────────────────────────── */
    * {
      border:        none;
      border-radius: 0;
      font-family:   "JetBrainsMono Nerd Font";
      font-size:     12px;
      min-height:    0;
      margin:        0;
      padding:       0;
    }

    /* ── Bar ─────────────────────────────────────────────────────
       Dark background, 1px bottom rule — like a terminal status line */
    window#waybar {
      background-color: ${gb.bg0h};
      color:            ${gb.fg};
      border-bottom:    1px solid ${gb.bg1};
    }

    /* ── Workspaces ─────────────────────────────────────────────── */
    #workspaces {
      background-color: ${gb.bg0h};
      padding: 0 4px;
    }

    #workspaces button {
      padding:          0 8px;
      background-color: transparent;
      color:            ${gb.fg4};
      border-radius:    0;
    }

    #workspaces button.focused,
    #workspaces button.active {
      background-color: ${gb.bg1};
      color:            ${gb.byel};
      /* Bottom accent line — like vim's cursorline underline */
      box-shadow:       inset 0 -2px ${gb.yel};
    }

    #workspaces button:hover {
      background-color: ${gb.bg1};
      color:            ${gb.fg};
    }

    #workspaces button.urgent {
      color:            ${gb.bred};
      box-shadow:       inset 0 -2px ${gb.bred};
    }

    /* ── Powerline separator  ────────────────────────────────── */
    #custom-sep {
      background-color: ${gb.bg0h};
      color:            ${gb.bg1};
      font-size:        18px;
      padding:          0;
    }

    /* ── Mode (resize, etc.) ─────────────────────────────────────── */
    #mode {
      background-color: ${gb.yel};
      color:            ${gb.bg};
      padding:          0 10px;
      font-weight:      bold;
    }

    /* ── Window title ────────────────────────────────────────────── */
    #window {
      background-color: transparent;
      color:            ${gb.fg4};
      font-style:       italic;
      padding:          0 10px;
    }

    /* ── Right-side modules — alternating backgrounds for readability
       like vim-airline segments  ────────────────────────────────── */
    #network {
      background-color: ${gb.bg1};
      color:            ${gb.bblu};
      padding:          0 12px;
    }

    #network.disconnected {
      color: ${gb.fg4};
    }

    #pulseaudio {
      background-color: ${gb.bg2};
      color:            ${gb.bpur};
      padding:          0 12px;
    }

    #pulseaudio.muted {
      color: ${gb.fg4};
    }

    #battery {
      background-color: ${gb.bg1};
      color:            ${gb.bgrn};
      padding:          0 12px;
    }

    #battery.warning:not(.charging) {
      color: ${gb.byel};
    }

    #battery.critical:not(.charging) {
      color:     ${gb.bred};
      animation: blink 0.8s steps(1) infinite;
    }

    #battery.charging {
      color: ${gb.baqu};
    }

    /* Clock: accent segment, like the last powerline block */
    #clock {
      background-color: ${gb.yel};
      color:            ${gb.bg};
      font-weight:      bold;
      padding:          0 14px;
    }

    #tray {
      background-color: ${gb.bg2};
      padding:          0 8px;
    }

    /* ── Blink animation for critical battery ────────────────────── */
    @keyframes blink {
      to { color: ${gb.bg}; background-color: ${gb.bred}; }
    }
  '';

  # ── Foot terminal — Gruvbox Dark ─────────────────────────────────
  home.file.".config/foot/foot.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=11
    dpi-aware=yes
    pad=8x8

    [colors]
    background=${h gb.bg}
    foreground=${h gb.fg}

    # dark/light (regular) — Gruvbox 16-colour palette
    regular0=${h gb.bg}         # black   (bg)
    regular1=${h gb.red}        # red
    regular2=${h gb.grn}        # green
    regular3=${h gb.yel}        # yellow
    regular4=${h gb.blu}        # blue
    regular5=${h gb.pur}        # purple
    regular6=${h gb.aqu}        # aqua
    regular7=${h gb.fg4}        # white   (fg4)

    # bright colours
    bright0=928374              # gray
    bright1=${h gb.bred}
    bright2=${h gb.bgrn}
    bright3=${h gb.byel}
    bright4=${h gb.bblu}
    bright5=${h gb.bpur}
    bright6=${h gb.baqu}
    bright7=${h gb.fg}

    # cursor — yellow block, terminal-classic
    cursor=${h gb.byel}
    cursor-text=${h gb.bg}

    # selection — like visual mode in vim
    selection-background=${h gb.bg1}
    selection-foreground=${h gb.fg}

    [cursor]
    style=block
    blink=yes

    [mouse]
    hide-when-typing=yes
  '';

  # ── Fuzzel launcher — terminal dropdown aesthetic ─────────────────
  # Looks like a terminal prompt / dmenu, not a GUI dialog
  home.file.".config/fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=12
    terminal=foot
    # Width in characters (terminal-native sizing)
    width=40
    lines=12
    tabs=4
    prompt=❯ 
    # Anchor top-center like a terminal quickopen
    anchor=top
    y-offset=0
    x-offset=0

    [colors]
    # Hard dark background for popup — distinct from desktop
    background=${h gb.bg0h}ff
    text=${h gb.fg}ff
    match=${h gb.byel}ff
    selection=${h gb.bg1}ff
    selection-text=${h gb.fg}ff
    selection-match=${h gb.byel}ff
    border=${h gb.yel}ff

    [border]
    width=1
    radius=0     # flat — no radius

    [dmenu]
    exit-immediately-if-one-item=false
  '';

  # ── Librewolf userChrome — hide tab bar ───────────────────────────
  # Run librewolf once first to create the profile, then hms will write this.
  home.file.".librewolf/userChrome-template.css".text = ''
    /*
     * Copy this to: ~/.librewolf/PROFILE_ID/chrome/userChrome.css
     *
     * Also set in about:config:
     *   toolkit.legacyUserProfileCustomizations.stylesheets = true
     */

    /* Hide tab strip — use keyboard or fuzzel to switch */
    #TabsToolbar { display: none !important; }
    #titlebar    { display: none !important; }

    /* ── Gruvbox Dark browser chrome ──────────────────────────── */
    :root {
      --toolbar-bgcolor:                  ${gb.bg} !important;
      --toolbar-color:                    ${gb.fg} !important;
      --toolbarbutton-hover-background:   ${gb.bg1} !important;
      --toolbarbutton-active-background:  ${gb.bg2} !important;
      --urlbar-box-bgcolor:               ${gb.bg1} !important;
      --urlbar-popup-bgcolor:             ${gb.bg} !important;
      --urlbar-popup-color:               ${gb.fg} !important;
    }

    #nav-bar {
      background-color: ${gb.bg} !important;
      border-bottom:    1px solid ${gb.bg1} !important;
    }

    #urlbar, #urlbar-background {
      background-color: ${gb.bg1} !important;
      color:            ${gb.fg}  !important;
      border-color:     ${gb.bg2} !important;
      border-radius:    0 !important;
    }

    #urlbar:focus-within #urlbar-background,
    #urlbar[focused="true"] #urlbar-background {
      border-color: ${gb.yel} !important;
    }

    .urlbarView {
      background-color: ${gb.bg} !important;
      border-color:     ${gb.bg1} !important;
    }

    .urlbarView-row:hover,
    .urlbarView-row[selected] {
      background-color: ${gb.bg1}  !important;
      color:            ${gb.byel} !important;
    }

    .toolbarbutton-1:hover {
      background-color: ${gb.bg1} !important;
    }
  '';

  # ── Stylus usercss — Gruvbox Dark for all websites ────────────────
  home.file."Downloads/gruvbox-dark-web.user.css".text = ''
    /* ==UserStyle==
    @name         Gruvbox Dark — Universal
    @namespace    gruvbox-dark-universal
    @version      1.0.0
    @description  Gruvbox Dark palette injected into every website via CSS variables.
    @author       elias
    @match        *://*/*
    @license      MIT
    ==/UserStyle== */

    @-moz-document regexp(".*") {
      :root {
        --gb-bg:      ${gb.bg};     --gb-bg1:     ${gb.bg1};
        --gb-bg2:     ${gb.bg2};    --gb-bg3:     ${gb.bg3};
        --gb-bg4:     ${gb.bg4};    --gb-fg:      ${gb.fg};
        --gb-fg4:     ${gb.fg4};    --gb-red:     ${gb.red};
        --gb-bred:    ${gb.bred};   --gb-green:   ${gb.grn};
        --gb-bgreen:  ${gb.bgrn};   --gb-yellow:  ${gb.yel};
        --gb-byellow: ${gb.byel};   --gb-blue:    ${gb.blu};
        --gb-bblue:   ${gb.bblu};   --gb-purple:  ${gb.pur};
        --gb-bpurple: ${gb.bpur};   --gb-aqua:    ${gb.aqu};
        --gb-baqua:   ${gb.baqu};   --gb-orange:  ${gb.ora};
        --gb-borange: ${gb.bora};

        /* ── Map to common design token namespaces ── */
        --background:             var(--gb-bg);
        --background-primary:     var(--gb-bg);
        --background-secondary:   var(--gb-bg1);
        --background-tertiary:    var(--gb-bg2);
        --background-floating:    var(--gb-bg1);
        --background-modifier-hover:    ${gb.bg1};
        --background-modifier-active:   ${gb.bg2};
        --background-modifier-selected: ${gb.bg2};
        --text-normal:    var(--gb-fg);    --text-primary:   var(--gb-fg);
        --text-secondary: var(--gb-fg4);   --text-muted:     var(--gb-fg4);
        --text-link:      var(--gb-bblue); --text-danger:    var(--gb-bred);
        --text-warning:   var(--gb-byellow); --text-success: var(--gb-bgreen);
        --text-brand:     var(--gb-byellow);
        --interactive-normal: var(--gb-fg4);
        --interactive-hover:  var(--gb-fg);
        --interactive-active: var(--gb-fg);
        --border-color:  var(--gb-bg2);    --divider-color: var(--gb-bg2);
        --input-background: var(--gb-bg1); --input-placeholder: var(--gb-bg4);
        --brand-500:     var(--gb-yellow); --accent-color:  var(--gb-yellow);
        --color-canvas-default:  var(--gb-bg);   --color-canvas-subtle: var(--gb-bg1);
        --color-fg-default:      var(--gb-fg);   --color-fg-muted:      var(--gb-fg4);
        --color-border-default:  var(--gb-bg2);  --color-accent-fg:     var(--gb-bblue);
        --color-success-fg:      var(--gb-bgreen); --color-danger-fg:   var(--gb-bred);
        --color-attention-fg:    var(--gb-byellow);
        --dt-black: ${gb.bg}; --dt-gray-0: ${gb.bg1}; --dt-gray-1: ${gb.bg2};
        --dt-gray-3: ${gb.bg3}; --dt-gray-4: ${gb.bg4}; --dt-gray-9: ${gb.fg};
        --dt-white: ${gb.fg}; --dt-yellow: ${gb.byel}; --dt-blue-6: ${gb.blu};
        --dt-blue-8: ${gb.bblu}; --dt-green-7: ${gb.bgrn}; --dt-red-7: ${gb.bred};

        box-shadow: none !important;
      }

      html, body { background-color: ${gb.bg} !important; color: ${gb.fg} !important; }

      ::-webkit-scrollbar              { width: 8px !important; }
      ::-webkit-scrollbar-track        { background: ${gb.bg}  !important; }
      ::-webkit-scrollbar-thumb        { background: ${gb.bg2} !important; }
      ::-webkit-scrollbar-thumb:hover  { background: ${gb.bg3} !important; }

      ::selection      { background: ${gb.yel} !important; color: ${gb.bg} !important; }
      ::-moz-selection { background: ${gb.yel} !important; color: ${gb.bg} !important; }

      a:link    { color: ${gb.bblu}  !important; }
      a:visited { color: ${gb.bpur}  !important; }
      a:hover   { color: ${gb.baqu}  !important; }
      a:active  { color: ${gb.bred}  !important; }

      input:not([type="range"]):not([type="checkbox"]):not([type="radio"]):not([type="color"]):not([type="file"]),
      textarea, select {
        background-color: ${gb.bg1} !important;
        color:            ${gb.fg}  !important;
        border-color:     ${gb.bg2} !important;
        caret-color:      ${gb.byel} !important;
      }
      input::placeholder, textarea::placeholder { color: ${gb.bg4} !important; }
      input:focus, textarea:focus, select:focus {
        outline:      2px solid ${gb.yel} !important;
        border-color: ${gb.yel} !important;
      }

      code, pre, kbd, samp {
        background-color: ${gb.bg1} !important;
        color:            ${gb.baqu} !important;
        border-color:     ${gb.bg2} !important;
        font-family:      "JetBrainsMono Nerd Font", monospace !important;
      }

      img:not([src*=".svg"]):not([class*="icon"]):not([class*="logo"]):not([class*="avatar"]) {
        filter: brightness(0.88) !important;
      }
    }
  '';

  # ── wifi-setup.sh — interactive TUI wifi helper ───────────────────
  home.file."wifi-setup.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # wifi-setup.sh — Interactive WiFi connection manager
      # Handles WPA2, WPA2-Enterprise PEAP, open networks
      # Usage: wifi   (alias)  or  bash ~/wifi-setup.sh

      need_root() {
        if command -v doas >/dev/null 2>&1; then doas "$@"; else sudo "$@"; fi
      }

      # Ensure deps
      for pkg in networkmanager iwd; do
        if ! rc-service "$pkg" status >/dev/null 2>&1; then
          echo "[warn] $pkg not running — starting..."
          need_root rc-service "$pkg" start || true
        fi
      done

      clear
      echo "╔══════════════════════════════════════╗"
      echo "║         WiFi Setup (nmcli)           ║"
      echo "╚══════════════════════════════════════╝"
      echo ""
      echo "Scanning..."
      nmcli device wifi rescan 2>/dev/null || true
      sleep 1
      nmcli -c yes device wifi list
      echo ""
      echo "  1) WPA2 password"
      echo "  2) WPA2-Enterprise PEAP (username + password)"
      echo "  3) Open network"
      echo "  4) Show saved connections"
      echo "  5) Delete a connection"
      echo "  6) Show IP / status"
      echo "  7) Exit"
      echo ""
      read -rp "❯ " choice

      case "$choice" in
        1)
          read -rp  "SSID: "     ssid
          read -rsp "Password: " pass; echo
          need_root nmcli connection add type wifi ssid "$ssid" \
            wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$pass"
          need_root nmcli connection up "$ssid" \
            && echo "✓ Connected to $ssid" \
            || echo "✗ Failed — check password"
          ;;
        2)
          read -rp  "SSID: "     ssid
          read -rp  "Username: " user
          read -rsp "Password: " pass; echo
          need_root nmcli connection add type wifi ssid "$ssid" \
            wifi-sec.key-mgmt wpa-eap \
            802-1x.eap peap \
            802-1x.phase2-auth mschapv2 \
            802-1x.identity "$user" \
            802-1x.password "$pass"
          need_root nmcli connection modify "$ssid" 802-1x.system-ca-certs no
          need_root nmcli connection up "$ssid" \
            && echo "✓ Connected" \
            || echo "✗ Failed"
          ;;
        3)
          read -rp "SSID: " ssid
          need_root nmcli connection add type wifi ssid "$ssid"
          need_root nmcli connection up "$ssid" \
            && echo "✓ Connected" || echo "✗ Failed"
          ;;
        4) nmcli connection show ;;
        5)
          read -rp "Connection name to delete: " name
          need_root nmcli connection delete "$name" && echo "✓ Deleted"
          ;;
        6)
          nmcli device status
          echo ""
          ip addr show | grep -E 'inet |link/ether'
          ;;
        7) exit 0 ;;
        *) echo "Invalid choice" ;;
      esac
    '';
  };

  # ── usb-mount.sh — TUI USB disk picker ───────────────────────────
  home.file."usb-mount.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # usb-mount.sh — Interactive USB mount/unmount
      # Usage: usb   (alias)  or  bash ~/usb-mount.sh

      need_root() {
        if command -v doas >/dev/null 2>&1; then doas "$@"; else sudo "$@"; fi
      }

      clear
      echo "╔══════════════════════════════════════╗"
      echo "║         USB Mount Manager            ║"
      echo "╚══════════════════════════════════════╝"
      echo ""
      echo "Detected removable disks:"
      echo ""

      idx=0
      declare -a DEVS LABELS

      while IFS= read -r dev; do
        size=$(lsblk -dn  -o SIZE   "$dev" 2>/dev/null || echo "?")
        label=$(blkid -s LABEL -o value "$dev" 2>/dev/null || echo "")
        fstype=$(blkid -s TYPE  -o value "$dev" 2>/dev/null || echo "unknown")
        mounted=$(lsblk -rn -o MOUNTPOINT "$dev" 2>/dev/null | grep -v '^$' | head -1)
        [ -z "$label" ]   && label="(no label)"
        [ -n "$mounted" ] && minfo=" → $mounted" || minfo=""
        idx=$((idx+1))
        DEVS[$idx]="$dev"
        LABELS[$idx]="$label"
        printf "  %d)  %-12s  %-10s  %-8s  %s%s\n" \
          "$idx" "$dev" "$label" "$size" "$fstype" "$minfo"
      done < <(lsblk -dpn -o NAME,TYPE | awk '$2=="disk" && $1!~/nvme/{print $1}')

      [ $idx -eq 0 ] && echo "  (none found)" && exit 0

      echo ""
      echo "  m) Mount   u) Unmount   q) Quit"
      echo ""
      read -rp "❯ " action

      case "$action" in
        m)
          read -rp "Disk number: " num
          dev="''${DEVS[$num]}"
          [ -z "$dev" ] && echo "Invalid." && exit 1
          # Prefer partition 2 (SCRIPTS USB layout), fall back to 1
          if lsblk "''${dev}2" >/dev/null 2>&1; then part="''${dev}2"
          else part="''${dev}1"; fi
          label="''${LABELS[$num]}"
          [ "$label" = "(no label)" ] && mnt="usb" \
            || mnt=$(echo "$label" | tr '[:upper:] ' '[:lower:]-')
          need_root mkdir -p "/media/$mnt"
          need_root mount "$part" "/media/$mnt" \
            && echo "✓ $part → /media/$mnt" \
            || echo "✗ Mount failed — try: doas mount -t exfat $part /media/$mnt"
          ;;
        u)
          read -rp "Disk number: " num
          dev="''${DEVS[$num]}"
          [ -z "$dev" ] && echo "Invalid." && exit 1
          mpt=$(lsblk -rn -o MOUNTPOINT "$dev" 2>/dev/null | grep -v '^$' | head -1)
          [ -z "$mpt" ] && echo "Not mounted." && exit 0
          need_root umount "$mpt" && echo "✓ Unmounted $mpt" || echo "✗ Failed"
          ;;
        q) exit 0 ;;
        *) echo "Invalid." ;;
      esac
    '';
  };

}
