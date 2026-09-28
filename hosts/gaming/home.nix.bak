{ config, pkgs, lib, ... }:

# Home Manager config for the gaming PC (user: elias).
# System-level stuff (Steam, Hyprland package, drivers, TLP/PPD, ssh, avahi,
# bluetooth) lives in configuration.nix — Home Manager has no options for those.
let
  wallpaper = ../../wallpapers/wallpaper.jpg;
in {
  imports = [
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
  ];

  home.stateVersion = "25.11";

  # ── WINDOW MANAGER: HYPRLAND ────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland itself comes from programs.hyprland in configuration.nix;
    # null here avoids a second, possibly mismatched copy.
    package = null;
    portalPackage = null;

    # Settings below are hyprlang. HM's default flips to Lua at stateVersion 26.05,
    # so pin it — otherwise a future stateVersion bump would silently break this config.
    configType = "hyprlang";

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "foot";
      "$menu" = "wofi --show drun";

      # Any monitor, native resolution, highest refresh rate (120Hz on the FHD panel).
      monitor = [ ",highrr,auto,1" ];

      exec-once = [
        "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      input = {
        kb_layout = "us";
        kb_options = "caps:escape";
        follow_mouse = 1;
        accel_profile = "flat"; # no mouse acceleration for games
        sensitivity = 0;
      };

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        "col.active_border" = "rgb(c0caf5)";
        "col.inactive_border" = "rgb(181825)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        blur = {
          enabled = true;
          size = 10;
          passes = 2;
        };
      };

      misc = {
        vrr = 2; # FreeSync only while a window is fullscreen (avoids desktop flicker)
        disable_hyprland_logo = true;
      };

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Space, exec, $menu"
        "$mod, B, exec, firefox"
        "$mod, Q, killactive,"
        "$mod SHIFT, E, exit,"
        "$mod, F, fullscreen,"
        "$mod, T, togglefloating,"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ] ++ (builtins.concatLists (builtins.genList (i:
        let ws = toString (i + 1); in [
          "$mod, ${ws}, workspace, ${ws}"
          "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
        ]) 9));

      # mouse: drag = move, right-drag = resize
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };

  # ── TERMINAL ───────────────────────────────────────────────
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "12x12";
      };
      colors = {
        background = "181825";
        foreground = "c0caf5";
      };
    };
  };

  # ── LAUNCHER ───────────────────────────────────────────────
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 500;
      allow_images = true;
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
      }
      window {
        background-color: #181825;
        color: #c0caf5;
        border: 2px solid #7aa2f7;
        border-radius: 8px;
      }
      #input {
        background-color: #181825;
        color: #c0caf5;
        border: none;
        margin: 8px;
      }
      #entry:selected {
        background-color: #7aa2f7;
        color: #181825;
      }
    '';
  };

  # ── NOTIFICATIONS ──────────────────────────────────────────
  services.dunst.enable = true;

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
      name = "Orchis-Dark";
      package = pkgs.orchis-theme;
    };
    gtk4.theme = config.gtk.theme; # keep GTK4 apps themed too
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # ── SHELL ──────────────────────────────────────────────────
  programs.zsh.shellAliases = {
    rb  = "sudo nixos-rebuild switch --flake ~/.config/nix-config#gaming-pc";
    rbu = "cd ~/.config/nix-config && nix flake update && sudo nixos-rebuild switch --flake .#gaming-pc";
  };

  # ── PACKAGES ───────────────────────────────────────────────
  # Steam, gamemode, gamescope, and Proton-GE are enabled system-wide
  # (configuration.nix); they don't belong here.
  home.packages = with pkgs; [
    # Apps
    firefox discord
    # Desktop utilities
    swaybg wl-clipboard grim slurp playerctl
    pulsemixer pavucontrol
    nnn lf
    # Needed by modules/shared/shell.nix (aliases + init hook)
    eza pay-respects
  ];
}
