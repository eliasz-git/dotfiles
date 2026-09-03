# Beattie Wiki — KDE Plasma + NixOS Lab

> **Host:** beattie · **DE:** KDE Plasma 6 (Wayland) · **Base:** NixOS 25.05 · **Theme:** Tundra Dark BL + Papirus Dark + Bibata · **Users:** `demo` / `demo` (auto-login, NOPASSWD sudo) + `tundra` (admin)

This wiki lives at `hosts/beattie/WIKI.md` — open anytime with **Super → wiki** or `xdg-open ~/.config/nix-config/hosts/beattie/WIKI.md`.

---

## Table of Contents
1. [Quick Start](#quick-start)
2. [Meet the 3 Linux Stations](#meet-the-3-linux-stations)
3. [KDE Plasma Tour (5 min)](#gnome-tour-5-min)
4. [Apps You Actually Have](#apps-you-actually-have)
5. [Terminal Crash Course](#terminal-crash-course)
6. [Customizing KDE Plasma](#customizing-gnome)
7. [NixOS Superpower — Rebuild + Rollback](#nixos-superpower)
8. [Cybersecurity Lab](#cybersecurity-lab)
9. [Cheat Sheets](#cheat-sheets)
10. [Troubleshooting](#troubleshooting)
11. [For Admins (Elias)](#for-admins-elias)

---

## Quick Start
- **Super** opens search — type anything.
- **Bottom dock** = favorites. Right-click → Add/Remove.
- **Top bar → Vitals** shows CPU/RAM.
- Open **Console**, run:
  ```bash
  fastfetch
  tldr ls
  ```
- Open **Welcome** again: Super → `welcome`

## Meet the 3 Linux Stations
All three run the **same NixOS config**, different desktops:

- **This: beattie — KDE Plasma** — macOS-like, simple, extensions. Best first desktop.
- **KDE Plasma station** — Windows-like, widgets, insane customization.
- **Omarchy station** — Hyprland tiling, keyboard-driven, for power users.

Try all three. Same apps, same terminal, different shell.

## KDE Plasma Tour (5 min)
- **Activities / Super:** overview, workspaces, search.
- **Dash (bottom):** click or Super + number. Drag to reorder. Scroll over icon cycles windows.
- **Workspaces:** dynamic — drag window to right edge creates new. Or Super + swipe.
- **Window tiling:** drag to edge, or Super + Arrow. `Alt+Tab` windows, `Super+Tab` apps.
- **Notifications:** top-center clock → calendar. Bottom-right → quick settings (wifi/sound/power).
- **Night Light:** Settings → Displays → Night Light (3500K preset, easy on eyes).
- **GSConnect:** pair your phone (same wifi) → share files/clipboard. Firewall already open 1714-1764.

## Apps You Actually Have

### System
- **KDE Plasma Software** — graphical app store (Flatpak). No terminal needed.
- **System Settings** — toggle Blur My Shell, Dash to Dock, Caffeine, etc.
- **KDE Plasma Tweaks** — fonts, theme, titlebar buttons.
- **dconf Editor** — advanced KDE Plasma settings.
- **Baobab** (Disk Usage), **KDE Plasma Disk Utility**, **System Monitor**

### Everyday
- **Browsers:** LibreWolf (privacy), Brave
- **Files:** Nautilus — `/` for path, `Ctrl+H` hidden files, `Ctrl+L` location.
- **Editors:** VSCodium, Obsidian, LibreOffice
- **Media:** VLC, Celluloid, Loupe (images), Evince (PDF), GIMP, Inkscape
- **Comms:** Thunderbird, Signal, Nextcloud

### Terminal (both installed)
- **KDE Plasma Console (kgx)** — simple, beginner default.
- **Kitty** — fast, splits, images, for Elias.

## Terminal Crash Course
Open Console:

```bash
# help any command
tldr nmap
helpme            # fzf over all tldrs

# nicer ls/cat
eza --icons
eza -la --icons
bat file.txt

# navigate
z <partial>       # zoxide jump, e.g., z beattie
fzf               # fuzzy finder (Ctrl+R history, Ctrl+T files)

# system
fastfetch
btop              # or htop, nvtop
bat --help | fzf

# fun
cowsay "i use nixos btw" | lolcat
sl
cmatrix
hollywood
pipes
```

**Aliases on this host:**
```
rb            → rebuild beattie

update        → flake update + rebuild
ll / la / l   → eza variants
cat           → bat
helpme        → fzf tldr
```

MOTD prints on new shell: `Welcome to Beattie Linux...` with hints.

## Customizing KDE Plasma
- **Appearance:** Settings → Appearance → Dark, green accent, background `wallpapers/wallpaper.jpg`
- **Dock:** System Settings → Dash to Dock → position/size/intellihide.
- **Blur:** System Settings → Blur My Shell → panel/dash blur.
- **Top bar:** Just Perfection → hide accessibility, adjust padding.
- **Menu:** ArcMenu → Redmond layout, left in panel. Right-click menu button to change.
- **Vitals:** click CPU icon → settings → pick sensors.
- **Caffeine:** top bar coffee cup → prevent sleep during demos.

Theme files (if you want to hack):
- GTK: `Tundra Dark (Everforest-Dark-BL)` from `everforest-gtk-theme`
- Icons: `Papirus-Dark`
- Cursor: `Bibata-Modern-Classic` 24px
- Font: Inter 11, mono JetBrainsMono Nerd Font 11

## NixOS Superpower
Whole desktop = two files: `hosts/beattie/configuration.nix` + `home.nix`.

```bash
# edit, then rebuild
sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure
# or: rb

# update all inputs
sudo nix flake update && sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure
# or: update  (or update-all function)

# try without committing
sudo nixos-rebuild test --flake /etc/nixos#beattie --impure

# rollback
reboot → pick older generation at boot menu
# or: sudo nixos-rebuild switch --rollback
```

No breakage sticks — reboot to previous generation.

## Cybersecurity Lab

> **Rule:** Only scan/attack what you own or have written permission for. Ask instructor before touching school network. These tools are for lab VMs and CTFs.

### Preinstalled Toolkit (both system + home)
**Network / Recon:** `nmap`, `masscan`, `amass`, `gobuster`, `ffuf`, `wfuzz`, `nuclei`, `dnsutils` (dig), `whois`, `wireshark`, `tcpdump`, `socat`, `netcat`  
**Web / AppSec:** `burpsuite`, `zap`, `sqlmap`, `nikto`  
**Cracking:** `hashcat`, `hashcat-utils`, `john`, `hydra`, `hcxtools`, `aircrack-ng`  
**Forensics / Reversing:** `binwalk`, `exiftool`, `foremost`, `sleuthkit`, `ghidra`, `radare2`, `cutter`, `binutils`, `strace`, `ltrace`  
**Misc:** `metasploit`, `exploitdb` (searchsploit), `seclists` (/usr/share/seclists)

### Lab Recipes

**1. Nmap quick scan (your VM only):**
```bash
nmap -sV -A 10.0.2.15
nmap --script vuln 10.0.2.15
```

**2. Wireshark:**
```bash
wireshark &   # demo has NOPASSWD sudo for capture
# or: sudo wireshark
# capture filter: host 10.0.2.15
```

**3. Gobuster dir bust (against your lab web VM):**
```bash
gobuster dir -u http://10.0.2.15 -w /run/current-system/sw/share/seclists/Discovery/Web-Content/common.txt
ffuf -u http://10.0.2.15/FUZZ -w /run/current-system/sw/share/seclists/Discovery/Web-Content/common.txt
```

**4. Burp / ZAP intercept:**
```bash
burpsuite &
zap &
# set browser proxy to 127.0.0.1:8080 (Burp) or 8080 (ZAP)
```

**5. Hash cracking:**
```bash
echo -n "password" | md5sum
hashcat -m 0 -a 0 hashes.txt /run/current-system/sw/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt --force
john --wordlist=/run/current-system/sw/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt hashes.txt
```

**6. Forensics:**
```bash
exiftool image.jpg
binwalk firmware.bin
foremost -i dump.dd -o out/
fls -r -i raw image.dd | head
```

**7. Ghidra / R2:**
```bash
ghidra &
r2 -A binary
# in r2: afl, pdf @ main, iz
cutter &
```

**8. Metasploit:**
```bash
msfconsole
search type:exploit platform:linux
searchsploit apache 2.4
```

SecLists lives via nix at `/run/current-system/sw/share/seclists` — use that path in commands.

### Practice Targets
- Run your own VMs (VirtualBox/virt-manager) — `docker` is enabled for labs (tryhackme/ctf docker images).
- Never `masscan` or `hydra` the school wifi — instant trouble.

## Cheat Sheets

**KDE Plasma:**
- Super — search/overview
- Super+Tab / Alt+Tab — apps / windows
- Super+Arrow — tile
- Print — screenshot
- Super+L — lock

**Terminal basics:**
- `man <cmd>` / `tldr <cmd>` — help
- `Ctrl+C` cancel, `Ctrl+R` history, `Ctrl+L` clear
- `|`, `>`, `>>`, `grep`, `rg`

**NixOS:**
- `/etc/nixos` is your repo (symlink to nix-config)
- generations keep you safe — experiment.

## Troubleshooting
- **No wifi?** Top-right → wifi → pick — or `nmtui` in terminal.
- **Black screen?** Reboot → boot menu → older generation.
- **Extensions broken after update?** System Settings → toggle off/on, or `gnome-extensions list`.
- **Sound broken?** Settings → Sound → output, or `pavucontrol`.
- **Forgot demo password?** Login as tundra, `sudo passwd demo`.
- **Wallpaper not showing?** `home.file` links it to `~/.config/nix-config/wallpapers/wallpaper.jpg` — run `rb` to re-apply dconf.
- **Docker permission?** `groups` should include docker — re-login after `rb`.

## For Admins (Elias)
- **Repo:** `~/Developer/nix-config` → symlinked to `/etc/nixos` on target.
- **Generate hw config on target:** `sudo nixos-generate-config --show-hardware-config > hosts/beattie/hardware-configuration.nix`
- **Build:** `sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure` (also `#beattie` alias)
- **Users:** `demo` (auto-login, NOPASSWD sudo for class — remove `security.sudo.extraRules` if you want password), `tundra` (your admin).
- **Hostnames:** `beattie` (flake attrs `beattie` + `beattie`).
- **Flatpak:** `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
- **To lock down:** comment `services.displayManager.autoLogin`, set `users.users.demo.initialPassword = null`, add `users.users.demo.hashedPassword = "..."` or require passwd change.

---

*Questions? Open an issue in nix-config or ask Elias. Have fun — you can't break NixOS, you just rollback.*
