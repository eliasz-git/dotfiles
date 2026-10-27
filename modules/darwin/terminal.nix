{ config, pkgs, ... }:

let
  palette = config.tundra.palette;
in {
  programs.alacritty.enable = false;

  home.file.".config/ghostty/config".text = ''
    # ── Ghostty — shared Tundra palette ──
    font-family = JetBrainsMono Nerd Font
    font-size = 14
    font-style = Regular
    font-style-bold = Bold
    font-style-italic = Italic
    font-style-bold-italic = Bold Italic
    cursor-style = bar
    cursor-style-blink = true
    cursor-color = ${palette.blue}
    cursor-text = ${palette.base}
    background = ${palette.base}
    foreground = ${palette.text}
    selection-background = ${palette.surface1}
    selection-foreground = ${palette.text}
    palette = 0=${palette.surface1}
    palette = 1=${palette.red}
    palette = 2=${palette.green}
    palette = 3=${palette.yellow}
    palette = 4=${palette.blue}
    palette = 5=${palette.pink}
    palette = 6=${palette.teal}
    palette = 7=${palette.subtext1}
    palette = 8=${palette.surface2}
    palette = 9=${palette.red}
    palette = 10=${palette.green}
    palette = 11=${palette.yellow}
    palette = 12=${palette.blue}
    palette = 13=${palette.pink}
    palette = 14=${palette.teal}
    palette = 15=${palette.text}
    window-padding-x = 20
    window-padding-y = 20
    window-decoration = none
    background-opacity = 0.95
    window-save-state = always
    shell-integration = zsh
    shell-integration-features = sudo,cursor
    copy-on-select = true
    confirm-close-surface = false
    quit-after-last-window-closed = false
    macos-option-as-alt = true
    macos-titlebar-style = hidden
    adjust-cell-height = 2
    scrollback-limit = 10000
  '';

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

  home.file.".config/nano/nanorc".text = ''
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
    set backup
    set backupdir "~/.cache/nano/backups"
    set locking
    set colonparsing
    include "~/.nix-profile/share/nano/*.nanorc"
    include "~/.nix-profile/share/nano/extra/*.nanorc"
  '';

  home.file.".config/nano/syntax/navy.nanorc".text = ''
    syntax "navy" "\.txt$"
    color brightblue "^.*$"
  '';
}
