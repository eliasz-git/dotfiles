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
set -g status-style "bg=#2d353b,fg=#d3c6aa"
set -g window-status-current-style "bg=#a7c080,fg=#2d353b,bold"
set -g pane-active-border-style "fg=#a7c080"
    '';
  };
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [ "#a7c080" "bold" ];
        inactiveBorderColor = [ "#475258" ];
        selectedLineBgColor = [ "#343f44" ];
      };
    };
  };
}
