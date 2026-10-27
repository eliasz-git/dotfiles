{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = with pkgs; [ rofi-calc rofi-emoji ];
    settings = {
      modi = "drun,run,window,ssh,calc,emoji";
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = "Apps";
      display-window = "Windows";
      display-ssh = "SSH";
    };
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
      palette = config.tundra.palette;
    in {
      "*" = {
        background-color = mkLiteral palette.base;
        text-color = mkLiteral palette.text;
      };
      window = {
        location = mkLiteral "center";
        width = 600;
        background-color = mkLiteral palette.base;
        border = mkLiteral "2px";
        border-radius = 8;
        border-color = mkLiteral palette.surface0;
      };
      mainbox = {
        background-color = mkLiteral palette.base;
      };
      input = {
        background-color = mkLiteral palette.mantle;
        text-color = mkLiteral palette.text;
        border = mkLiteral "none";
        margin = 8;
        padding = 12;
      };
      "element selected" = {
        background-color = mkLiteral palette.blue;
        text-color = mkLiteral palette.base;
      };
      listview = {
        background-color = mkLiteral "transparent";
        lines = 10;
        columns = 1;
        fixed-height = false;
      };
      element = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral palette.text;
        padding = mkLiteral "12px 16px";
        spacing = 8;
      };
      "element-text" = {
        text-color = mkLiteral palette.text;
      };
      "element-icon" = {
        size = mkLiteral "1.2em";
      };
    };
  };
}
