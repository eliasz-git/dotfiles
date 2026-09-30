{ config, pkgs, lib, zen-browser, ... }:

# Home Manager config for the desktop (user: elias).
# System-level stuff (Steam, Hyprland package, drivers, TLP/PPD, ssh, avahi,
# bluetooth) lives in configuration.nix — Home Manager has no options for those.
let
  palette = config.tundra.palette;
  selectedEverforest = config.tundra.theme == "everforest-blue";
  wallpaperDir = ../../wallpapers;

  # Every image in the collection is linked into the daemon's directory. The
  # list is read from the directory rather than repeated here, so adding a
  # painting is a matter of dropping the file in. The daemon picks anything
  # with a dash in its name, so wallpaper.jpg stays the default and is never
  # rotated in; every other file takes part in rotation. wallpaper.sh writes
  # wallpaper_backup_*.jpg when replacing the default, and those are skipped:
  # they are the old default, not part of the collection.
  #
  # listToAttrs rather than genAttrs: genAttrs routes names through the attr
  # parser, which treats the dots in ".local/share/..." as attribute
  # separators and loses the directory part.
  wallpaperLinks = lib.listToAttrs (
    map
      (name: {
        name = ".local/share/tundra/wallpapers/${name}";
        value.source = "${wallpaperDir}/${name}";
      })
      (
        lib.filter
          (name: lib.hasSuffix ".jpg" name && !lib.hasPrefix "wallpaper_backup_" name)
          (lib.attrNames (builtins.readDir wallpaperDir))
      )
  );

  # The ASCII screensaver is three scripts plus the FIGlet faces they draw with.
  # The faces are linked into the XDG data directory rather than left in the
  # checkout, so the installed system does not depend on this repository keeping
  # its current location. Only .flf is linked, so a README can sit alongside them.
  asciiFontDir = ../../themes/tundra/ascii/fonts;
  asciiLinks =
    {
      ".local/bin/tundra-ascii".source = ../../scripts/tundra-ascii.sh;
      ".local/bin/tundra-screensaver".source = ../../scripts/tundra-screensaver.sh;
      ".local/bin/tundra-screensaver-effect".source = ../../scripts/tundra-screensaver-effect.sh;
    }
    // lib.listToAttrs (
      map
        (name: {
          name = ".local/share/tundra/ascii/fonts/${name}";
          value.source = "${asciiFontDir}/${name}";
        })
        (
          lib.filter
            (name: lib.hasSuffix ".flf" name)
            (lib.attrNames (builtins.readDir asciiFontDir))
        )
    );
