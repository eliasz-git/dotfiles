{ pkgs, hermes-agent, ... }:

{
  system.stateVersion = 6;
  system.primaryUser = "elias";

  nix.enable = false;
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  environment.systemPackages = with pkgs; let extraPrinting = if stdenv.isLinux then [ gutenprint ] else []; in [
    cups
    ghostscript
    hermes-agent
  ] ++ extraPrinting;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # cleanup "none": "zap" uninstalled unlisted brews (mpdscribble, rust, mpc) and aborted switches
      cleanup = "none";
    };
    taps = [ ];  # declared in extraConfig below with `trusted: true`
    brews = [
      "sketchybar" "cups" "opencode" "mas"
      #"yabai"
      "pcre2" "ripgrep"
      "deno" "himalaya" "openjdk@21" "pnpm" "python@3.14" "yt-dlp" "libomp"
      # Apple Reminders CLI + iMessage CLI (steipete/tap)
      "imsg" "remindctl"
      # Now Playing widget for sketchybar (covers Music, Spotify, YT Music, browsers)
      "nowplaying-cli"
      # mpd/rmpc/mpdscribble/mpc: brew-declared (not nix packages, to skip darwin builds); daemon lifecycle in home.nix
      "mpd" "rmpc" "mpdscribble" "mpc"
      # rust: needed for Rust builds (airpods-cli); declared so it survives rebuilds
      "rust"
      # Soulseek client (GUI, bottled, light); Linux hosts run slskd headless instead
      "nicotine-plus"
    ];
    casks = [
      "cloudflare-warp" "lulu" "keepassxc"
      "obsidian" "pearcleaner" "raycast" "steam" "yubico-authenticator"
      "iina" "karabiner-elements" "claude" "prismlauncher"
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
      # Automation — Hammerspoon for display watcher
      "hammerspoon"
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
      mas "Hush Nag Blocker", id: 1544743900
      mas "uBlock Origin Lite", id: 6745342698
      mas "Obsidian Web Clipper", id: 6720708363
      mas "Night Eye", id: 1450504903
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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    victor-mono
  ];

  services.yabai = {
    enable = false;
  };

  services.jankyborders = {
    enable = false;
  };

  users.users.elias = {
    name = "elias";
    home = "/Users/elias";
    shell = pkgs.zsh;
  };

  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

  programs.zsh.enable = true;

  home-manager.backupFileExtension = "backup";
}
