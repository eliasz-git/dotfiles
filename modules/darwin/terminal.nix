{ pkgs, ... }:

{
  programs.alacritty.enable = false;

  # Ghostty — navy palette #04182F / #06467E / #116FAE / #68A2C6 / #305561 / #7E8A94
  # ADHD: low saturation blues, single blue accent, off-white text not pure white
  home.file.".config/ghostty/config".text = ''
    # ── Ghostty — Navy (#04182F wallpaper palette) ──
    font-family = JetBrainsMono Nerd Font
    font-size = 14
    font-style = Regular
    font-style-bold = Bold
    font-style-italic = Italic
    font-style-bold-italic = Bold Italic

    cursor-style = bar
    cursor-style-blink = true
    cursor-color = #68A2C6
    cursor-text = #04182F

    # Primary
    background = #04182F
    foreground = #68A2C6
    selection-background = #06467E
    selection-foreground = #68A2C6

    # Palette — mapped from your 6-color wallpaper scheme
    # normal
    palette = 0=#04182F
    palette = 1=#305561
    palette = 2=#06467E
    palette = 3=#7E8A94
    palette = 4=#116FAE
    palette = 5=#305561
    palette = 6=#68A2C6
    palette = 7=#7E8A94
    # bright (lightened ~20% for ADHD low-contrast)
    palette = 8=#0a2a4a
    palette = 9=#0e5a9a
    palette = 10=#4a7a85
    palette = 11=#9aadb8
    palette = 12=#3d8bc9
    palette = 13=#8ec0e0
    palette = 14=#4a7a85
    palette = 15=#c2d4e0

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

  # Nano — navy-tuned
  home.file.".nanorc".text = ''
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
    set backup
    set backupdir "~/.cache/nano/backups"
    set locking
    include "~/.nix-profile/share/nano/*.nanorc"
    include "~/.nix-profile/share/nano/extra/*.nanorc"
    bind ^S save main
    bind ^Q exit main
    bind ^F whereis main
    bind ^H help main
    bind ^G help main
    bind M-W copy main
  '';

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
}
