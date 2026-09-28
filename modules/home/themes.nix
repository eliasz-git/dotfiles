{ config, lib, pkgs, ... }:

let
  # Theme switcher script - properly escaped for Nix
  themeSwitcher = pkgs.writeScriptBin "tundra-theme" ''
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
  '';

in {
  options.tundra = {
    enable = lib.mkEnableOption "Tundra theme system";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-mocha";
      description = "Current theme name";
    };
  };

  config = lib.mkIf config.tundra.enable {
    # Install theme switcher for user
    home.packages = [ themeSwitcher ];

    # Create state directory and default theme file via activation
    home.activation.tundraTheme = {
      text = ''
        mkdir -p "$HOME/.config/tundra"
        if [ ! -f "$HOME/.config/tundra/theme" ]; then
          echo "${config.tundra.theme}" > "$HOME/.config/tundra/theme"
        fi
      '';
    };
  };
}