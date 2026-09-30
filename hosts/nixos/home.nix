{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/shared/secrets.nix
    ../../modules/shared/slskd.nix
    ../../modules/shared/operations.nix
    ../../modules/home/themes.nix
    ../../modules/nixos/terminal.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  tundra.enable = true;
  tundra.theme = "everforest-blue";

  home.packages = with pkgs; [
    ghostty
    powertop brightnessctl playerctl
    bluetuith netop
    wl-clipboard grim slurp swappy
    dunst rofi swaybg
    librewolf thunderbird vscodium signal-desktop
    bitwarden-desktop obsidian libreoffice
    mpd rmpc mpdscribble mpc slskd
    steam calibre discord gramps rustdesk tailscale docker
    tutanota-desktop yubioath-flutter prismlauncher
    nextcloud-client
    jetbrains-toolbox
    davmail
    gnome-online-accounts
    bibata-cursors
    papirus-icon-theme
    everforest-gtk-theme
  ];

  programs.zsh.initContent = lib.mkOrder 600 ''
    eval "$(zoxide init zsh)"
    eval "$(pay-respects zsh --alias)"
    export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

    update-all() {
        rbu
    }
  '';

  home.pointerCursor = {
    enable = true;
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
    gtk4.theme = config.gtk.theme; # keep the pre-26.05 behaviour explicitly (silences HM warning)
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
      palette = config.tundra.palette;
    in {
      "*" = {
        background-color = mkLiteral palette.base;
        text-color = mkLiteral palette.text;
        margin = 0;
        padding = 0;
        spacing = 0;
      };
      "window" = {
        location = mkLiteral "center";
        width = 640;
        background-color = mkLiteral palette.base;
        border-radius = 8;
        border = mkLiteral "2px";
        border-color = mkLiteral palette.surface0;
      };
      "mainbox" = {
        background-color = mkLiteral palette.base;
      };
      "inputbar" = {
        spacing = 8;
        padding = 12;
        background-color = mkLiteral palette.mantle;
        border-radius = mkLiteral "8px 8px 0 0";
      };
      "prompt, entry, element-icon, element-text" = {
        vertical-align = mkLiteral "0.5";
      };
      "prompt" = {
        text-color = mkLiteral palette.blue;
      };
      "textbox" = {
        padding = 8;
        background-color = mkLiteral palette.mantle;
        text-color = mkLiteral palette.text;
      };
      "listview" = {
        padding = mkLiteral "4px 0";
        lines = 8;
        columns = 1;
        fixed-height = false;
      };
      "element" = {
        background-color = mkLiteral "transparent";
        padding = 8;
        spacing = 8;
      };
      "element normal normal" = {
        text-color = mkLiteral palette.text;
      };
      "element normal urgent" = {
        text-color = mkLiteral palette.red;
      };
      "element normal active" = {
        text-color = mkLiteral palette.green;
      };
      "element selected normal" = {
        background-color = mkLiteral palette.blue;
        text-color = mkLiteral palette.base;
        border-radius = 4;
      };
      "element selected urgent" = {
        background-color = mkLiteral palette.red;
        text-color = mkLiteral palette.base;
        border-radius = 4;
      };
      "element selected active" = {
        background-color = mkLiteral palette.green;
        text-color = mkLiteral palette.base;
        border-radius = 4;
      };
      "element-icon" = {
        size = mkLiteral "1em";
      };
      "element-text" = {
        text-color = mkLiteral palette.text;
      };
    };
  };

  programs.niri = {
    # Use nixpkgs' niri (same one programs.niri.enable installs system-wide), not
    # niri-flake's own build — that one pins libdisplay-info_0_2, which nixpkgs removed.
    package = pkgs.niri;
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            options = "caps:super"; # Caps Lock acts as Mod (Super)
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
          active.color = "${config.tundra.palette.blue}ff";
          inactive.color = "${config.tundra.palette.surface1}aa";
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
        { matches = [ { app-id = "^ghostty$"; } ]; opacity = 0.85; }
        { matches = [ { app-id = "^VSCodium$"; } ]; opacity = 0.88; }
        { matches = [ { app-id = "^librewolf$"; } ]; opacity = 0.92; }
        { matches = [ { app-id = "^thunar$"; } ]; opacity = 0.85; }
        { matches = [ { app-id = "^obsidian$"; } ]; opacity = 0.88; }
      ];

      binds = with config.lib.niri.actions; {
        "Mod+G".action = spawn "ghostty";
        "Mod+B".action = spawn "librewolf";
        "Mod+U".action = spawn "vscodium";
        "Mod+M".action = spawn "rmpc";            # music (rmpc)
        "Mod+Return".action = spawn "thunar";
        "Mod+Space".action = spawn "rofi" [ "-show" "drun" ];

        "Mod+Q".action = close-window;
        "Mod+Shift+F".action = quit;
        "Mod+T".action = toggle-window-floating;
        "Mod+Shift+Return".action = fullscreen-window;

        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Up".action = focus-window-up;
        "Mod+Down".action = focus-window-down;
        "Mod+H".action = focus-column-left;
        "Mod+I".action = focus-column-right;
        "Mod+E".action = focus-window-up;
        "Mod+N".action = focus-window-down;

        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+I".action = move-column-right;
        "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
        "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        "Mod+Shift+1".action.move-window-to-workspace = 1;
        "Mod+Shift+2".action.move-window-to-workspace = 2;
        "Mod+Shift+3".action.move-window-to-workspace = 3;
        "Mod+Shift+4".action.move-window-to-workspace = 4;
        "Mod+Shift+5".action.move-window-to-workspace = 5;
        "Mod+Shift+6".action.move-window-to-workspace = 6;
        "Mod+Shift+7".action.move-window-to-workspace = 7;
        "Mod+Shift+8".action.move-window-to-workspace = 8;
        "Mod+Shift+9".action.move-window-to-workspace = 9;

        "XF86MonBrightnessUp".action = spawn "brightnessctl" [ "set" "+5%" ];
        "XF86MonBrightnessDown".action = spawn "brightnessctl" [ "set" "5%-" ];

        "XF86AudioRaiseVolume".action = spawn "wpctl" [ "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
        "XF86AudioLowerVolume".action = spawn "wpctl" [ "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
        "XF86AudioMute".action = spawn "wpctl" [ "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        "XF86AudioMicMute".action = spawn "wpctl" [ "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];

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
        color: ${config.tundra.palette.text};
      }

      #workspaces button {
        padding: 0 10px;
        color: ${config.tundra.palette.text};
        background-color: ${config.tundra.palette.mantle}cc;
        margin: 3px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
      }

      #workspaces button.active {
        background-color: ${config.tundra.palette.blue}e6;
        color: ${config.tundra.palette.base};
        box-shadow: 0 3px 6px #00000066;
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
        background-color: ${config.tundra.palette.surface0}e6;
        color: ${config.tundra.palette.text};
        border-radius: 8px;
        box-shadow: 0 2px 4px #0000004d;
      }
      #battery.charging {
        background-color: ${config.tundra.palette.green}e6;
        color: ${config.tundra.palette.base};
        box-shadow: 0 2px 4px #0000004d;
      }

      #battery.warning:not(.charging) {
        background-color: ${config.tundra.palette.yellow}e6;
        color: ${config.tundra.palette.base};
        box-shadow: 0 2px 4px #0000004d;
      }

      #battery.critical:not(.charging) {
        background-color: ${config.tundra.palette.red}e6;
        color: ${config.tundra.palette.base};
        box-shadow: 0 2px 4px #0000004d;
      }
    '';
  };

  # Music — mirrors macOS mpd + rmpc + mpdscribble (Last.fm) setup
  home.file.".mpd/mpd.conf".text = ''
    music_directory     "~/Music"
    playlist_directory  "~/.mpd/playlists"
    db_file             "~/.mpd/database"
    log_file            "~/.mpd/log"
    pid_file            "~/.mpd/pid"
    state_file          "~/.mpd/state"
    sticker_file        "~/.mpd/sticker.sql"
    port                "6600"
    bind_to_address     "127.0.0.1"
    auto_update         "yes"
    follow_outside_symlinks "yes"
    follow_inside_symlinks "yes"
    log_level           "default"

    audio_output {
      type      "pipewire"
      name      "PipeWire"
      mixer_type "software"
    }
  '';

  # mpdscribble config is generated at service start (see systemd.user.services.mpdscribble
  # below) so the Last.fm password never lives in this repo.

  home.file.".config/rmpc/config.ron".text = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        address: "127.0.0.1:6600",
        password: None,
        cache_dir: None,
        on_song_change: None,
        volume_step: 5,
        max_fps: 30,
        scrolloff: 0,
        wrap_navigation: false,
        enable_mouse: true,
        scroll_amount: 1,
        enable_config_hot_reload: true,
        enable_lyrics_hot_reload: true,
        status_update_interval_ms: 1000,
        rewind_to_start_sec: None,
        keep_state_on_song_change: true,
        reflect_changes_to_playlist: false,
        select_current_song_on_change: true,
        ignore_leading_the: false,
        browser_song_sort: [Disc, Track, Artist, Title],
        directories_sort: SortFormat(group_by_type: true, reverse: false),
        auto_open_downloads: true,
        lyrics_dir: "~/Music/Lyrics",
        album_art: (
            method: Kitty,
            max_size_px: (width: 1200, height: 1200),
            disabled_protocols: ["http://", "https://"],
            vertical_align: Center,
            horizontal_align: Center,
        ),
        keybinds: (
            global: {
                "q":          Quit,
                "?":          ShowHelp,
                ":":          CommandMode,
                "oI":         ShowCurrentSongInfo,
                "oo":         ShowOutputs,
                "op":         ShowDecoders,
                "od":         ShowDownloads,
                "oP":         Partition(),
                "z":          ToggleRepeat,
                "x":          ToggleRandom,
                "c":          ToggleConsume,
                "v":          ToggleSingle,
                "p":          TogglePause,
                "s":          Stop,
                ">":          NextTrack,
                "<":          PreviousTrack,
                "f":          SeekForward,
                "b":          SeekBack,
                ".":          VolumeUp,
                ",":          VolumeDown,
                "<Tab>":      NextTab,
                "gt":         NextTab,
                "<S-Tab>":    PreviousTab,
                "gT":         PreviousTab,
                "1":          SwitchToTab("Queue"),
                "2":          SwitchToTab("Directories"),
                "3":          SwitchToTab("Artists"),
                "4":          SwitchToTab("Album Artists"),
                "5":          SwitchToTab("Albums"),
                "6":          SwitchToTab("Playlists"),
                "7":          SwitchToTab("Search"),
                "8":          SwitchToTab("Lyrics"),
                "<C-u>":      Update,
                "<C-U>":      Rescan,
                "R":          AddRandom,
            },
            navigation: {
                "<C-c>":      Close,
                "<Esc>":      Close,
                "<CR>":       Confirm,
                "k":          Up,
                "<Up>":       Up,
                "j":          Down,
                "<Down>":     Down,
                "h":          Left,
                "<Left>":     Left,
                "l":          Right,
                "<Right>":    Right,
                "<C-w>k":     PaneUp,
                "<C-Up>":     PaneUp,
                "<C-w>j":     PaneDown,
                "<C-Down>":   PaneDown,
                "<C-w>h":     PaneLeft,
                "<C-Left>":   PaneLeft,
                "<C-w>l":     PaneRight,
                "<C-Right>":  PaneRight,
                "K":          MoveUp,
                "J":          MoveDown,
                "<C-u>":      UpHalf,
                "<C-d>":      DownHalf,
                "<C-b>":      PageUp,
                "<PageUp>":   PageUp,
                "<C-f>":      PageDown,
                "<PageDown>": PageDown,
                "gg":         Top,
                "G":          Bottom,
                "<Space>":    Select,
                "<C-Space>":  InvertSelection,
                "/":          EnterSearch,
                "n":          NextResult,
                "N":          PreviousResult,
                "a":          Add,
                "A":          AddAll,
                "D":          Delete,
                "<C-r>":      Rename,
                "i":          FocusInput,
                "oi":         ShowInfo,
                "<C-z>":      ContextMenu(),
                "<C-s>s":     Save(kind: Modal(all: false, duplicates_strategy: Ask)),
                "<C-s>a":     Save(kind: Modal(all: true, duplicates_strategy: Ask)),
                "r":          Rate(),
            },
            queue: {
                "d":          Delete,
                "D":          DeleteAll,
                "<CR>":       Play,
                "C":          JumpToCurrent,
                "X":          Shuffle,
            },
        ),
        search: (
            case_sensitive: false,
            ignore_diacritics: false,
            search_button: false,
            mode: Contains,
            tags: [
                (value: "any",         label: "Any Tag"),
                (value: "artist",      label: "Artist"),
                (value: "album",        label: "Album"),
                (value: "albumartist", label: "Album Artist"),
                (value: "title",       label: "Title"),
                (value: "filename",    label: "Filename"),
                (value: "genre",       label: "Genre"),
            ],
        ),
        artists: (
            album_display_mode: SplitByDate,
            album_sort_by: Date,
            album_date_tags: [Date],
        ),
        tabs: [
            (
                name: "Lyrics",
                borders: "ALL",
                border_symbols: Rounded,
                pane: Split(
                    direction: Horizontal,
                    panes: [
                        (
                            size: "34%",
                            pane: Pane(AlbumArt),
                        ),
                        (
                            size: "66%",
                            pane: Split(
                                direction: Vertical,
                                panes: [
                                    (
                                        size: "3",
                                        borders: "ALL",
                                        border_symbols: Rounded,
                                        pane: Pane(QueueHeader()),
                                    ),
                                    (
                                        size: "76%",
                                        borders: "ALL",
                                        border_symbols: Rounded,
                                        pane: Pane(Lyrics),
                                    ),
                                    (
                                        size: "24%",
                                        borders: "ALL",
                                        border_symbols: Rounded,
                                        pane: Pane(Queue),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
            (
                name: "Queue",
                pane: Split(
                    direction: Horizontal,
                    panes: [
                        (
                            size: "35%",
                            pane: Split(
                                direction: Vertical,
                                panes: [
                                    (
                                        size: "100%",
                                        borders: "LEFT | RIGHT | TOP",
                                        border_symbols: Rounded,
                                        pane: Pane(AlbumArt)
                                    ),
                                    (
                                        size: "40%",
                                        borders: "ALL",
                                        border_symbols: Inherited(parent: Rounded, top_left: "├", top_right: "┤",),
                                        border_title: [(kind: Text(" Lyrics - Tab to focus, scroll j/k "))],
                                        border_title_alignment: Right,
                                        pane: Pane(Lyrics)
                                    ),
                                ],
                            ),
                        ),
                        (
                            size: "65%",
                            pane: Split(
                                direction: Vertical,
                                panes: [
                                    (
                                        size: "3",
                                        borders: "ALL",
                                        border_symbols: Inherited(parent: Rounded, bottom_left: "├", bottom_right: "┤",),
                                        pane: Split(
                                            direction: Horizontal,
                                            panes: [
                                                (
                                                    size: "1",
                                                    pane: Pane(Empty())
                                                ),
                                                (
                                                    size: "100%",
                                                    pane: Pane(QueueHeader())
                                                ),
                                            ]
                                        )
                                    ),
                                    (
                                        size: "100%",
                                        borders: "LEFT | RIGHT | BOTTOM",
                                        border_symbols: Rounded,
                                        pane: Split(
                                            direction: Horizontal,
                                            panes: [
                                                (
                                                    size: "1",
                                                    pane: Pane(Empty())
                                                ),
                                                (
                                                    size: "100%",
                                                    pane: Pane(Queue)
                                                ),
                                            ]
                                        )
                                    ),
                                ],
                            )
                        ),
                    ],
                ),
            ),
            (
                name: "Directories",
                borders: "ALL",
                border_symbols: Rounded,
                pane: Split(
                    size: "100%",
                    direction: Vertical,
                    panes: [(pane: Pane(Directories), size: "100%", borders: "ALL", border_symbols: Rounded)],
                )
            ),
            (
                name: "Artists",
                borders: "ALL",
                border_symbols: Rounded,
                pane: Split(
                    size: "100%",
                    direction: Vertical,
                    panes: [(pane: Pane(Artists), size: "100%", borders: "ALL", border_symbols: Rounded)],
                )
            ),
            (
                name: "Album Artists",
                borders: "ALL",
                border_symbols: Rounded,
                pane: Split(
                    size: "100%",
                    direction: Vertical,
                    panes: [(pane: Pane(AlbumArtists), size: "100%", borders: "ALL", border_symbols: Rounded)],
                )
            ),
            (
                name: "Albums",
                borders: "ALL",
                border_symbols: Rounded,
                pane: Split(
                    size: "100%",
                    direction: Vertical,
                    panes: [(pane: Pane(Albums), size: "100%", borders: "ALL", border_symbols: Rounded)],
                )
            ),
            (
                name: "Playlists",
                borders: "ALL",
                border_symbols: Rounded,
                pane: Split(
                    size: "100%",
                    direction: Vertical,
                    panes: [(pane: Pane(Playlists), size: "100%", borders: "ALL", border_symbols: Rounded)],
                )
            ),
            (
                name: "Search",
                borders: "ALL",
                border_symbols: Rounded,
                pane: Split(
                    size: "100%",
                    direction: Vertical,
                    panes: [(pane: Pane(Search), size: "100%", borders: "ALL", border_symbols: Rounded)],
                )
            ),
        ],
    )
  '';

  systemd.user.services.mpd = {
    Unit = { Description = "Music Player Daemon"; };
    Service = {
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon";
      Restart = "always";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  # Last.fm password lives OUTSIDE the repo as an agenix secret
  # (secrets/lastfm-password.age, decrypted to ~/.config/mpdscribble/lastfm-password).
  # ExecStartPre builds the real config into the runtime dir from it; if the file
  # is missing the service fails loudly instead of scrobbling as nobody.
  systemd.user.services.mpdscribble = {
    Unit = {
      Description = "mpdscribble Last.fm scrobbler";
      # The password path is a symlink into the agenix runtime dir, so the decrypt
      # agent has to run first or ExecStartPre reads a dangling link.
      After = [ "agenix.service" ];
      Requires = [ "agenix.service" ];
    };
    Service = {
      ExecStartPre = "${pkgs.writeShellScript "mpdscribble-gen-conf" ''
        set -eu
        export PATH=${lib.makeBinPath [ pkgs.coreutils ]}
        pw_file="$HOME/.config/mpdscribble/lastfm-password"
        if [ ! -r "$pw_file" ]; then
          echo "mpdscribble: missing $pw_file (put your Last.fm password in it, chmod 600)" >&2
          exit 1
        fi
        umask 077
        mkdir -p "$HOME/.cache/mpdscribble"
        cat > "$XDG_RUNTIME_DIR/mpdscribble.conf" <<EOF
        verbose = 1

        [last.fm]
        url = https://post.audioscrobbler.com/
        username = quasar327
        password = $(head -n1 "$pw_file")
        journal = $HOME/.cache/mpdscribble/lastfm.journal
        EOF
      ''}";
      ExecStart = "${pkgs.mpdscribble}/bin/mpdscribble --conf %t/mpdscribble.conf";
      Restart = "always";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  # This host runs the scrobbler, so it opts in to the Last.fm secret. The
  # decrypt agent writes ~/.config/mpdscribble/lastfm-password.
  age.secrets."lastfm-password".enable = true;

  # slskd lives in modules/shared/slskd.nix (secrets: ~/.config/slskd/slskd.env)

  # sconnect — fuzzy SSH host picker (same as macOS). Hosts: ~/.config/ssh/devices;
  # add a host with: sconnect --add "name user@host"
  home.file.".local/bin/sconnect".text = ''
    #!/usr/bin/env bash
    # sconnect — fuzzy SSH host picker. Hosts: ~/.config/ssh/devices
    # Format (one per line, # = comment):  name user@host[:port] [identity_file]
    # Add a host:  sconnect --add "name user@host"
    set -euo pipefail

    DEVICES="''${SSH_DEVICES:-$HOME/.config/ssh/devices}"

    if [ "''${1:-}" = "--add" ]; then
      shift
      printf '%s\n' "$*" >> "$DEVICES"
      echo "added: $*"
      exit 0
    fi

    [ -f "$DEVICES" ] || { echo "no devices file: $DEVICES" >&2; exit 1; }

    pick="$(grep -vE '^[[:space:]]*#' "$DEVICES" | grep -vE '^[[:space:]]*$' | fzf --prompt='ssh > ')"
    [ -n "$pick" ] || exit 0

    read -r _ userhost ident <<<"$pick"
    port=""
    if [[ "$userhost" == *:* ]]; then
      port="''${userhost##*:}"
      userhost="''${userhost%:*}"
    fi

    args=()
    [ -n "''${port:-}" ] && args+=(-p "$port")
    [ -n "''${ident:-}" ] && args+=(-i "$ident")
    exec ssh "''${args[@]}" "$userhost"
  '';

  home.file.".local/bin/sconnect".executable = true;

  # devices file is user-owned (writable) so `sconnect --add` / edits work;
  # seeded once, never overwritten on later rebuilds
  home.activation.sshDevices = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.config/ssh"
    if [ -L "$HOME/.config/ssh/devices" ] || [ ! -f "$HOME/.config/ssh/devices" ]; then
      rm -f "$HOME/.config/ssh/devices"
      cat > "$HOME/.config/ssh/devices" <<'DEVICES'
# sconnect devices — one host per line:  name user@host[:port] [identity_file]
# add more any time:  sconnect --add "name user@host"
# (examples below — edit addresses/users to match your network)
macbook  elias@macbook.local
icarus    elias@icarus.local
mini1     elias@mini1.local
mini2     elias@mini2.local
router    admin@192.168.1.1
DEVICES
    fi
  '';
}
