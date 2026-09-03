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

  home.packages = with pkgs; [
    # KDE polish
    kdePackages.kate kdePackages.konsole kdePackages.yakuake
    kdePackages.okular kdePackages.gwenview kdePackages.ark kdePackages.spectacle

    # Everyday - beginner friendly, big icons
    librewolf brave
    vscodium obsidian libreoffice-fresh vlc celluloid gimp inkscape
    kdePackages.kcalc kdePackages.kcharselect
    nextcloud-client bitwarden-desktop signal-desktop thunderbird

    # Terminal - konsole for kde, kitty backup
    kitty
    tldr eza bat fzf zoxide ripgrep fastfetch yq tree htop btop
    gh lazygit python312 nodejs_22
    cowsay fortune lolcat hollywood pipes

    # Theming - Tundra Dark
    bibata-cursors papirus-icon-theme everforest-gtk-theme adw-gtk3 inter
    kdePackages.breeze-icons kdePackages.breeze-gtk

    # Cyber lab
    nmap wireshark netcat-gnu socat tcpdump masscan amass gobuster ffuf wfuzz nuclei
    burpsuite zap sqlmap nikto hashcat john hydra aircrack-ng
    binwalk exiftool foremost sleuthkit ghidra radare2 cutter metasploit exploitdb seclists
    dnsutils whois binutils strace ltrace
  ];

  programs.zsh.shellAliases = {
    rb = "sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure";
    update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#beattie --impure";
    ll = "eza -la --icons"; la = "eza -a --icons"; l = "eza --icons"; cat = "bat --paging=never";
    helpme = "tldr --list | fzf --preview 'tldr {1}' | xargs tldr";
  };
  programs.zsh.initContent = lib.mkOrder 600 ''
    eval "$(zoxide init zsh)"
    eval "$(pay-respects zsh --alias)"
    export PATH="$HOME/.npm-global/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    if [ ! -f ~/.hushlogin ]; then
      echo ""
      cowsay "Welcome to Beattie Linux (KDE Plasma + NixOS)!" | lolcat
      echo "  Discover: start menu → search anything"
      echo "  Try: tldr ls  |  helpme  |  fastfetch"
      echo "  System Settings → Appearance for Tundra Dark"
      echo ""
    fi
    diag() {
      echo "=== GPU ==="; lspci | grep -E "VGA|Display"; echo "";
      echo "=== ERRORS LAST BOOT ==="; journalctl -b -1 -p 3 --no-pager | tail -n 40
    }
    update-all() {
      echo "Updating flake..."; cd /etc/nixos; sudo nix flake update
      echo "Rebuilding..."; sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure
    }
  '';

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    cursorTheme = { name = "Bibata-Modern-Classic"; package = pkgs.bibata-cursors; size = 24; };
    iconTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
    theme = { name = "Everforest-Dark-BL"; package = pkgs.everforest-gtk-theme; };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };

  # KDE theming - Tundra Dark via Breeze Dark + Papirus
  # Plasma 6 stores config in kdeglobals, kwinrc etc - we set basic dark preference
  # Users can tweak further in System Settings → Appearance

  # Wallpaper
  home.file.".config/nix-config/wallpapers/wallpaper.jpg".source = ../../wallpapers/wallpaper.jpg;

  xdg.desktopEntries.beattie-welcome = {
    name = "Welcome to Linux — Beattie";
    comment = "Beginner guide for this KDE desktop";
    exec = "xdg-open ${config.home.homeDirectory}/.config/nix-config/hosts/beattie/WELCOME.md";
    icon = "help-about"; categories = [ "Utility" ]; terminal = false;
  };
  xdg.desktopEntries.beattie-wiki = {
    name = "Beattie Wiki";
    comment = "Full Beattie lab wiki — KDE, terminal, cybersecurity";
    exec = "xdg-open ${config.home.homeDirectory}/.config/nix-config/hosts/beattie/WIKI.md";
    icon = "accessories-dictionary"; categories = [ "Utility" ]; terminal = false;
  };
  home.file.".config/nix-config/hosts/beattie/WELCOME.md".source = ./WELCOME.md;
  home.file.".config/nix-config/hosts/beattie/WIKI.md".source = ./WIKI.md;
  xdg.configFile."autostart/beattie-welcome.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Beattie Welcome
    Exec=xdg-open ${config.home.homeDirectory}/.config/nix-config/hosts/beattie/WELCOME.md
    X-GNOME-Autostart-enabled=true
    NoDisplay=false
  '';
}
