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
    dps = "docker ps";
    dcu = "docker compose up -d";
    dcd = "docker compose down";
    dcl = "docker compose logs -f";
  };

  programs.git = {
    enable = true;
    settings.user.name = "tundra-node";
    settings.user.email = "117379918+tundra-node@users.noreply.github.com";
  };

  # slskd lives in modules/shared/slskd.nix (secrets: ~/.config/slskd/slskd.env)
}
