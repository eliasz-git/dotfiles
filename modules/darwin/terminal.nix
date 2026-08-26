{ pkgs, ... }:

{
  # Alacritty disabled — replaced by Ghostty (brew cask, config below)
  programs.alacritty.enable = false;

  # Ghostty — GPU-accelerated, native macOS terminal
  # Installed via brew cask `ghostty`, configured here via home-manager
  # https://ghostty.org/docs/config
  home.file.".config/ghostty/config".text = ''
    # ── Ghostty — Everforest Dark (matches previous Alacritty) ──
    font-family = JetBrainsMono Nerd Font
    font-size = 14
    font-style = Regular
    font-style-bold = Bold
    font-style-italic = Italic
    font-style-bold-italic = Bold Italic

    # Cursor — beam, blinking 750ms
    cursor-style = bar
    cursor-style-blink = true
    cursor-color = #cdd9e5
    cursor-text = #0d1b2a

    # Colors — primary
    background = #0d1b2a
    foreground = #cdd9e5
    selection-background = #1b2d42
    selection-foreground = #cdd9e5

    # Palette — normal + bright mapped from Alacritty
    palette = 0=#1b2d42
    palette = 1=#7090b8
    palette = 2=#5ba3c9
    palette = 3=#a8c8e8
    palette = 4=#4f8fbf
    palette = 5=#8eafd4
    palette = 6=#6ec6c6
    palette = 7=#cdd9e5
    palette = 8=#253d5a
    palette = 9=#7090b8
    palette = 10=#5ba3c9
    palette = 11=#a8c8e8
    palette = 12=#4f8fbf
    palette = 13=#8eafd4
    palette = 14=#6ec6c6
    palette = 15=#cdd9e5

    # Window
    window-padding-x = 20
    window-padding-y = 20
    window-decoration = none
    background-opacity = 0.95
    window-save-state = always

    # Behavior — linuxy / keyboard-centric
    shell-integration = zsh
    shell-integration-features = sudo,cursor
    copy-on-select = true
    confirm-close-surface = false
    quit-after-last-window-closed = false
    macos-option-as-alt = true
    macos-titlebar-style = hidden
    adjust-cell-height = 2

    # Scrollback
    scrollback-limit = 10000
  '';

  # ── Nano — highly customizable, replaces neovim ──
  # nano is in home.packages; we ship a rich nanorc here
  home.file.".nanorc".text = ''
    # ── Nano — Everforest-tuned, keyboard-centric ──
    set linenumbers
    set indicator
    set constantshow
    set showcursor
    set autoindent
    set tabsize 4
    set tabstospaces
    set smooth
    set softwrap
    set atblanks
    set mouse
    set historylog
    set positionlog
    set multibuffer
    set jumpyscrolling
    set wordbounds
    set zap
    set minibar
    set nohelp
    set stateflags
    set titlecolor white,blue
    set statuscolor white,green
    set keycolor cyan,blue
    set functioncolor green,blue
    set numbercolor cyan,blue

    # Backups in one place, not littering cwd
    set backup
    set backupdir "~/.cache/nano/backups"
    set locking

    # Syntax highlighting — pull from nix profile
    include "~/.nix-profile/share/nano/*.nanorc"
    include "~/.nix-profile/share/nano/extra/*.nanorc"

    # Keybinds — more linuxy
    bind ^S save main
    bind ^Q exit main
    bind ^F whereis main
    bind ^H help main
    bind ^G help main
    bind M-W copy main
  '';

  # Also expose at XDG location for newer nano
  home.file.".config/nano/nanorc".text = ''
    set linenumbers
    set indicator
    set constantshow
    set showcursor
    set autoindent
    set tabsize 4
    set tabstospaces
    set smooth
    set softwrap
    set atblanks
    set mouse
    set historylog
    set positionlog
    set multibuffer
    set jumpyscrolling
    set wordbounds
    set zap
    set minibar
    set nohelp
    set stateflags
    set backup
    set backupdir "~/.cache/nano/backups"
    set locking
    include "~/.nix-profile/share/nano/*.nanorc"
    include "~/.nix-profile/share/nano/extra/*.nanorc"
  '';

  # Yazi — file manager defaults (nix package provides binary, config is optional)
  # Ships with sane defaults; add custom yazi.toml here if you want later
  # home.file.".config/yazi/yazi.toml".text = '''' ... '''';

  # btop — no extra config needed, respects $XDG_CONFIG_HOME/btop/btop.conf
}
