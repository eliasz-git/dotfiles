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

  # Headless — no desktop apps, no gaming. Server TUI only.
  # Old desktop list (kitty/brave/thunderbird/vscodium/waybar/ollama/gamescope)
  # removed per your call to run both minis headless.
  home.packages = with pkgs; [
    btop
    powertop
    bluetuith # bluetooth TUI if ever needed
    wl-clipboard

    # media debugging on headless
    ffmpeg
    mediainfo

    # keep yubikey for ssh
    yubikey-manager
  ];

  programs.zsh.shellAliases = {
    # NixOS (new primary)
    rb  = "sudo nixos-rebuild switch --flake ~/.config/nix-config#mini2";
    rbu = "cd ~/.config/nix-config && sudo nix flake update && sudo nixos-rebuild switch --flake .#mini2";
    # Home-manager fallback (still works standalone if you test without nixos)
    hms = "home-manager switch --flake ~/.config/nix-config#mini2";
    hmu = "cd ~/.config/nix-config && nix flake update && home-manager switch --flake .#mini2";
    dps = "docker ps";
    dcu = "docker compose up -d";
    dcd = "docker compose down";
    dcl = "docker compose logs -f";
  };

  programs.git = {
    enable = true;
    userName = "elias";
    userEmail = "elias@example.com";
  };
}
