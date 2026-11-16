{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    eza bat fzf zoxide ripgrep fastfetch yq tree yazi btop nano
    curl wget git htop tmux bottom lazydocker
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
    # Chat — Beeper/Discord (gurk-rs is brew-declared on macOS; the nixpkgs
    # build fails on darwin on -lsqlcipher, so it stays Linux-only here)
    weechat discordo
    # RSS — NetNewsWire
    newsboat
    # Notes/Markdown — Obsidian
    glow zk nb mdcat
    # Browser — Firefox
    w3m lynx elinks browsh
    # Editor — VSCodium (nano kept, add helix)
    helix micro
    # Password — Yubico (KeePassXC is brew-declared cask on macOS; nixpkgs build fails on darwin)
    # yubikey-manager = ykman CLI (YubiKey configuration). yubioath-flutter is the
    # YubiKey Authenticator GUI (Linux-only; macOS gets yubico-authenticator via
    # the homebrew cask in hosts/darwin/configuration.nix). KeePassXC stays in
    # the isLinux list below.
    yubikey-manager
    # Media — IINA/GrayJay/YouTube
    mpv yt-dlp ytfzf
    # System — btop already + extras
    duf dust ncdu
    # Misc TUI
    cmatrix cbonsai pipes
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    veracrypt keepassxc yubioath-flutter gurk-rs
  ];
}
