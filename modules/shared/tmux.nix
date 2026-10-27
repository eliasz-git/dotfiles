{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    settings = {
      default-terminal = "screen-256color";
      mouse = true;
      focus-events = false;
      aggressive-resize = false;
      clock-mode-style = 12;
      escape-time = 0;
      history-limit = 50000;
      status-keys = "emacs";
      mode-keys = "emacs";
      prefix = "C-a";
      unbind = [ "C-b" ];
      bind = [
        { key = "C-a"; mod = [ ]; command = "send-prefix"; }
        { key = "|"; mod = [ ]; command = "split-window -h"; }
        { key = "-"; mod = [ ]; command = "split-window -v"; }
        { key = "h"; mod = [ ]; command = "select-pane -L"; }
        { key = "j"; mod = [ ]; command = "select-pane -D"; }
        { key = "k"; mod = [ ]; command = "select-pane -U"; }
        { key = "l"; mod = [ ]; command = "select-pane -R"; }
      ];
    };

    # Theme colors are applied at runtime by tundra-theme-apply to
    # ~/.config/tundra/colors/tmux.conf; this file is sourced if present so a
    # first login does not fail on a missing file.
    home.file.".config/tmux/tmux.conf".text = ''
      set -g default-terminal "screen-256color"
      set -g mouse on
      set -s escape-time 0
      set -g history-limit 50000
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix
      bind | split-window -h
      bind - split-window -v
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      source-file -q "$HOME/.config/tundra/colors/tmux.conf"
    '';
  };
}
