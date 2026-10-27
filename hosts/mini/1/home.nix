{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../modules/shared/programs.nix
    ../../../modules/shared/shell.nix
    ../../../modules/shared/git.nix
    ../../../modules/shared/multiplexer.nix
    ../../../modules/shared/fastfetch.nix
    ../../../modules/shared/slskd.nix
    ../../../modules/shared/operations.nix
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
    slskd

    nix-tree
    nixpkgs-fmt
    nix-output-monitor
  ];

  programs.zsh = {
    enable = true;
    dotDir = config.xdg.configHome + "/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    shellAliases = {
      ls  = lib.mkForce "eza --icons --group-directories-first";
      ll  = lib.mkForce "eza -la --icons --group-directories-first --git";
      wifi = "bash ~/wifi-setup.sh";
      usb  = "bash ~/usb-mount.sh";

      dps = "docker ps";
      dcu = "docker compose up -d";
      dcd = "docker compose down";
      dcl = "docker compose logs -f";

    };

    initContent = lib.mkOrder 550 ''
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
    settings.user.name = "tundra-node";
    settings.user.email = "117379918+tundra-node@users.noreply.github.com";
  };

  # slskd lives in modules/shared/slskd.nix (secrets: ~/.config/slskd/slskd.env)
}
