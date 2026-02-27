{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/nixos/terminal.nix  # keeps kitty for when you want it
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Browser
    browsh
    w3m

    # Editor
    neovim
    helix

    # File manager
    yazi

    # Email
    neomutt
    isync    # mbsync
    msmtp

    # Music
    ncspot

    # System monitoring
    btop

    # Calendar
    khal
    vdirsyncer

    # Misc TUIs
    glow         # markdown reader
    lazydocker
    signal-cli

    # Power/brightness from TTY
    powertop
    brightnessctl
    playerctl

    # Networking TUI
    bluetuith
  ];

  programs.zsh.shellAliases = {
    terminal-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#terminal --impure";
    terminal-update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#terminal --impure";
  };

  # Auto-launch tmux on login
  programs.zsh.initContent = lib.mkOrder 600 ''
    eval "$(zoxide init zsh)"
    eval "$(thefuck --alias)"
    export PATH="$HOME/.npm-global/bin:$PATH"

    # Auto-start tmux on TTY login
    if [ -z "$TMUX" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec tmux new-session -A -s main
    fi
  '';
}