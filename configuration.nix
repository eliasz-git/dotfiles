{ pkgs, ... }:

{
  system.stateVersion = 6;
  system.primaryUser = "elias";
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.enable = false;
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # System-wide packages (only essential system tools)
  environment.systemPackages = with pkgs; [];

  # Homebrew integration
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      "FelixKratz/formulae"
      "koekeishiya/formulae"
      "TheBoredTeam/boring-notch"
      "netbirdio/tap"
    ];
    brews = [
      "sketchybar" "borders" "yabai"
    ];
    casks = [
      "cloudflare-warp" "libreoffice" "lulu" "firefox" "signal" "netbird-ui"
      "microsoft-auto-update" "microsoft-powerpoint" "microsoft-teams"
      "obsidian" "pearcleaner" "raycast" "steam" "thunderbird" "alacritty"
      "cyberduck" "vscodium" "iina" "keka" "karabiner-elements" "sf-symbols"
      "knockknock" "oversight" "tuta-mail" "boring-notch" "bitwarden" "grayjay"
    ];
  };

  # macOS defaults - Night Fury optimized
  system.defaults = {
    dock = {
      autohide = true; 
      autohide-delay = 0.0; 
      autohide-time-modifier = 0.5;
      mru-spaces = false; 
      show-recents = false; 
      static-only = true;
      tilesize = 48; 
      largesize = 64; 
      magnification = true;
      orientation = "bottom"; 
      showhidden = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleKeyboardUIMode = 3;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.trackpad.enableSecondaryClick" = true;
    };
    screencapture.location = "/Users/elias/Pictures/Screenshots";
    loginwindow.GuestEnabled = false;
    screensaver.askForPasswordDelay = 5;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    victor-mono
  ];

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    extraConfig = ''
#!/usr/bin/env sh
# Night Fury Yabai Configuration

# Load scripting addition (requires SIP disabled)
sudo yabai --load-sa
yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

# ===== GLOBAL SETTINGS =====

yabai -m config mouse_follows_focus          off
yabai -m config focus_follows_mouse          off
yabai -m config window_origin_display        default
yabai -m config window_placement             second_child
yabai -m config window_topmost               off
yabai -m config window_shadow                float

# ===== TRANSPARENCY & BORDERS (Night Fury) =====

yabai -m config window_opacity               on
yabai -m config window_opacity_duration      0.2
yabai -m config active_window_opacity        0.92
yabai -m config normal_window_opacity        0.70
yabai -m config window_animation_duration    0.2

# Window borders - Electric Blue theme
yabai -m config window_border                on
yabai -m config window_border_width          3
yabai -m config active_window_border_color   0xff64b5f6
yabai -m config normal_window_border_color   0xff1e3a5f
yabai -m config insert_feedback_color        0xff4dd0e1

# ===== LAYOUT =====

yabai -m config layout                       bsp
yabai -m config split_ratio                  0.50
yabai -m config auto_balance                 off

# Padding and gaps (Night Fury spacing)
yabai -m config top_padding                  20   # Space for SketchyBar
yabai -m config bottom_padding               10
yabai -m config left_padding                 10
yabai -m config right_padding                10
yabai -m config window_gap                   10

# ===== MOUSE =====

yabai -m config mouse_modifier               fn
yabai -m config mouse_action1                move
yabai -m config mouse_action2                resize
yabai -m config mouse_drop_action            swap

# ===== WINDOW RULES =====

# Floating windows
yabai -m rule --add app="^System Settings$" manage=off
yabai -m rule --add app="^System Preferences$" manage=off
yabai -m rule --add app="^Archive Utility$" manage=off
yabai -m rule --add app="^Raycast$" manage=off
yabai -m rule --add app="^Calculator$" manage=off
yabai -m rule --add app="^Activity Monitor$" manage=off
yabai -m rule --add app="^Finder$" manage=off
yabai -m rule --add app="^Installer$" manage=off
yabai -m rule --add app="^Lulu$" manage=off
yabai -m rule --add app="^PearCleaner$" manage=off
yabai -m rule --add app="^Mullvad VPN$" manage=off
yabai -m rule --add app="^Facetime$" manage=off
yabai -m rule --add app="^Photos$" manage=on
yabai -m rule --add app="^Alacritty$" manage=on

# Apps with specific opacity (maintain transparency)
yabai -m rule --add app="^Alacritty$" opacity=0.65
yabai -m rule --add app="^VSCodium$" opacity=0.92
yabai -m rule --add app="^Firefox$" opacity=0.90

# ===== SIGNALS (SketchyBar Integration) =====

yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"
yabai -m signal --add event=window_title_changed action="sketchybar --trigger title_change"
yabai -m signal --add event=space_changed action="sketchybar --trigger space_change"

borders active_color=0xff64b5f6 inactive_color=0xff1e3a5f width=5.0 &
sketchybar &
echo "Night Fury yabai configuration loaded.."
    '';
  };

  # User
  users.users.elias = {
    name = "elias";
    home = "/Users/elias";
    shell = pkgs.zsh;
  };

  # Add system PATH for Homebrew
  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

  # Enable zsh at system level
  programs.zsh.enable = true;
  
  home-manager.backupFileExtension = "backup";
}