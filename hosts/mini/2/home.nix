{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/nixos/terminal.nix
  ];

  home.username = "elias";
  home.homeDirectory = "/home/elias";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  xdg.enable = true;

  home.packages = with pkgs; [
    kitty
    powertop
    playerctl
    bluetuith
    netop
    wl-clipboard
    grim
    slurp
    swappy
    dunst
    rofi-wayland
    librewolf
    brave
    thunderbird
    vscodium
    signal-desktop
    bitwarden
    obsidian
    libreoffice
    vlc
    lollypop
    tutanota-desktop
    yubioath-flutter
    prismlauncher
    nextcloud-client
    davmail
    gnome-online-accounts
    bibata-cursors
    papirus-icon-theme
    everforest-gtk-theme
    waybar

    # Add local AI + gaming packages
    ollama
    gamescope
    mangohud
  ];

  programs.zsh.shellAliases = {
    hms = "cd ~/.config/nix-config && nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#mini2";
    hmu = "cd ~/.config/nix-config && nix flake update && nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#mini2";
  };

  # Waybar tweaks: remove battery from modules-right
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "mpris" "pulseaudio" "network" "cpu" "memory" "tray" ];
      };

      "niri/workspaces" = { format = "{name}"; on-click = "activate"; };
      "niri/window" = { max-length = 50; };
      clock = { format = "{:%a %d %b %I:%M %p}"; };
      cpu = { format = "󰻠 {usage}%"; };
      memory = { format = "󰍛 {percentage}%"; };
    };
  };

  # Minimal changes: replace TLP function with comment by removing it from install script
  programs.git = {
    enable = true;
    userName = "elias";
    userEmail = "elias@example.com";
  };
}
