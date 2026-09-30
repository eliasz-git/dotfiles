{ config, ... }:

let
  palette = config.tundra.palette or {
    base = "#2d353b"; mantle = "#272e33"; surface0 = "#343f44";
    surface1 = "#3d484d"; text = "#d3c6aa"; subtext0 = "#a7a89c";
    blue = "#7fbbb3"; green = "#a7c080";
  };
in {
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
set -g status-style "bg=${palette.base},fg=${palette.text}"
set -g status-left "#[bg=${palette.blue},fg=${palette.base},bold] #S #[bg=${palette.surface0},fg=${palette.text}] #{pane_current_path} "
set -g status-right "#[bg=${palette.surface0},fg=${palette.text}] %I:%M %p #[bg=${palette.blue},fg=${palette.base},bold] #h "
set -g window-status-current-style "bg=${palette.blue},fg=${palette.base},bold"
set -g window-status-style "fg=${palette.subtext0}"
set -g pane-active-border-style "fg=${palette.blue}"
set -g pane-border-style "fg=${palette.surface1}"
    '';
  };
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [ palette.blue "bold" ];
        inactiveBorderColor = [ palette.surface1 ];
        selectedLineBgColor = [ palette.base ];
      };
    };
  };
}
