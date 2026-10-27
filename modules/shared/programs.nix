{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    eza bat fzf zoxide ripgrep fastfetch yq tree yazi btop nano
    curl wget git htop tmux bottom lazydocker topgrade
    gh lazygit delta python312 nodejs_22 go rustup uv
    wakeonlan wireguard-tools nmap tcpdump mtr speedtest-cli
    ffmpeg mediainfo p7zip unzip unrar gzip bzip2 xz zip syncthing
    # ── TUI app ecosystem — r/unixporn replacements ──
    # File manager (yazi already) + preview
    lf nnn
    # Music — local (foobar2000/XLD/Music.app) + Apple Music control (beets disabled on Tahoe gst-python timeout)
    # Kept: termusic (main local, library.db) + cmus (lightweight hyper+m) + nowplaying-cli (brew, Apple Music)
    # mpd + rmpc are brew-declared in configuration.nix (not nix packages, to skip darwin builds); daemon lifecycle via Home Manager launchd.agents in home.nix.
    # Still dropped: ncmpcpp/musikcube (duplicate MPD stack).
    cmus termusic
    # Email — Tuta/Himalaya already + TUI
    # himalaya is brew-declared in configuration.nix (like mpd/rmpc), so brew's 2.1.0 isn't shadowed by stale nixpkgs 2.0.0
    neomutt aerc
    # Chat — Beeper/Discord
    weechat discordo gurk-rs
    # RSS — NetNewsWire
    newsboat
    # Notes/Markdown — Obsidian
    glow zk nb mdcat
    # Browser — Firefox
    w3m lynx elinks browsh
    # Editor — VSCodium (nano kept, add helix)
    helix micro
    # Password — KeePassXC/Yubico (pass/gopass disabled on macOS 26 Tahoe libredirect bug)
    keepassxc yubikey-manager
    # Media — IINA/GrayJay/YouTube
    mpv yt-dlp ytfzf
    # System — btop already + extras
    duf dust ncdu
    # Misc TUI
    cmatrix cbonsai pipes
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    veracrypt
  ];
}
