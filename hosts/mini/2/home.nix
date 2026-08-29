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

  # Homelab only — headless server / self-hosted tooling, no desktop or gaming GUI
  home.packages = with pkgs; [
    docker docker-compose
    kubernetes helm k9s kubectx
    terraform ansible
    tailscale
    ollama caddy slskd
    btop
    yubikey-manager pass gnupg age sops
    restic rclone
  ];

  programs.zsh.shellAliases = {
    hms = "cd ~/.config/nix-config && nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#mini2";
    hmu = "cd ~/.config/nix-config && nix flake update && nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#mini2";
  };

  programs.git = {
    enable = true;
    userName = "elias";
    userEmail = "elias@example.com";
  };

  # slskd — headless Soulseek daemon (web UI :5030). Only one instance should
  # log in with the account at a time; the always-on homelab is the natural host.
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
