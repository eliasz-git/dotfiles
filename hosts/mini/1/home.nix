{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../modules/shared/programs.nix
    ../../../modules/shared/fastfetch.nix
  ];

  home.username = "elias";
  home.homeDirectory = "/home/elias";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  xdg.enable = true;

  home.packages = with pkgs; [
    tmux
    btop
    git
    fd
    delta
    jq
    tree
    entr
    just

    zsh
    starship
    fzf
    zoxide
    pass
    gnupg
    yubikey-manager

    impala

    nix-tree
    nixpkgs-fmt
    nix-output-monitor
  ];

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    shellAliases = {
      ls  = "eza --icons --group-directories-first";
      ll  = "eza -la --icons --group-directories-first --git";
      wifi = "bash ~/wifi-setup.sh";
      usb  = "bash ~/usb-mount.sh";

      dps = "docker ps";
      dcu = "docker compose up -d";
      dcd = "docker compose down";
      dcl = "docker compose logs -f";

      hms = "home-manager switch --flake ~/.config/nix-config#mini1";
      hmu = "cd ~/.config/nix-config && nix flake update nixpkgs-unstable && home-manager switch --flake .#mini1";
    };

    initExtra = ''
      [ -f ~/.profile ] && . ~/.profile
      eval "$(zoxide init zsh)"
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh 2>/dev/null || true
      source ${pkgs.fzf}/share/fzf/completion.zsh   2>/dev/null || true
    '';
  };

  # Keep the wifi and usb helper scripts available as user files (simple stubs)
  home.file."wifi-setup.sh" = {
    text = ''
      #!/bin/sh
      echo "Run the wifi-setup.sh from the repo: ~/.config/nix-config/hosts/alpine/wifi-setup.sh"
    '';
    executable = true;
  };

  home.file."usb-mount.sh" = {
    text = ''
      #!/bin/sh
      echo "Run the usb-mount.sh from the repo: ~/.config/nix-config/hosts/alpine/usb-mount.sh"
    '';
    executable = true;
  };

  programs.git = {
    enable = true;
    userName = "elias";
    userEmail = "elias@example.com";
  };
}
