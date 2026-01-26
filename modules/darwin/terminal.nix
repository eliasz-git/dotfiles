{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        bright = {
          black = "#5a524c";
          blue = "#7fbbb3";
          cyan = "#83c092";
          green = "#a7c080";
          magenta = "#d699b6";
          red = "#e67e80";
          white = "#d3c6aa";
          yellow = "#dbbc7f";
        };
        cursor = {
          cursor = "#d3c6aa";
          text = "#2d353b";
        };
        normal = {
          black = "#475258";
          blue = "#7fbbb3";
          cyan = "#83c092";
          green = "#a7c080";
          magenta = "#d699b6";
          red = "#e67e80";
          white = "#d3c6aa";
          yellow = "#dbbc7f";
        };
        primary = {
          background = "#2d353b";
          foreground = "#d3c6aa";
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
        decorations = "full";
        dynamic_title = true;
        opacity = 0.95;
        padding = {
          x = 20;
          y = 20;
        };
      };
    };
  };
};