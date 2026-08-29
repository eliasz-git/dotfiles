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
set -g status-style "bg=#04182F,fg=#68A2C6"
set -g status-left "#[bg=#116FAE,fg=#04182F,bold] #S #[bg=#06467E,fg=#68A2C6] #{pane_current_path} "
set -g status-right "#[bg=#06467E,fg=#68A2C6] %I:%M %p #[bg=#116FAE,fg=#04182F,bold] #h "
set -g window-status-current-style "bg=#116FAE,fg=#04182F,bold"
set -g window-status-style "fg=#7E8A94"
set -g pane-active-border-style "fg=#116FAE"
set -g pane-border-style "fg=#06467E"
    '';
  };
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [ "#116FAE" "bold" ];
        inactiveBorderColor = [ "#06467E" ];
        selectedLineBgColor = [ "#04182F" ];
      };
    };
  };
}
