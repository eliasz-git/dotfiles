{ ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = ''
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
set -g status-style "bg=#0d1b2a,fg=#cdd9e5"
set -g window-status-current-style "bg=#5ba3c9,fg=#0d1b2a,bold"
set -g pane-active-border-style "fg=#5ba3c9"
    '';
  };
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [ "#5ba3c9" "bold" ];
        inactiveBorderColor = [ "#1b2d42" ];
        selectedLineBgColor = [ "#1b2d42" ];
      };
    };
  };
}
