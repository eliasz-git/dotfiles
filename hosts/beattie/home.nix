{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/nixos/terminal.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # ── User packages — beginner friendly + showcase ───────────────────
  home.packages = with pkgs; [
    # GNOME helpers
    gnome-tweaks
    gnome-extension-manager
    dconf-editor

    # Everyday apps (GUI, discoverable)
    librewolf brave
    vscodium
    obsidian
    libreoffice-fresh
    vlc celluloid
    gimp inkscape
    loupe evince file-roller
    gnome-calculator gnome-system-monitor baobab gnome-disk-utility
    nextcloud-client
    bitwarden-desktop
    signal-desktop
    thunderbird

    # Terminal + CLI (curated for learning)
    kitty gnome-console
    tldr eza bat fzf zoxide ripgrep fastfetch yq tree htop btop
    gh lazygit
    python312 nodejs_22

    # Fun intro to terminal
    cowsay fortune lolcat sl cmatrix hollywood pipes fastfetch

    # Media polish
    bibata-cursors
    papirus-icon-theme
    everforest-gtk-theme
    adw-gtk3
    inter

    # Networking / cyber lab — full toolkit
    nmap wireshark netcat-gnu socat tcpdump masscan amass gobuster ffuf wfuzz nuclei
    burpsuite zap sqlmap nikto
    hashcat john hydra aircrack-ng
    binwalk exiftool foremost sleuthkit
    ghidra radare2 cutter
    metasploit exploitdb seclists
    dnsutils whois binutils strace ltrace
  ];

  # Keep same zsh goodies but add beginner aliases
  programs.zsh.shellAliases = {
    rb = "sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure";
    update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#beattie --impure";
    ll = "eza -la --icons";
    la = "eza -a --icons";
    l = "eza --icons";
    cat = "bat --paging=never";
    helpme = "tldr --list | fzf --preview 'tldr {1}' | xargs tldr";
  };

  programs.zsh.initContent = lib.mkOrder 600 ''
    eval "$(zoxide init zsh)"
    eval "$(pay-respects zsh --alias)"
    export PATH="$HOME/.npm-global/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

    # Friendly MOTD on first open
    if [ ! -f ~/.hushlogin ]; then
      echo ""
      cowsay "Welcome to Beattie Linux (GNOME + NixOS)!" | lolcat
      echo "  Try: tldr ls  |  helpme  |  fastfetch"
      echo "  GNOME Tweaks -> Appearance to theme, Extensions to customize"
      echo ""
    fi

    update-all() {
      echo "Updating flake..."
      cd /etc/nixos
      sudo nix flake update
      echo "Rebuilding..."
      sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure
    }
  '';

  # ── Cursor / GTK — Tundra Dark (matches your laptop) ──────────
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Everforest-Dark-BL";
      package = pkgs.everforest-gtk-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # ── GNOME dconf — make it look really good out of the box ─────────
  dconf.settings = {
    # Interface: Tundra Dark — dark mode, Everforest-Dark-BL base
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Everforest-Dark-BL";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = 24;
      font-name = "Inter 11";
      document-font-name = "Inter 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      enable-animations = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Inter Bold 11";
      button-layout = "appmenu:close";
    };
    # Background — uses your existing wallpaper
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/.config/nix-config/wallpapers/wallpaper.jpg";
      picture-uri-dark = "file://${config.home.homeDirectory}/.config/nix-config/wallpapers/wallpaper.jpg";
      picture-options = "zoom";
      color-shading-type = "solid";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${config.home.homeDirectory}/.config/nix-config/wallpapers/wallpaper.jpg";
    };

    # Dash to Dock (bottom, polished)
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dock-fixed = true;
      extend-height = false;
      autohide = false;
      intellihide = false;
      dash-max-icon-size = 48;
      icon-size-fixed = true;
      show-trash = false;
      show-mounts = true;
      isolate-workspaces = false;
      click-action = "minimize-or-previews";
      scroll-action = "cycle-windows";
      running-indicator-style = "DOTS";
      custom-theme-shrink = true;
      background-opacity = 0.8;
      transparency-mode = "DYNAMIC";
      preferred-monitor = -2; # follow primary
    };

    # Blur My Shell — subtle, premium feel
    "org/gnome/shell/extensions/blur-my-shell" = {
      hacks-level = 1;
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = { blur = true; };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      static-blur = true;
      style-dash-to-dock = 0;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = true;
      brightness = 0.6;
      sigma = 30;
    };

    # Just Perfection — keep top bar clean but not hidden
    "org/gnome/shell/extensions/just-perfection" = {
      panel-button-padding-size = 8;
      panel-indicator-padding-size = 6;
      panel-size = 0;
      window-demands-attention-focus = true;
      accessibility-menu = false;
    };

    # Vitals — show CPU/mem in top bar (great for demos)
    "org/gnome/shell/extensions/vitals" = {
      hot-sensors = [ "_processor_usage_" "_memory_usage_" "_system_load_" ];
      show-battery = true;
      use-higher-precision = false;
      alphabetize = false;
      fixed-widths = true;
    };

    # AppIndicator
    "org/gnome/shell/extensions/appindicator" = {
      legacy-tray-enabled = true;
    };

    # ArcMenu — Windows-like start menu for beginners
    "org/gnome/shell/extensions/arcmenu" = {
      menu-button-appearance = "Icon";
      menu-layout = "Redmond";
      position-in-panel = "Left";
    };

    # Enable extensions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "caffeine@patapon.info"
        "just-perfection-desktop@just-perfection"
        "Vitals@CoreCoding.com"
        "arcmenu@arcmenu.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "clipboard-indicator@tudmotu.com"
        "gsconnect@andyholmes.github.io"
      ];
      favorite-apps = [
        "librewolf.desktop"
        "brave-browser.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Console.desktop"
        "codium.desktop"
        "obsidian.desktop"
        "gnome-system-monitor.desktop"
        "org.gnome.Software.desktop"
        "gnome-tweaks.desktop"
      ];
    };

    # Window behavior — friendly defaults
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [ "<Super>Tab" ];
      switch-windows = [ "<Alt>Tab" ];
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };

    # Night Light (eye care for lab)
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = 3500;
    };

    # Privacy — keep it lab-friendly
    "org/gnome/desktop/privacy" = {
      remember-recent-files = true;
      old-files-age = 7;
    };

    # Console (kgx) theme
    "org/gnome/Console" = {
      custom-font = "JetBrainsMono Nerd Font 11";
      theme = "auto";
    };
  };

  # ── Welcome guide — desktop files + autostart ──────────────────────
  xdg.desktopEntries.beattie-welcome = {
    name = "Welcome to Linux — Beattie";
    comment = "Beginner guide for this GNOME desktop";
    exec = "xdg-open ${config.home.homeDirectory}/.config/nix-config/hosts/beattie/WELCOME.md";
    icon = "help-about";
    categories = [ "Utility" ];
    terminal = false;
  };
  xdg.desktopEntries.beattie-wiki = {
    name = "Beattie Wiki";
    comment = "Full BeattieCST1 lab wiki — GNOME, terminal, cybersecurity";
    exec = "xdg-open ${config.home.homeDirectory}/.config/nix-config/hosts/beattie/WIKI.md";
    icon = "accessories-dictionary";
    categories = [ "Utility" ];
    terminal = false;
  };

  # Copy welcome file via home.file
  home.file.".config/nix-config/hosts/beattie/WELCOME.md".source = ./WELCOME.md;
  home.file.".config/nix-config/hosts/beattie/WIKI.md".source = ./WIKI.md;
  # Ensure wallpaper is available at the dconf path
  home.file.".config/nix-config/wallpapers/wallpaper.jpg".source = ../../wallpapers/wallpaper.jpg;

  # Autostart: show welcome on first login
  xdg.configFile."autostart/beattie-welcome.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Beattie Welcome
    Exec=xdg-open ${config.home.homeDirectory}/.config/nix-config/hosts/beattie/WELCOME.md
    X-GNOME-Autostart-enabled=true
    NoDisplay=false
  '';
}
