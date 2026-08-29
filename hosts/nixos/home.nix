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
    ghostty
    powertop brightnessctl playerctl
    bluetuith netop
    wl-clipboard grim slurp swappy
    dunst rofi-wayland swaybg
    librewolf brave thunderbird vscodium signal-desktop
    bitwarden obsidian libreoffice vlc
    mpd rmpc mpdscribble mpc
    steam calibre discord gramps rustdesk tailscale docker
    tutanota-desktop yubioath-flutter prismlauncher
    nextcloud-client
    jetbrains-toolbox
    davmail
    gnome-online-accounts
    bibata-cursors
    papirus-icon-theme
    orchis-theme
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
      name = "Orchis-Dark";
      package = pkgs.orchis-theme;
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
        bg = mkLiteral "#04182F";
        bg-alt = mkLiteral "#06467E";
        fg = mkLiteral "#68A2C6";
        fg-alt = mkLiteral "#7E8A94";
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
        text-color = mkLiteral "#116FAE";
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
        text-color = mkLiteral "#305561";
      };
      "element normal active" = {
        text-color = mkLiteral "#68A2C6";
      };
      "element selected normal" = {
        background-color = mkLiteral "#116FAE";
        text-color = mkLiteral "@bg";
        border-radius = 4;
      };
      "element selected urgent" = {
        background-color = mkLiteral "#305561";
        text-color = mkLiteral "@bg";
        border-radius = 4;
      };
      "element selected active" = {
        background-color = mkLiteral "#68A2C6";
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
            layout = "us";
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
          active-color = "#116FAEff";
          inactive-color = "#06467Eaa";
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
        "Mod+B".action = spawn "brave";
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

        "Mod+Shift+1".action = move-window-to-workspace 1;
        "Mod+Shift+2".action = move-window-to-workspace 2;
        "Mod+Shift+3".action = move-window-to-workspace 3;
        "Mod+Shift+4".action = move-window-to-workspace 4;
        "Mod+Shift+5".action = move-window-to-workspace 5;
        "Mod+Shift+6".action = move-window-to-workspace 6;
        "Mod+Shift+7".action = move-window-to-workspace 7;
        "Mod+Shift+8".action = move-window-to-workspace 8;
        "Mod+Shift+9".action = move-window-to-workspace 9;

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
        color: #68A2C6;
      }

      #workspaces button {
        padding: 0 10px;
        color: #68A2C6;
        background-color: rgba(4, 24, 47, 0.6);
        margin: 3px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
      }

      #workspaces button.active {
        background-color: rgba(17, 111, 174, 0.9);
        color: #04182F;
        box-shadow: 0 3px 6px rgba(17, 111, 174, 0.4);
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
        background-color: rgba(17, 111, 174, 0.7);
        color: #04182F;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(17, 111, 174, 0.4);
      }
      #battery.charging {
        background-color: rgba(17, 111, 174, 0.9);
        color: #04182F;
        box-shadow: 0 2px 4px rgba(17, 111, 174, 0.4);
      }

      #battery.warning:not(.charging) {
        background-color: rgba(48, 85, 97, 0.9);
        color: #04182F;
        box-shadow: 0 2px 4px rgba(219, 188, 127, 0.4);
      }

      #battery.critical:not(.charging) {
        background-color: rgba(230, 126, 128, 0.9);
        color: #04182F;
        box-shadow: 0 2px 4px rgba(230, 126, 128, 0.4);
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

  home.file.".config/mpdscribble/mpdscribble.conf".text = ''
    verbose = 1

    [last.fm]
    url = https://post.audioscrobbler.com/
    username = quasar327
    password = Ag!2hCFrUfGwpeHvVve_
    journal = ~/.cache/mpdscribble/lastfm.journal
  '';

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
        select_current_song_on_change: false,
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

  home.file.".config/rmpc/theme.ron".text = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        default_album_art_path: None,
        format_tag_separator: " | ",
        browser_column_widths: [20, 38, 42],
        background_color: None,
        text_color: None,
        header_background_color: None,
        modal_background_color: None,
        modal_backdrop: false,
        preview_label_style: (fg: "yellow"),
        preview_metadata_group_style: (fg: "yellow", modifiers: "Bold"),
        highlighted_item_style: (fg: "blue", modifiers: "Bold"),
        current_item_style: (fg: "black", bg: "blue", modifiers: "Bold"),
        borders_style: (fg: "blue"),
        highlight_border_style: (fg: "blue"),
        symbols: (
            song: "S",
            dir: "D",
            playlist: "P",
            marker: "M",
            ellipsis: "...",
            song_style: None,
            dir_style: None,
            playlist_style: None,
        ),
        level_styles: (
            info: (fg: "blue", bg: "black"),
            warn: (fg: "yellow", bg: "black"),
            error: (fg: "red", bg: "black"),
            debug: (fg: "light_green", bg: "black"),
            trace: (fg: "magenta", bg: "black"),
        ),
        progress_bar: (
            symbols: ["█", "█", "█", " ", "█"],
            track_style: None,
            elapsed_style: (fg: "blue"),
            thumb_style: (fg: "blue"),
            use_track_when_empty: true,
        ),
        scrollbar: (
            symbols: ["│", "█", "▲", "▼"],
            track_style: (),
            ends_style: (),
            thumb_style: (fg: "blue"),
        ),
        tab_bar: (
            active_style: (fg: "black", bg: "blue", modifiers: "Bold"),
            inactive_style: (),
        ),
        lyrics: (
            timestamp: false
        ),
        browser_song_format: [
            (
                kind: Group([
                    (kind: Property(Track)),
                    (kind: Text(" ")),
                ])
            ),
            (
                kind: Group([
                    (kind: Property(Artist)),
                    (kind: Text(" - ")),
                    (kind: Property(Title)),
                ]),
                default: (kind: Property(Filename))
            ),
        ],
        song_table_format: [
            (
                prop: (kind: Property(Artist),
                    default: (kind: Text("Unknown"))
                ),
                label_prop: (kind: Text("Artist")),
                width: "20%",
            ),
            (
                prop: (kind: Property(Title),
                    default: (kind: Text("Unknown"))
                ),
                label_prop: (kind: Text("Title")),
                width: "35%",
            ),
            (
                prop: (kind: Property(Album), style: (fg: "white"),
                    default: (kind: Text("Unknown Album"), style: (fg: "white"))
                ),
                label_prop: (kind: Text("Album")),
                width: "30%",
            ),
            (
                prop: (kind: Property(Duration),
                    default: (kind: Text("-"))
                ),
                label_prop: (kind: Text("Duration")),
                width: "15%",
                alignment: Right,
            ),
        ],
        layout: Split(
            direction: Vertical,
            panes: [
                (
                    size: "4",
                    pane: Split(
                        direction: Horizontal,
                        panes: [
                            (
                                size: "35",
                                borders: "LEFT | TOP | BOTTOM",
                                border_symbols: Inherited(parent: Rounded, bottom_left: "├"),
                                pane: Component("header_left")
                            ),
                            (
                                size: "100%",
                                borders: "ALL",
                                border_symbols: Inherited(parent: Rounded, top_left: "┬", top_right: "┬", bottom_left: "┴", bottom_right: "┴"),
                                pane: Component("header_center")
                            ),
                            (
                                size: "35",
                                borders: "RIGHT | TOP | BOTTOM",
                                border_symbols: Inherited(parent: Rounded, bottom_right: "┤"),
                                pane: Component("header_right")
                            ),
                        ]
                    )
                ),
                (
                    pane: Pane(Tabs),
                    borders: "RIGHT | LEFT | BOTTOM",
                    border_symbols: Rounded,
                    size: "2",
                ),
                (
                    pane: Pane(TabContent),
                    size: "100%",
                ),
                (
                    size: "3",
                    pane: Split(
                        direction: Horizontal,
                        panes: [
                            (
                                size: "12",
                                borders: "ALL",
                                border_symbols: Inherited(parent: Rounded, top_right: "┬", bottom_right: "┴"),
                                pane: Component("input_mode")
                            ),
                            (
                                size: "100%",
                                borders: "TOP | BOTTOM | RIGHT",
                                border_symbols: Rounded,
                                border_title: [(kind: Text(" ")), (kind: Property(Status(QueueLength()))), (kind: Text(" songs / ")), (kind: Property(Status(QueueTimeTotal()))), (kind: Text(" total time "))],
                                border_title_alignment: Right,
                                pane: Component("progress_bar"),
                            ),
                        ]
                    ),
                ),
            ],
        ),
        components: {
            "state": Pane(Property(
                content: [
                    (kind: Text("["), style: (fg: "yellow", modifiers: "Bold")),
                    (kind: Property(Status(StateV2( ))), style: (fg: "yellow", modifiers: "Bold")),
                    (kind: Text("]"), style: (fg: "yellow", modifiers: "Bold")),
                ], align: Left,
            )),
            "title": Pane(Property(
                content: [
                    (kind: Property(Song(Title)), style: (modifiers: "Bold"),
                        default: (kind: Text("No Song"), style: (modifiers: "Bold"))),
                ], align: Center, scroll_speed: 1
            )),
            "volume": Split(
                direction: Horizontal,
                panes: [
                    (size: "1", pane: Pane(Property(content: [(kind: Text(""))]))),
                    (size: "100%", pane: Pane(Volume(kind: Slider(symbols: (filled: "─", thumb: "●", track: "─"))))),
                    (size: "3", pane: Pane(Property(content: [(kind: Property(Status(Volume)), style: (fg: "blue"))], align: Right))),
                    (size: "2", pane: Pane(Property(content: [(kind: Text("%"), style: (fg: "blue"))]))),
                ]
            ),
            "elapsed_and_bitrate": Pane(Property(
                content: [
                    (kind: Property(Status(Elapsed))),
                    (kind: Text(" / ")),
                    (kind: Property(Status(Duration))),
                    (kind: Group([
                        (kind: Text(" (")),
                        (kind: Property(Status(Bitrate))),
                        (kind: Text(" kbps)")),
                    ])),
                ],
                align: Left,
            )),
            "artist_and_album": Pane(Property(
                content: [
                    (kind: Property(Song(Artist)), style: (fg: "yellow", modifiers: "Bold"),
                        default: (kind: Text("Unknown"), style: (fg: "yellow", modifiers: "Bold"))),
                    (kind: Text(" - ")),
                    (kind: Property(Song(Album)), default: (kind: Text("Unknown Album"))),
                ], align: Center, scroll_speed: 1
            )),
            "states": Split(
                direction: Horizontal,
                panes: [
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                    (
                        size: "100%",
                        pane: Pane(Property(content: [(kind: Property(Status(InputBuffer())), style: (fg: "blue"), align: Left)]))
                    ),
                    (
                        size: "6",
                        pane: Pane(Property(content: [
                            (kind: Text("["), style: (fg: "blue", modifiers: "Bold")),
                            (kind: Property(Status(RepeatV2(
                                on_label: "z",
                                off_label: "z",
                                on_style: (fg: "yellow", modifiers: "Bold"),
                                off_style: (fg: "blue", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(RandomV2(
                                on_label: "x",
                                off_label: "x",
                                on_style: (fg: "green", modifiers: "Bold"),
                                off_style: (fg: "blue", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(ConsumeV2(
                                on_label: "c",
                                off_label: "c",
                                oneshot_label: "c",
                                on_style: (fg: "yellow", modifiers: "Bold"),
                                off_style: (fg: "blue", modifiers: "Dim"),
                                oneshot_style: (fg: "red", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(SingleV2(
                                on_label: "v",
                                off_label: "v",
                                oneshot_label: "v",
                                on_style: (fg: "yellow", modifiers: "Bold"),
                                off_style: (fg: "blue", modifiers: "Dim"),
                                oneshot_style: (fg: "red", modifiers: "Bold"),
                            )))),
                            (kind: Text("]"), style: (fg: "blue", modifiers: "Bold")),
                        ], align: Right
                        ))
                    ),
                    (
                        size: "9",
                        pane: Pane(Property(content: [
                            (kind: Property(Status(RandomV2(
                                on_label: " SHUFFLE",
                                off_label: "",
                                on_style: (fg: "green", modifiers: "Bold"),
                            )))),
                        ], align: Left))
                    ),
                ]
            ),
            "input_mode": Pane(Property(
                content: [
                    (kind: Transform(Replace(content: (kind: Property(Status(InputMode()))), replacements: [
                        (match: "Normal", replace: (kind: Text(" NORMAL "), style: (fg: "black", bg: "blue"))),
                        (match: "Insert", replace: (kind: Text(" INSERT "), style: (fg: "black", bg: "green"))),
                    ])))
                ], align: Center
            )),
            "header_left": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("state")),
                    (size: "1", pane: Component("elapsed_and_bitrate")),
                ]
            ),
            "header_center": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("title")),
                    (size: "1", pane: Component("artist_and_album")),
                ]
            ),
            "header_right": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("volume")),
                    (size: "1", pane: Component("states")),
                ]
            ),
            "progress_bar": Split(
                direction: Horizontal,
                panes: [
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                    (
                        size: "100%",
                        pane: Pane(ProgressBar)
                    ),
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                ]
            )
        },
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

  systemd.user.services.mpdscribble = {
    Unit = { Description = "mpdscribble Last.fm scrobbler"; };
    Service = {
      ExecStart = "${pkgs.mpdscribble}/bin/mpdscribble";
      Restart = "always";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
}