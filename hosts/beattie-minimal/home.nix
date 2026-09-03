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
    gnome-tweaks gnome-extension-manager dconf-editor
    librewolf brave vscodium obsidian libreoffice-fresh vlc celluloid gimp inkscape
    loupe evince file-roller gnome-calculator gnome-system-monitor baobab gnome-disk-utility
    kitty gnome-console tldr eza bat fzf zoxide ripgrep fastfetch yq tree htop btop
    gh lazygit python312 nodejs_22 cowsay fortune lolcat
    bibata-cursors papirus-icon-theme everforest-gtk-theme adw-gtk3 inter
    # diagnostic
    inxi lshw pciutils usbutils vulkan-tools mesa-demos
  ];

  programs.zsh.shellAliases = {
    rb = "sudo nixos-rebuild switch --flake /etc/nixos#beattie-minimal --impure";
    rb-full = "sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure";
    update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#beattie-minimal --impure";
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
      cowsay "beattie-minimal (no extensions) - test if black screen goes away" | lolcat
      echo "  rb       -> rebuild minimal"
      echo "  rb-full  -> rebuild full beattie"
      echo "  diag     -> run diagnostics"
      echo ""
    fi
    diag() {
      echo "=== GPU ==="; lspci | grep -E "VGA|Display"; echo ""
      echo "=== ERRORS LAST BOOT ==="; journalctl -b -1 -p 3 --no-pager | tail -n 40; echo ""
      echo "=== GDM ==="; journalctl -b -1 -u display-manager --no-pager | tail -n 40
    }
  '';

  home.pointerCursor = { name = "Bibata-Modern-Classic"; package = pkgs.bibata-cursors; size = 24; gtk.enable = true; x11.enable = true; };
  gtk = {
    enable = true;
    cursorTheme = { name = "Bibata-Modern-Classic"; package = pkgs.bibata-cursors; size = 24; };
    iconTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
    theme = { name = "Everforest-Dark-BL"; package = pkgs.everforest-gtk-theme; };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };

  dconf.settings = {
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
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/.config/nix-config/wallpapers/wallpaper.jpg";
      picture-uri-dark = "file://${config.home.homeDirectory}/.config/nix-config/wallpapers/wallpaper.jpg";
      picture-options = "zoom";
    };
    "org/gnome/desktop/screensaver" = { picture-uri = "file://${config.home.homeDirectory}/.config/nix-config/wallpapers/wallpaper.jpg"; };
    # no extensions enabled - clean gnome
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [];
      favorite-apps = [ "librewolf.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Console.desktop" "codium.desktop" "org.gnome.Software.desktop" ];
    };
    "org/gnome/mutter" = { dynamic-workspaces = true; edge-tiling = true; workspaces-only-on-primary = true; };
    "org/gnome/settings-daemon/plugins/color" = { night-light-enabled = true; night-light-temperature = 3500; };
    "org/gnome/Console" = { custom-font = "JetBrainsMono Nerd Font 11"; theme = "auto"; };
  };

  home.file.".config/nix-config/wallpapers/wallpaper.jpg".source = ../../wallpapers/wallpaper.jpg;
}
