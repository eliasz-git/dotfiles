{ config, lib, pkgs, ... }:

let
  palettes = {
    catppuccin-mocha = {
      base = "#1e1e2e";
      mantle = "#181825";
      surface0 = "#313244";
      surface1 = "#45475a";
      surface2 = "#585b70";
      text = "#cdd6f4";
      subtext0 = "#a6adc8";
      subtext1 = "#bac2de";
      blue = "#89b4fa";
      mauve = "#cba6f7";
      pink = "#f5c2e7";
      peach = "#fab387";
      yellow = "#f9e2af";
      green = "#a6e3a1";
      red = "#f38ba8";
      teal = "#94e2d5";
    };
    everforest-blue = {
      # Everforest Dark (medium contrast), with its muted teal-blue as the
      # interface accent and its canonical greens for status/success colors.
      base = "#2d353b";
      mantle = "#272e33";
      surface0 = "#343f44";
      surface1 = "#3d484d";
      surface2 = "#475258";
      text = "#d3c6aa";
      subtext0 = "#a7a89c";
      subtext1 = "#b0b79c";
      blue = "#7fbbb3";
      mauve = "#d699b6";
      pink = "#d699b6";
      peach = "#e69875";
      yellow = "#dbbc7f";
      green = "#a7c080";
      red = "#e67e80";
      teal = "#83c092";
    };
  };
in {
  options.tundra = {
    enable = lib.mkEnableOption "Tundra theme system";
    theme = lib.mkOption {
      type = lib.types.enum (builtins.attrNames palettes);
      default = "catppuccin-mocha";
      description = "Selected shared desktop palette";
    };
    palette = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = palettes.${config.tundra.theme};
      description = "Shared color tokens derived from the selected Tundra theme";
    };
  };

  config = lib.mkIf config.tundra.enable {
    # Install theme switcher for user
    home.packages = [ (pkgs.writeScriptBin "tundra-theme" ''
      #!/usr/bin/env bash
      set -euo pipefail

      THEMES_DIR="''${HOME}/.config/tundra/themes"
      STATE_FILE="''${HOME}/.config/tundra/theme"
      mkdir -p "''${HOME}/.config/tundra"

      # List available themes
      list_themes() {
        echo "Available themes:"
        for theme in "''${THEMES_DIR}"/*.nix; do
          [ -f "''$theme" ] || continue
          basename "''$theme" .nix | sed 's/^/  /'
        done
      }

      # Apply theme
      apply_theme() {
        local theme_name="''$1"
        local theme_file="''${THEMES_DIR}/''${theme_name}.nix"

        if [ ! -f "''$theme_file" ]; then
          echo "Theme not found: ''$theme_name"
          list_themes
          exit 1
        fi

        echo "''$theme_name" > "''$STATE_FILE"
        echo "Theme set to: ''$theme_name"

        # Trigger rebuild if on NixOS
        if [ -f /etc/nixos/configuration.nix ] || [ -f /etc/nixos/flake.nix ]; then
          echo "Run 'sudo nixos-rebuild switch --flake ~/.config/nix-config#gaming-pc' to apply"
        elif [ -f /etc/nix-darwin/configuration.nix ] || [ -f ~/.config/nix-config/flake.nix ]; then
          echo "Run 'darwin-rebuild switch --flake ~/.config/nix-config#macbook' to apply"
        fi

        # Apply runtime changes for Hyprland/Waybar/Rofi/Dunst if running
        if command -v hyprctl >/dev/null 2>&1; then
          hyprctl reload
        fi
        if command -v waybar >/dev/null 2>&1; then
          pkill -SIGUSR2 waybar 2>/dev/null || true
        fi
        if command -v rofi >/dev/null 2>&1; then
          # Rofi picks up theme on next launch
          true
        fi
        if command -v dunst >/dev/null 2>&1; then
          pkill dunst && dunst &
        fi
        # Update swaylock config for current theme
        if command -v tundra-update-swaylock >/dev/null 2>&1; then
          tundra-update-swaylock
        fi
      }

      # Get current theme
      current_theme() {
        if [ -f "''$STATE_FILE" ]; then
          cat "''$STATE_FILE"
        else
          echo "catppuccin-mocha"
        fi
      }

      case "''${1:-}" in
        ""|current)
          current_theme
          ;;
        list|ls)
          list_themes
          ;;
        set)
          apply_theme "''${2:-}"
          ;;
        *)
          echo "Usage: tundra-theme [current|list|set <theme>]"
          exit 1
          ;;
      esac
    '')];

    # Create state directory and default theme file via activation
    home.activation.tundraTheme = ''
      mkdir -p "$HOME/.config/tundra"
      printf '%s\n' "${config.tundra.theme}" > "$HOME/.config/tundra/theme"
    '';
  };
}
