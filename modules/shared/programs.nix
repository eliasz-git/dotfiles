{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    eza bat fzf zoxide ripgrep fastfetch yq thefuck tree yazi btop nano
    curl wget git htop tmux
    gh lazygit python312 nodejs_22 go rustup uv
    wakeonlan wireguard-tools nmap tcpdump mtr speedtest-cli
    ffmpeg mediainfo p7zip unzip unrar gzip bzip2 xz zip syncthing
  ] ++ lib.optionals (!stdenv.isDarwin) [
    # LibreWolf removed on macOS (kept on Linux hosts)
    librewolf
  ] ++ lib.optionals stdenv.isLinux [
    veracrypt
  ];
}
