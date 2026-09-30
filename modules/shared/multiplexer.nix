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

# Colours come from the runtime theme engine rather than from Nix: the fragment
# below is rewritten by tundra-theme-apply, so switching themes does not need a
# rebuild. It is sourced with -q because it does not exist until the applier has
# run at least once, and a first login must not fail on a missing file.
source-file -q "$HOME/.config/tundra/colors/tmux.conf"
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
