# Beattie — KDE Showcase

NixOS + KDE Plasma 6 (Wayland) — Tundra Dark — beginner-friendly demo + cybersecurity lab.

Hostname: **beattie** — flake: `#beattie` (alias `#beattie`). Complements KDE + Omarchy stations.

## Quick start

```bash
# 1. Generate hardware config on the target machine
sudo nixos-generate-config --show-hardware-config > hosts/beattie/hardware-configuration.nix

# 2. Symlink (first time on that desktop)
sudo rm -rf /etc/nixos
sudo ln -s /path/to/nix-config /etc/nixos
# or: git clone https://github.com/tundra-node/nix-config /etc/nixos

# 3. Validate and build before activation
cd /etc/nixos
./scripts/validate.sh --all
./scripts/tundra-cli.sh build beattie
# 4. Activate after review
./scripts/tundra-cli.sh switch beattie
```

Login: `demo` / `demo` (NOPASSWD sudo for the showcase account). `elias` is admin. No auto-login is configured; harden the initial passwords before exposing the machine.

## What makes it showcase-ready

- **KDE Plasma 6 + SDDM (Wayland)** — familiar, polished, beginner-friendly
- **Look:** Tundra Dark (Everforest-Dark-BL) + Papirus-Dark + Bibata cursor + blur-my-shell + dash-to-dock (bottom) — matches your laptop
- **Desktop tools:** Discover, KDE Connect, Spectacle, Dolphin, Kate, Konsole
- **Store:** Discover + Flatpak + PackageKit
- **Everyday:** Librewolf, Brave, VSCodium, Obsidian, LibreOffice, VLC/Celluloid, GIMP, Inkscape, Loupe, Evince
- **Terminal:** Console + Kitty, tldr, eza, fzf, zoxide, btop, cowsay/fortune/lolcat
- **Cyber lab:** nmap, masscan, amass, gobuster, ffuf, wfuzz, nuclei, burpsuite, zap, sqlmap, nikto, hashcat, john, hydra, aircrack-ng, binwalk, exiftool, foremost, sleuthkit, ghidra, radare2, cutter, metasploit, exploitdb, seclists (+ wireshark/tcpdump/socat/netcat ...)
- **Guides:** WELCOME.md (1-pager) + WIKI.md (full wiki) — both as launchers (Super → welcome/wiki) and autostart

## Wiki

`hosts/beattie/WIKI.md` covers: KDE Plasma tour, terminal crash course, customization, NixOS rebuild/rollback, full cyber lab recipes (nmap→wireshark→gobuster→burp→hashcat→forensics→ghidra→metasploit), cheat sheets, troubleshooting.

## Customizing

Edit `home.nix` dconf:
- KDE System Settings → Colors & Themes
- KDE System Settings → Workspace Behavior
- GTK appearance is managed by Home Manager for GTK applications

Then `rb` to apply.

## Notes
- QWERTY/us keymap for students.
- Dark mode, Night Light 3500K, GSConnect firewall 1714-1764.
- Wallpaper via `home.file` → `~/.config/nix-config/wallpapers/wallpaper.jpg`.
