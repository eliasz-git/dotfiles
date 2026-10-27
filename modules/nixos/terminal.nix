{ config, pkgs, ... }:

let
  palette = config.tundra.palette;
in {
  # Share the same font and selected palette as the other desktop hosts.
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
      font-style = "Regular";
      font-style-bold = "Bold";
      font-style-italic = "Italic";
      font-style-bold-italic = "Bold Italic";
      cursor-style = "bar";
      cursor-style-blink = true;
      cursor-color = palette.blue;
      cursor-text = palette.base;
      background = palette.base;
      foreground = palette.text;
      selection-background = palette.surface1;
      selection-foreground = palette.text;
      palette = [
        "0=${palette.surface1}"
        "1=${palette.red}"
        "2=${palette.green}"
        "3=${palette.yellow}"
        "4=${palette.blue}"
        "5=${palette.pink}"
        "6=${palette.teal}"
        "7=${palette.subtext1}"
        "8=${palette.surface2}"
        "9=${palette.red}"
        "10=${palette.green}"
        "11=${palette.yellow}"
        "12=${palette.blue}"
        "13=${palette.pink}"
        "14=${palette.teal}"
        "15=${palette.text}"
      ];
      window-padding-x = 20;
      window-padding-y = 20;
      window-decoration = "none";
      background-opacity = 0.95;
      window-save-state = "always";
      shell-integration = "zsh";
      shell-integration-features = "sudo,cursor";
      copy-on-select = true;
      confirm-close-surface = false;
      quit-after-last-window-closed = false;
      adjust-cell-height = 2;
      scrollback-limit = 10000;
    };
  };

  home.file.".nanorc".text = ''
    # ── Core ──
    set linenumbers
    set indicator
    set constantshow
    set showcursor
    set smarthome
    set autoindent
    set tabsize 4
    set tabstospaces
    set softwrap
    set atblanks
    set breaklonglines
    set boldtext
    set quickblank
    set wordchars
    set wordbounds
    set afterends

    # ── Interaction ──
    set mouse
    set historylog
    set positionlog
    set multibuffer
    set jumpyscrolling
    set smooth
    set zap
    set minibar
    set nohelp
    set stateflags
    set titlecolor brightwhite,blue
    set statuscolor white,blue
    set selectedcolor white,magenta
    set numbercolor brightcyan,blue
    set keycolor brightcyan,blue
    set functioncolor brightwhite,blue
    set scrollercolor cyan,blue

    # ── Safety ──
    set backup
    set backupdir "~/.cache/nano/backups"
    set locking
    set colonparsing

    # ── Syntax ──
    include "~/.nix-profile/share/nano/*.nanorc"
    include "~/.nix-profile/share/nano/extra/*.nanorc"

    # ── Keybinds — linuxy, no conflicts with Ghostty ──
    bind ^S save main
    bind ^Q exit main
    bind ^W copy main
    bind ^F whereis main
    bind ^H help main
    bind ^G help main
    bind ^K cut main
    bind ^U paste main
    bind ^Z undo main
    bind ^Y redo main
    bind ^O insert main
    bind ^T wordcount main
    bind M-W copy main
    bind M-U paste main
    bind ^Left prevword main
    bind ^Right nextword main
    unbind ^J main
  '';

  home.file.".config/nano/syntax/navy.nanorc".text = ''
    syntax "navy" "\.txt$"
    color brightblue "^.*$"
  '';
}
