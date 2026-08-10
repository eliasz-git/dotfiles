{ pkgs, hermes-agent, ... }:

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
    taps = [
      "FelixKratz/formulae"
      "koekeishiya/formulae"
      "TheBoredTeam/boring-notch"
      "pear-devs/pear"
      "anomalyco/tap"
      "steipete/tap"
    ];
    brews = [
      "borders" "cups" "opencode"
      #"yabai"
      "pcre2" "ripgrep"
      # Added during macOS 27→26 downgrade prep
      "deno" "gemini-cli" "himalaya" "openjdk@21" "pnpm" "python@3.14" "yt-dlp" "libomp"
      # Apple Reminders CLI + iMessage CLI (steipete/tap)
      "imsg" "remindctl"
    ];
    casks = [
      "cloudflare-warp" "libreoffice" "lulu" "signal" "firefox" "keepassxc"
      "obsidian" "pearcleaner" "raycast" "steam" "thunderbird" "yubico-authenticator"
      "vscodium" "iina" "karabiner-elements" "sf-symbols" "claude" "prismlauncher"
      "knockknock" "oversight" "tuta-mail" "boring-notch" "bitwarden" "pear-desktop"
      "beeper" "flux-app" "lm-studio" "netnewswire" "telegram" "macfuse" "loop"
      "tor-browser" "utm" "veracrypt" "jan" "jetbrains-toolbox" "stats" "microsoft-teams"
      "opencode-desktop"
      # Added during macOS 27→26 downgrade prep
      "calibre" "discord" "gramps" "openwork" "protonvpn"
      "copilot-cli"
      # Apps installed manually (DMG) that have brew casks — catch-up so a
      # rebuild can restore them without re-downloading DMGs
      "burn" "crossover" "docker-desktop" "grayjay" "rustdesk" "tailscale-app"
      "termius" "zed" "zen" "balenaetcher" "tinymediamanager"
    ];
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
