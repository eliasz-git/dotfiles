{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/darwin/terminal.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # Same for karabiner — keeps keyboard remaps under version control
  home.file.".config/karabiner".source =
    config.lib.file.mkOutOfStoreSymlink
      "/Users/elias/.config/nix-config/modules/darwin/karabiner";

  # AeroSpace — i3-style tiling window manager
  home.file.".config/aerospace/aerospace.toml".text = ''
    # AeroSpace — https://nikitabobko.github.io/AeroSpace/
    [general]
    start-at-login = true

    [gaps]
    inner.gaps = 8
    outer.gaps = 8

    [layouts]
    default-layout = "tiles"

    # Native borders off — felixkratz borders app handles them
    [borders]
    enable = false

    [keybindings]
    # Focus
    alt-left = "focus left"
    alt-down = "focus down"
    alt-up = "focus up"
    alt-right = "focus right"

    # Move windows
    alt-shift-left = "move left"
    alt-shift-down = "move down"
    alt-shift-up = "move up"
    alt-shift-right = "move right"

    # Workspaces
    alt-1 = "workspace 1"
    alt-2 = "workspace 2"
    alt-3 = "workspace 3"
    alt-4 = "workspace 4"
    alt-5 = "workspace 5"
    alt-6 = "workspace 6"
    alt-7 = "workspace 7"
    alt-8 = "workspace 8"
    alt-9 = "workspace 9"
    alt-0 = "workspace 10"

    # Move window to workspace
    alt-shift-1 = "move-node-to-workspace 1"
    alt-shift-2 = "move-node-to-workspace 2"
    alt-shift-3 = "move-node-to-workspace 3"
    alt-shift-4 = "move-node-to-workspace 4"
    alt-shift-5 = "move-node-to-workspace 5"
    alt-shift-6 = "move-node-to-workspace 6"
    alt-shift-7 = "move-node-to-workspace 7"
    alt-shift-8 = "move-node-to-workspace 8"
    alt-shift-9 = "move-node-to-workspace 9"
    alt-shift-0 = "move-node-to-workspace 10"

    # Layouts / window ops
    alt-t = "layout tiles"
    alt-a = "layout accordion"
    alt-f = "fullscreen"
    alt-w = "close"
    alt-enter = "exec-and-forget open -a Terminal"
    alt-tab = "focus next"
    alt-shift-tab = "focus prev"
  '';

  # macOS-specific shell aliases
  programs.zsh.shellAliases = {
    darwin-rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook";
    darwin-update = "cd ~/.config/nix-config && nix flake update && sudo darwin-rebuild switch --flake .#macbook";
  };

  # macOS-specific update function
  programs.zsh.initContent = lib.mkOrder 600 ''
    update-all() {
        echo "Updating Nix flake..."
        cd ~/.config/nix-config
        nix flake update

        echo "Rebuilding macOS system..."
        sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook
    }
  '';
}
