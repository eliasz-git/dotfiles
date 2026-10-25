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
    kdePackages.kate kdePackages.konsole kdePackages.yakuake kdePackages.okular kdePackages.gwenview kdePackages.ark kdePackages.spectacle
    kdePackages.kcalc
    librewolf brave vscodium obsidian libreoffice-fresh vlc celluloid gimp inkscape
    nextcloud-client bitwarden-desktop signal-desktop thunderbird
    kitty tldr eza bat fzf zoxide ripgrep fastfetch yq tree htop btop gh lazygit python312 nodejs_22
    cowsay fortune lolcat hollywood pipes
    bibata-cursors papirus-icon-theme everforest-gtk-theme adw-gtk3 inter kdePackages.breeze-icons
    inxi lshw pciutils usbutils mesa-demos vulkan-tools
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
      cowsay "beattie-minimal KDE - no heavy cyber lab" | lolcat
      echo "  rb       -> rebuild minimal"
      echo "  rb-full  -> rebuild full beattie (KDE + cyber lab)"
      echo "  diag     -> diagnostics"
      echo ""
    fi
    diag() {
      echo "=== GPU ==="; lspci | grep -E "VGA|Display"; echo "";
      echo "=== ERRORS LAST BOOT ==="; journalctl -b -1 -p 3 --no-pager | tail -n 40; echo "";
      echo "=== SDDM ==="; journalctl -b -1 -u display-manager --no-pager | tail -n 40
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
  home.file.".config/nix-config/wallpapers/wallpaper.jpg".source = ../../wallpapers/wallpaper.jpg;
}
