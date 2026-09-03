# Welcome to Linux — Beattie GNOME Showcase
### NixOS + GNOME — Tundra Dark — Beginner Friendly

You're on the **GNOME** station — **beattie**. The other two Linux desktops are **KDE Plasma** and **Omarchy** (Hyprland). All three are NixOS — same system, different desktops.

> Full wiki: Super → `Beattie Wiki` or `hosts/beattie/WIKI.md`

---

### 1. Getting Around
- **Super** (Windows key) — overview / search. Just start typing.
- **Super + Tab** / **Alt + Tab** — switch apps / windows.
- **Dash (bottom bar)** — favorite apps. Right-click any app -> Add to Favorites.
- **Top bar** — time, network, sound, power. Click **Vitals** to see CPU/RAM.
- **Workspaces** — Super + drag window to edge, or overview -> drag to new workspace.

### 2. Must-Try Apps (all in the dash or Super search)
- **GNOME Software** — app store (Flatpaks). Install without terminal.
- **Extension Manager** — customize GNOME (dash, blur, etc.). Try toggling Blur My Shell.
- **GNOME Tweaks** — themes, fonts, window buttons.
- **Files (Nautilus)** — file manager. Press `/` to type a path, `Ctrl+H` hidden files.
- **Console + Kitty** — terminals. Console is simple, Kitty is powerful.
- **VSCodium** — code editor.
- **LibreWolf / Brave** — browsers.
- **Obsidian, LibreOffice, VLC, GIMP, Inkscape** — already installed.

### 3. Terminal — 5 Commands to Try
Open **Console** and run:
```bash
fastfetch              # system info (your wallpaper + specs)
tldr ls                # beginner help for any command
eza --icons            # pretty ls
btop                   # better task manager (q to quit)
cowsay "I use NixOS btw" | lolcat
```
Helpers: `tldr <command>` explains anything. `helpme` fuzzy-searches all tldrs.

### 4. Customization
- **Appearance:** Settings -> Appearance -> Style: Dark, Accent: Green.
- **Extensions:** Extension Manager -> turn on/off Dash to Dock, Blur My Shell, Caffeine (prevents sleep), ArcMenu (start menu).
- **Wallpaper:** Settings -> Appearance -> Add Picture. Original at `~/.config/nix-config/wallpapers/wallpaper.jpg`.
- **Theme:** Tundra Dark BL + Papirus Dark icons + Bibata cursor — same family as the other stations.

### 5. Cybersecurity Lab (see Wiki for full recipes)
```bash
nmap -sV 10.0.2.15      # scanner (lab VM only)
wireshark &            # packet analyzer (demo has NOPASSWD)
gobuster dir -u http://10.0.2.15 -w /run/current-system/sw/share/seclists/Discovery/Web-Content/common.txt
burpsuite &  zap & # web intercept
hashcat --help ; john --help
ghidra &  r2 -A binary
msfconsole ; searchsploit apache
```
> Ask instructor before scanning the school network! Full toolkit in WIKI.md: masscan, amass, ffuf, nuclei, sqlmap, hydra, aircrack-ng, binwalk, foremost, sleuthkit, etc.

### 6. NixOS Superpower
This whole desktop is ONE flake: `hosts/beattie/configuration.nix` + `home.nix` → `beattie`.
- `rb` — rebuild (`sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure`)
- `update` — flake update + rebuild
- Rollback: reboot -> pick older generation in boot menu. You can't break it.

### 7. How It Differs From the Other Two
- **This (GNOME):** macOS-like, simple, extensions. Best for beginners/creatives.
- **KDE:** Windows-like, ultra-customizable, widgets.
- **Omarchy:** Keyboard-driven tiling (Hyprland), for power users.

Try all three — pick your favorite.

---
**Tips:** Press **Super** and type `welcome` or `wiki` to reopen. Have fun and break things — you can rollback!
