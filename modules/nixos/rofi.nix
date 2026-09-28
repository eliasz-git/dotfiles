{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg = mkLiteral "#181825";
        bg-alt = mkLiteral "#1e1e2e";
        fg = mkLiteral "#c0caf5";
        selected = mkLiteral "#7aa2f7";
        border = mkLiteral "#313244";
      };
      window = {
        location = mkLiteral "center";
        width = 600;
        background-color = mkLiteral "@bg";
        border = mkLiteral "2px";
        border-radius = 8;
        border-color = mkLiteral "@border";
      };
      input = {
        background-color = mkLiteral "@bg-alt";
        border = mkLiteral "none";
        margin = 8;
        padding = 12;
      };
      "entry:selected" = {
        background-color = mkLiteral "@selected";
        color = mkLiteral "@bg";
      };
      listview = {
        lines = 10;
        columns = 1;
        fixed-height = false;
      };
      element = {
        padding = mkLiteral "12px 16px";
        spacing = 8;
      };
      "element-text" = {
        color = mkLiteral "@fg";
      };
      "element-icon" = {
        size = mkLiteral "1.2em";
      };
    };
  };
}