{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        bright = {
          black = "#253d5a";
          blue = "#4f8fbf";
          cyan = "#6ec6c6";
          green = "#5ba3c9";
          magenta = "#8eafd4";
          red = "#7090b8";
          white = "#cdd9e5";
          yellow = "#a8c8e8";
        };
        cursor = {
          cursor = "#cdd9e5";
          text = "#0d1b2a";
        };
        normal = {
          black = "#1b2d42";
          blue = "#4f8fbf";
          cyan = "#6ec6c6";
          green = "#5ba3c9";
          magenta = "#8eafd4";
          red = "#7090b8";
          white = "#cdd9e5";
          yellow = "#a8c8e8";
        };
        primary = {
          background = "#0d1b2a";
          foreground = "#cdd9e5";
        };
      };
      cursor = {
        blink_interval = 750;
        style = {
          blinking = "On";
          shape = "Beam";
        };
      };
      env = {
        TERM = "xterm-256color";
      };
      font = {
        size = 14.0;
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
      };
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      selection = {
        save_to_clipboard = true;
      };
      window = {
        decorations = "none";
        dynamic_title = true;
        opacity = 0.95;
        padding = {
          x = 20;
          y = 20;
        };
      };
    };
  };
}