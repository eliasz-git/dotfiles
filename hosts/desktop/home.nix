{ config, pkgs, lib, zen-browser, ... }:

# Home Manager config for the desktop (user: elias).
# System-level stuff (Steam, Mango package, drivers, TLP/PPD, ssh, avahi,
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
    # Anki — official upstream binaries via nixpkgs `anki-bin`; the data
    # directory stays user-owned (see the module for the sync story).
    ../../modules/shared/anki.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/shared/operations.nix
    ../../modules/home/themes.nix
    ../../modules/nixos/mango/monitors.nix
    ../../modules/nixos/mango/input.nix
    ../../modules/nixos/mango/bindings.nix
    ../../modules/nixos/mango/looknfeel.nix
    ../../modules/nixos/mango/autostart.nix
    ../../modules/nixos/mango/toggles.nix
    ../../modules/nixos/mangobar.nix
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

  # ── WINDOW MANAGER: MANGO ──────────────────────────────────
  wayland.windowManager.mango = {
    enable = true;
    # Mango itself comes from programs.mango in configuration.nix; the mango
    # hm module adds a second copy to the user profile, which is what provides
    # `mmsg`. package is left at the module default for that reason.

    # Configuration is imported from the modular files (monitors/input/
    # bindings/looknfeel/autostart/toggles) plus the two runtime fragments
    # sourced here:
    #
    #   ~/.config/tundra/mango-vrr.conf   the Philips monitor rule, rewritten
    #                                     live by the VRR toggle
    #   ~/.config/tundra/colors/mango.conf the theme colours, written by the
    #                                     theme applier
    #
    # source_optional (not source): a missing fragment must never fail the
    # config, because the colours do not exist until the applier has run and
    # the fragment path must not be required at build time either.
    # bottomPrefixes pushes these lines after every other setting, so the theme
    # fragment's colours are parsed after (and override) the build-time values
    # in looknfeel.nix. The VRR rule does not collide because it names a
    # different monitor than the Acer rule in monitors.nix.
    settings.source_optional = [
      "~/.config/tundra/mango-vrr.conf"
      "~/.config/tundra/colors/mango.conf"
    ];
    bottomPrefixes = [ "source" ];
  };

  # Rotate the painting collection every 15 minutes and hide the background only
  # on a monitor that holds a fullscreen window, so media and games there have no
  # wallpaper behind them while the other displays keep theirs. The daemon runs
  # one swaybg per output and is the sole wallpaper owner for this host. It is
  # exec_once'd by modules/nixos/mango/autostart.nix.

  # Lock screen and idle manager. swayidle is the sole idle manager: it runs the
  # ASCII screensaver at 150s of idleness and the lock at 300s, and locks on
  # suspend. Both it and wlsunset are user services so the mango-toggle-idle and
  # mango-toggle-nightlight toggles can stop/start them without touching the
  # session.
  home.file = {
    ".local/bin/tundra-wallpaper-daemon".source = ../../scripts/wallpaper-daemon.sh;
    ".local/bin/tundra-wallpaper".source = ../../scripts/wallpaper.sh;
    ".local/bin/tundra-lock".source = ../../scripts/tundra-lock.sh;

    # The Philips monitor rule lives here, not in monitors.nix, so the VRR
    # toggle can rewrite its vrr field. home-manager rewrites this file on every
    # rebuild, so it always matches the declared layout.
    ".config/tundra/mango-vrr.conf".text = ''
      # Generated by home.nix. The VRR toggle flips vrr:1 <-> vrr:0 in this file.
      monitor_rule=name:^HDMI-A-1$,width:1920,height:1080,refresh:120,x:1536,y:0,scale:1,primary:1,vrr:1
    '';
  } // wallpaperLinks // asciiLinks;

  systemd.user.services.swayidle = {
    Unit = {
      Description = "Idle manager (swayidle): screensaver at 150s, lock at 300s";
      After = [ "mango-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 150 ${config.home.homeDirectory}/.local/bin/tundra-screensaver timeout 300 ${config.home.homeDirectory}/.local/bin/tundra-lock before-sleep ${config.home.homeDirectory}/.local/bin/tundra-lock";
    };
    Install.WantedBy = [ "mango-session.target" ];
  };

  systemd.user.services.wlsunset = {
    Unit = {
      Description = "Night light (wlsunset)";
      After = [ "mango-session.target" ];
    };
    Service = {
      # Coordinates approximate America/New_York (see configuration.nix) so the
      # sunset/sunrise transition tracks local time. Toggled by
      # mango-toggle-nightlight.
      ExecStart = "${pkgs.wlsunset}/bin/wlsunset -l 40.71 -L -74.01 -t 3500 -T 6500";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "mango-session.target" ];
  };

  # ── TERMINAL ───────────────────────────────────────────────
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "12x12";
        # The colour half is a runtime fragment. foot keeps a [colors-dark]
        # section below as the declared default, which is what a terminal shows
        # if it somehow starts before the applier has run.
        include = "~/.config/tundra/colors/foot.ini";
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
    # mangobar: workspaces + window title on the left, clock in the middle,
    # custom media, cpu, memory, network, volume, tray on the right.
    #
    # config.jsonc and style.css both come from modules/nixos/mangobar.nix
    # (imported above). style.css imports the runtime theme fragment as its
    # first statement, so every colour rule lives in the fragment, not here.

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
    swaylock # tundra-lock (lock screen) calls it by name
    pulsemixer pavucontrol
    # figlet draws the screensaver wordmark; gawk animates it. Both are invoked
    # by name from tundra-screensaver, so they have to be on the session PATH
    # that swayidle and the Mango keybindings run with.
    figlet gawk
    # tundra-wallpaper runs `file --mime-type` to pick the extension; without it
    # every file prompts as "may not be an image" and PNG/WebP are saved as .jpg.
    file
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
