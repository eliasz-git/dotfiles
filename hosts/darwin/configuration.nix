{ pkgs, hermes-agent, ... }:

{
  system.stateVersion = 6;
  system.primaryUser = "elias";

  # Nix settings
  nix.enable = false;
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # System-wide packages (only essential system tools)
  environment.systemPackages = with pkgs; let extraPrinting = if stdenv.isLinux then [ gutenprint ] else []; in [
    cups
    ghostscript
    hermes-agent
  ] ++ extraPrinting;

  # Homebrew integration
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [ ];  # declared in extraConfig below with `trusted: true`
    brews = [
      "borders" "sketchybar" "cups" "opencode" "mas"
      #"yabai"
      "pcre2" "ripgrep"
      "deno" "himalaya" "openjdk@21" "pnpm" "python@3.14" "yt-dlp" "libomp"
      # Apple Reminders CLI + iMessage CLI (steipete/tap)
      "imsg" "remindctl"
    ];
    casks = [
      "cloudflare-warp" "lulu" "firefox" "keepassxc"
      "obsidian" "pearcleaner" "raycast" "steam" "yubico-authenticator"
      "vscodium" "iina" "karabiner-elements" "claude" "prismlauncher"
      "tuta-mail" "boring-notch" "pear-desktop"
      "beeper" "netnewswire" "macfuse"
      "veracrypt" "microsoft-teams"
      "opencode-desktop"
      # Apps installed manually (DMG) that have brew casks — catch-up so a
      # rebuild can restore them without re-downloading DMGs
      "calibre" "discord" "gramps"
      "burn" "crossover" "docker-desktop" "grayjay" "rustdesk" "tailscale-app"
      "termius" "zed" "balenaetcher" "tinymediamanager" "hermes-desktop"
      "browseros" "wakatime"
      # Tiling WM + menu bar toolkit
      "aerospace" "vorssaint"
      # Terminal — Ghostty replaces Alacritty
      "ghostty"
      # Installed manually via brew, caught up here so rebuilds keep them
      "foobar2000" "xld" "openlogi"
    ];
    # Third-party taps. Declared with `trusted: true` so that `brew bundle
    # cleanup` (run on activation via cleanup = "zap") restores the Homebrew
    # trust store instead of resetting it to empty, which would abort the
    # activation when it then runs `brew cleanup`.
    extraConfig = ''
      tap "FelixKratz/formulae", trusted: true
      tap "koekeishiya/formulae", trusted: true
      tap "TheBoredTeam/boring-notch", trusted: true
      tap "pear-devs/pear", trusted: true
      tap "anomalyco/tap", trusted: true
      tap "steipete/tap", trusted: true
      tap "nikitabobko/tap", trusted: true
      # Mac App Store apps
      mas "Hush Nag Blocker", id: 1544743900
      mas "uBlock Origin Lite", id: 6745342698
      mas "Obsidian Web Clipper", id: 6720708363
    '';
  };

  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      mru-spaces = false;
      show-recents = false;
      static-only = true;
      tilesize = 74;
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
      "com.apple.trackpad.forceClick" = true;
      # Natural scrolling OFF (live value: 0)
      "com.apple.swipescrolldirection" = false;
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
    enable = false;
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
