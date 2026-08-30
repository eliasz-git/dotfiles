{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../modules/shared/programs.nix
    ../../../modules/shared/shell.nix
    ../../../modules/shared/git.nix
    ../../../modules/shared/multiplexer.nix
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
    slskd

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

      # NixOS (new primary)
      rb  = "sudo nixos-rebuild switch --flake ~/.config/nix-config#mini1";
      rbu = "cd ~/.config/nix-config && sudo nix flake update && sudo nixos-rebuild switch --flake .#mini1";
      # Home-manager fallback
      hms = "home-manager switch --flake ~/.config/nix-config#mini1";
      hmu = "cd ~/.config/nix-config && nix flake update && home-manager switch --flake .#mini1";
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
    userName = "tundra-node";
    userEmail = "117379918+tundra-node@users.noreply.github.com";
  };

  # slskd — headless Soulseek daemon (web UI :5030). Alpine runs OpenRC, so the
  # systemd user unit is inert here; start it with `slskd` directly or an OpenRC
  # service. Only one instance should log in with the account at a time.
  home.file.".config/slskd/slskd.yml".text = ''
    slskd:
      username: "CHANGEME"
      password: "CHANGEME"

    shares:
      directories:
        - "~/Music"

    web:
      username: slskd
      password: slskd
      port: 5030
      https: false
  '';

  systemd.user.services.slskd = {
    Unit = { Description = "slskd Soulseek daemon (headless, web UI :5030)"; };
    Service = {
      ExecStart = "${pkgs.slskd}/bin/slskd";
      Restart = "always";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
}
