# BeattieCST1 — GNOME Showcase

NixOS + GNOME (Wayland) — Tundra Dark — beginner-friendly demo + cybersecurity lab.

Hostname: **BeattieCST1** — flake: `#BeattieCST1` (alias `#beattie`). Complements KDE + Omarchy stations.

## Quick start

```bash
# 1. Generate hardware config on the target machine
sudo nixos-generate-config --show-hardware-config > hosts/beattie/hardware-configuration.nix

# 2. Symlink (first time on that desktop)
sudo rm -rf /etc/nixos
sudo ln -s /path/to/nix-config /etc/nixos
# or: git clone https://github.com/tundra-node/nix-config /etc/nixos

# 3. Build (both work)
sudo nixos-rebuild switch --flake /etc/nixos#BeattieCST1 --impure
sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure
# or inside: rb  /  rb-beattie
```

Login: `demo` / `demo` (NOPASSWD sudo, auto-login). `tundra` is admin. To harden: comment `services.displayManager.autoLogin` + set hashedPassword.

## What makes it showcase-ready

- **GNOME + GDM (Wayland)** — familiar, polished, gestures
- **Look:** Tundra Dark (Everforest-Dark-BL) + Papirus-Dark + Bibata cursor + blur-my-shell + dash-to-dock (bottom) — matches your laptop
- **Extensions:** Dash to Dock, AppIndicator, Blur My Shell, Caffeine, Just Perfection, Vitals, ArcMenu, Clipboard Indicator, GSConnect, User Themes
- **Store:** GNOME Software + Flatpak + Extension Manager + Tweaks + dconf-editor
- **Everyday:** Librewolf, Brave, VSCodium, Obsidian, LibreOffice, VLC/Celluloid, GIMP, Inkscape, Loupe, Evince
- **Terminal:** Console + Kitty, tldr, eza, fzf, zoxide, btop, cowsay/fortune/lolcat
- **Cyber lab:** nmap, masscan, amass, gobuster, ffuf, wfuzz, nuclei, burpsuite, zap, sqlmap, nikto, hashcat, john, hydra, aircrack-ng, binwalk, exiftool, foremost, sleuthkit, ghidra, radare2, cutter, metasploit, exploitdb, seclists (+ wireshark/tcpdump/socat/netcat ...)
- **Guides:** WELCOME.md (1-pager) + WIKI.md (full wiki) — both as launchers (Super → welcome/wiki) and autostart

## Wiki

`hosts/beattie/WIKI.md` covers: GNOME tour, terminal crash course, customization, NixOS rebuild/rollback, full cyber lab recipes (nmap→wireshark→gobuster→burp→hashcat→forensics→ghidra→metasploit), cheat sheets, troubleshooting.

## Customizing

Edit `home.nix` dconf:
- `org/gnome/desktop/interface/gtk-theme`
- `org/gnome/shell/extensions/dash-to-dock`
- `org/gnome/shell/extensions/blur-my-shell`

Then `rb` to apply.

## Notes
- QWERTY/us keymap for students.
- Dark mode, Night Light 3500K, GSConnect firewall 1714-1764.
- Wallpaper via `home.file` → `~/.config/nix-config/wallpapers/wallpaper.jpg`.
