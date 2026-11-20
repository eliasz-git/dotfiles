{ config, lib, pkgs, ... }:

# Canonical palette registry lives in modules/home/themes.nix
# (tundra.palette — base/mantle/surface0/... — consumed by every app config:
# niri, waybar, sketchybar, ghostty, hyprland, mango, tmux, lazygit, fastfetch).
#
# This module keeps only the system-level tundra.enable/tundra.theme options
# and a read-only theme switcher. The 20-theme registry that used to live here
# was never consumed by any app and has been removed; themes are selected
# declaratively via tundra.theme in each host's configuration.

let
  defaultTheme = "everforest-blue";
in {
  options.tundra = {
    enable = lib.mkEnableOption "Tundra theme system";
    theme = lib.mkOption {
      type = lib.types.str;
      default = defaultTheme;
      description = "Current theme name. Palette tokens are defined in modules/home/themes.nix.";
    };
  };

  config = lib.mkIf config.tundra.enable {
    environment.systemPackages = [
      (pkgs.writeScriptBin "tundra-theme" ''
        #!/usr/bin/env bash
        set -euo pipefail
        CONFIG_DIR="''${XDG_CONFIG_HOME:-''$HOME/.config}/tundra"
        STATE_FILE="$CONFIG_DIR/theme"
        mkdir -p "$CONFIG_DIR"
        case ''${1:-current} in
          current)
            if [ -f "$STATE_FILE" ]; then cat "$STATE_FILE"; else echo "${defaultTheme}"; fi
            ;;
          list|ls)
            echo "Available themes (declarative — set tundra.theme in your host Nix config):"
            echo "  everforest-blue  catppuccin-mocha"
            ;;
          set)
            echo "Runtime theme mutation is disabled; it would diverge from Nix." >&2
            echo "Edit tundra.theme in the intended host configuration instead." >&2
            exit 2
            ;;
          *)
            echo "Usage: tundra-theme [current|list]" >&2
            exit 2
            ;;
        esac
      '')
    ];
  };
}
