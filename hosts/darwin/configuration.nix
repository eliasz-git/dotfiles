{ pkgs, lib, hermes-agent, ... }:

{
  imports = [
    ../../modules/system/themes.nix
    ../../modules/darwin/themes.nix
  ];

  tundra.enable = true;
  tundra.theme = "everforest-blue";

  system.stateVersion = 6;
  system.primaryUser = "elias";

  documentation.man.enable = false;
  documentation.doc.enable = false;
  system.build.manual = lib.mkForce {};

  nix.enable = false;
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  environment.systemPackages = with pkgs; let extraPrinting = if stdenv.hostPlatform.isLinux then [ gutenprint ] else []; in [
    cups
    ghostscript
    hermes-agent
  ] ++ extraPrinting;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      { name = "FelixKratz/formulae"; trusted = true; }
      { name = "koekeishiya/formulae"; trusted = true; }
      { name = "TheBoredTeam/boring-notch"; trusted = true; }
      { name = "pear-devs/pear"; trusted = true; }
      { name = "anomalyco/tap"; trusted = true; }
      { name = "steipete/tap"; trusted = true; }
      { name = "nikitabobko/tap"; trusted = true; }
    ];
    brews = [
      "borders" "cups" "opencode" "sketchybar"
      "pcre2" "ripgrep"
      "deno" "antigravity-cli" "himalaya" "openjdk@21" "pnpm" "python@3.14" "yt-dlp" "libomp"
      "imsg" "remindctl"
      "mole"
      "mpd" "mpc" "rmpc" "mpdscribble" "nowplaying-cli" "kew" "nicotine-plus"
      "docker" "blueutil"
      # AI tools - not in Homebrew, install via npm:
      # "claude-code" -> npm i -g @anthropic-ai/claude-code
      # "copilot-cli" -> npm i -g @github/copilot-cli
      "ollama"
      # Theme tools
      "eza" "bat" "fd" "zoxide" "atuin"
      # "pay-respects" not in Homebrew
      # Utils
      "jq" "yq" "git-delta" "lazygit" "btop" "dust" "procs" "tealdeer"
    ];
    casks = [
      "cloudflare-warp" "libreoffice" "lulu" "signal" "keepassxc"
      "obsidian" "pearcleaner" "raycast" "steam" "thunderbird" "yubico-authenticator"
      "vscodium" "iina" "karabiner-elements" "sf-symbols" "claude" "prismlauncher"
      "knockknock" "oversight" "tuta-mail" "boring-notch"
      "beeper" "flux-app" "lm-studio" "netnewswire" "telegram" "macfuse" "fuse-t" "loop"
      "tor-browser" "utm" "veracrypt" "stats" "microsoft-teams"
      "opencode-desktop"
      "calibre" "discord" "gramps" "openwork" "protonvpn"
      # "copilot-cli" not in Homebrew casks - install via npm
      "burn" "crossover" "tailscale-app"
      "zen" "balenaetcher" "tinymediamanager" "godot"
      "aerospace" "vorssaint"
      "foobar2000" "xld" "musicbrainz-picard" "soulseek"
      "ghostty" "betterdisplay" "openlogi"
      "hermes-desktop" "wakatime"
      # Fonts
      "font-jetbrains-mono-nerd-font" "font-fira-code-nerd-font" "font-victor-mono-nerd-font"
      # "font-sf-mono-nerd-font" not available in Homebrew
      # Additional tools
      "rectangle" "hiddenbar" "monitorcontrol"
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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    victor-mono
  ];

  services.yabai = {
    enable = false;
  };

  services.jankyborders = {
    enable = true;
    width = 6.0;
    hidpi = false; # 1920x1080 @1x - hidpi=on misaligns (left slightly, right off screen)
    active_color = "0xff7fbbb3"; # Everforest aqua-blue
    inactive_color = "0xff3d484d"; # Everforest surface
    style = "round";
    background_color = "0x00000000";
    blur_radius = 0.0;
    ax_focus = false; # off = faster, avoids ghost when window removed
    order = "below"; # below = stable with AeroSpace
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
