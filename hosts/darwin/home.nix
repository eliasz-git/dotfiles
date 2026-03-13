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

  # macOS-specific packages only
  home.packages = with pkgs; [
    moonlight-qt
  ];

  # Symlink sketchybar config so changes in nix-config are live immediately
  xdg.configFile."sketchybar" = {
    source = ../../modules/darwin/sketchybar;
    recursive = true;
  };

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