in {
  imports = [
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/shared/operations.nix
    ../../modules/home/themes.nix
    ../../modules/nixos/hyprland/monitors.nix
    ../../modules/nixos/hyprland/input.nix
    ../../modules/nixos/hyprland/bindings.nix
    ../../modules/nixos/hyprland/looknfeel.nix
    ../../modules/nixos/hyprland/autostart.nix
    ../../modules/nixos/hyprland/toggles.nix
    ../../modules/nixos/rofi.nix
    ../../modules/nixos/mail.nix
    ../../modules/nixos/clipboard.nix
    ../../modules/nixos/screenshot.nix
    ../../modules/nixos/ai-tools.nix
    ../../modules/nixos/launchers.nix
    # Runtime theme engine: the palette catalogue, the colour-fragment applier
    # and the units that keep it current. Imports modules/home/themes.nix itself.
    ../../modules/nixos/theme-runtime.nix
    ../../modules/nixos/gaming-enhanced.nix
  ];

  home.stateVersion = "26.05";

  # Enable theme system
  tundra.enable = true;
  tundra.theme = "everforest-blue";

  # ── WINDOW MANAGER: HYPRLAND ────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland itself comes from programs.hyprland in configuration.nix;
    # null here avoids a second, possibly mismatched copy.
    package = null;
    portalPackage = null;

    # Keep the working hyprlang configuration active for now. The Lua-compatible
    # modular source remains in the repository and the existing hyprland.lua file
    # is intentionally not removed, so migration can resume after a newer stable
    # Hyprland/Home Manager combination is verified.
    configType = "hyprlang";

    # Settings are now imported from modular files:
    # - monitors.nix
    # - input.nix
    # - bindings.nix
    # - looknfeel.nix
    # - autostart.nix
    # - toggles.nix
    #
    # Keep minimal overrides here if needed:
    settings = {
      # Monitor config from monitors.nix (override if needed)
      # monitor = [ ",highrr,auto,1" ];

      # Input config from input.nix

      # Keybindings from bindings.nix

      # Look & feel from looknfeel.nix

      # Autostart from autostart.nix
    };
  };

  # Rotate the painting collection every 15 minutes and hide swaybg whenever
  # Hyprland reports a fullscreen window, so media and games have no wallpaper
  # behind them. The daemon is the sole wallpaper owner for this host.

  # Hypridle is the sole idle manager. Lock only after inactivity or before
  # suspend; do not start Hyprlock itself as an exec-once command.
  home.file = {
    ".local/bin/tundra-wallpaper-daemon".source = ../../scripts/wallpaper-daemon.sh;
    ".local/bin/tundra-wallpaper".source = ../../scripts/wallpaper.sh;
  } // wallpaperLinks // asciiLinks // {
    ".config/hypr/hypridle.conf".text = ''
      general {
        lock_cmd = pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock
        before_sleep_cmd = loginctl lock-session
        inhibit_sleep = 3
      }

      # Screensaver first, lock later. The gap is deliberate: the ASCII
      # screensaver appears at 150s of idleness and any key dismisses it, so
      # stepping away briefly costs nothing while a longer absence still ends
      # at the lock. tundra-screensaver exits its own special workspace on
      # dismissal, so this listener only has to start it.
      listener {
        timeout = 150
        on-timeout = tundra-screensaver
      }

      listener {
        timeout = 300
        on-timeout = loginctl lock-session
      }
    '';

    ".config/hypr/hyprlock.conf".text = ''
      general {
        disable_loading_bar = true
        hide_cursor = true
        grace = 0
      }

      background {
        monitor =
        color = rgb(${lib.removePrefix "#" palette.base})
        blur_passes = 2
      }

      input-field {
        size = 320, 60
        outline_thickness = 2
        dots_size = 0.25
        dots_spacing = 0.25
        outer_color = rgb(${lib.removePrefix "#" palette.blue})
        inner_color = rgb(${lib.removePrefix "#" palette.mantle})
        font_color = rgb(${lib.removePrefix "#" palette.text})
        check_color = rgb(${lib.removePrefix "#" palette.green})
        fail_color = rgb(${lib.removePrefix "#" palette.red})
        capslock_color = rgb(${lib.removePrefix "#" palette.yellow})
        placeholder_text = <i>Type password to unlock</i>
        rounding = 12
        font_family = JetBrainsMono Nerd Font
        position = 0, -80
        halign = center
        valign = center
      }
    '';
  };

  wayland.windowManager.hyprland.settings.exec-once = [
    "env TUNDRA_WALLPAPER_DIR=${config.home.homeDirectory}/.local/share/tundra/wallpapers ${config.home.homeDirectory}/.local/bin/tundra-wallpaper-daemon"
  ];

  # ── TERMINAL ───────────────────────────────────────────────
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "12x12";
      };
      "colors-dark" = {
        background = lib.removePrefix "#" palette.base;
        foreground = lib.removePrefix "#" palette.text;
        regular0 = lib.removePrefix "#" palette.surface1;
        regular1 = lib.removePrefix "#" palette.red;
        regular2 = lib.removePrefix "#" palette.green;
        regular3 = lib.removePrefix "#" palette.yellow;
        regular4 = lib.removePrefix "#" palette.blue;
        regular5 = lib.removePrefix "#" palette.pink;
        regular6 = lib.removePrefix "#" palette.teal;
        regular7 = lib.removePrefix "#" palette.subtext1;
        bright0 = lib.removePrefix "#" palette.surface2;
        bright1 = lib.removePrefix "#" palette.red;
        bright2 = lib.removePrefix "#" palette.green;
        bright3 = lib.removePrefix "#" palette.yellow;
        bright4 = lib.removePrefix "#" palette.blue;
        bright5 = lib.removePrefix "#" palette.pink;
        bright6 = lib.removePrefix "#" palette.teal;
        bright7 = lib.removePrefix "#" palette.text;
      };
    };
  };

  # ── LAUNCHER: ROFI (replaces wofi) ─────────────────────────
  # Configured in rofi.nix

  # ── NOTIFICATIONS ──────────────────────────────────────────
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 360;
        origin = "top-right";
        offset = "12x12";
        font = "JetBrainsMono Nerd Font 10";
        frame_width = 2;
        frame_color = palette.surface0;
        separator_color = "frame";
        padding = 12;
        horizontal_padding = 12;
        background = palette.base;
        foreground = palette.text;
      };
      urgency_low = {
        background = palette.base;
        foreground = palette.subtext0;
        frame_color = palette.surface0;
        timeout = 3;
      };
      urgency_normal = {
        background = palette.base;
        foreground = palette.text;
        frame_color = palette.blue;
        timeout = 5;
      };
      urgency_critical = {
        background = palette.base;
        foreground = palette.text;
        frame_color = palette.red;
        timeout = 0;
      };
    };
  };

  # ── TOP BAR ────────────────────────────────────────────────
  # Waybar: workspaces + window title on the left, clock in the middle,
  # cpu, memory, network, volume, tray on the right.
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "top";
      height = 32;
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "custom/media" "cpu" "memory" "network" "pulseaudio" "tray" ];
      "hyprland/window".max-length = 60;
      clock.format = "{:%a %b %d  %I:%M %p}";
      cpu = {
        format = "󰻠 {usage}%";
        interval = 5;
      };
      memory = {
        format = "󰍛 {percentage}%";
        interval = 5;
      };
      network = {
        format-wifi = "󰖨 {signalStrength}%";
        format-ethernet = "󰈀 {ipaddr}";
        format-disconnected = "󰖪 Disconnected";
        interval = 10;
      };
      pulseaudio = {
        format = "vol {volume}%";
        format-muted = "muted";
        on-click = "pavucontrol";
      };
      "custom/media" = {
        format = "{}";
        exec = ''
          status=$(playerctl status 2>/dev/null) || exit 0
          case "$status" in
            Playing) icon="󰐊" ;;
            Paused) icon="󰏔" ;;
            *) exit 0 ;;
          esac
          title=$(playerctl metadata title 2>/dev/null)
          artist=$(playerctl metadata artist 2>/dev/null)
          [ -n "$title" ] || title="Unknown title"
          if [ -n "$artist" ] && [ "$artist" != "$title" ]; then
            printf "%s  %s — %s" "$icon" "$title" "$artist"
          else
            printf "%s  %s" "$icon" "$title"
          fi
        '';
        interval = 5;
        on-click = "playerctl play-pause";
        on-click-right = "playerctl next";
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
      }
      window#waybar {
        background-color: ${palette.mantle};
        color: ${palette.text};
      }
      #workspaces button {
        padding: 0 8px;
        color: ${palette.text};
        background: transparent;
      }
      #workspaces button.active {
        background-color: ${palette.blue};
        color: ${palette.base};
      }
      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #window {
        padding: 0 12px;
      }
      #cpu.warning {
        color: ${palette.yellow};
      }
      #cpu.critical {
        color: ${palette.red};
      }
      #memory.warning {
        color: ${palette.yellow};
      }
      #memory.critical {
        color: ${palette.red};
      }
    '';
  };

  # ── GAME OVERLAY ───────────────────────────────────────────
  programs.mangohud.enable = true;

  # ── CURSOR & GTK ───────────────────────────────────────────
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
    theme = {
      name = if selectedEverforest then "Everforest-Dark-BL" else "catppuccin-mocha-blue-standard";
      package = if selectedEverforest then pkgs.everforest-gtk-theme else pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "blue" ];
      };
    };
    gtk4.theme = config.gtk.theme; # keep GTK4 apps themed too
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=${if selectedEverforest then "MateriaEverforestDark" else "catppuccin-mocha-blue"}
  '';
  # The /Games mount is a systemd automount; a GTK bookmark keeps it visible in Thunar.
  xdg.configFile."gtk-3.0/bookmarks".text = "file:///Games Gaming SSD\n";

  # ── SHELL ──────────────────────────────────────────────────
  # Aliases defined in modules/shared/shell.nix

  # ── PACKAGES ───────────────────────────────────────────────
  # Steam, gamemode, gamescope, and Proton-GE are enabled system-wide
  # (configuration.nix); they don't belong here.
  # Zen Browser comes from the zen-browser flake input (it isn't in nixpkgs);
  # the binary is `zen-beta`, which is what Super+B launches.
  home.packages = with pkgs; [
    # Apps
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    discord
    bottles
    brightnessctl
    heroic
    keepassxc
    lazygit
    lutris
    neovim
    obsidian
    rmpc
    thunar
    imv
    mpv
    wlogout
    # Desktop utilities
    swaybg wl-clipboard grim slurp playerctl
    pulsemixer pavucontrol
    # figlet draws the screensaver wordmark; gawk animates it. Both are invoked
    # by name from tundra-screensaver, so they have to be on the session PATH
    # that Hypridle and the Hyprland keybindings run with.
    figlet gawk
    nnn lf
    # Clipboard
    cliphist
    (if selectedEverforest then materia-everforest-kvantum else catppuccin-kvantum.override {
      variant = "mocha";
      accent = "blue";
    })
    # Screenshot/recording
    swappy wf-recorder
    # Needed by modules/shared/shell.nix (aliases + init hook)
    eza pay-respects
    # AI tools (also in ai-tools.nix)
    # opencode, antigravity-cli and copilot-cli ship no .desktop file; they get
    # launcher entries from modules/nixos/launchers.nix.
  ];
}
