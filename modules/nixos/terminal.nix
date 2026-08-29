{ pkgs, ... }:

{
  # Mirror the macOS Ghostty setup — same navy palette, same font/opacity
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
      cursor-color = "#68A2C6";
      cursor-text = "#04182F";
      background = "#04182F";
      foreground = "#68A2C6";
      selection-background = "#06467E";
      selection-foreground = "#68A2C6";
      palette = [
        "0=#04182F"
        "1=#305561"
        "2=#06467E"
        "3=#7E8A94"
        "4=#116FAE"
        "5=#305561"
        "6=#68A2C6"
        "7=#7E8A94"
        "8=#0a2a4a"
        "9=#0e5a9a"
        "10=#4a7a85"
        "11=#9aadb8"
        "12=#3d8bc9"
        "13=#8ec0e0"
        "14=#4a7a85"
        "15=#c2d4e0"
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
