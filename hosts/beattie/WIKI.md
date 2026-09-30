# Beattie Wiki — KDE Plasma + NixOS Lab

> **Host:** beattie · **DE:** KDE Plasma 6 (Wayland) · **Base:** NixOS 25.05 · **Theme:** Tundra Dark BL + Papirus Dark + Bibata · **Users:** `demo` / `demo` (auto-login, NOPASSWD sudo) + `elias` (admin)

This wiki lives at `hosts/beattie/WIKI.md` — open anytime with **Super → wiki** or `xdg-open ~/.config/nix-config/hosts/beattie/WIKI.md`.

---

## Table of Contents
1. [Quick Start](#quick-start)
2. [Meet the 3 Linux Stations](#meet-the-3-linux-stations)
3. [KDE Plasma Tour (5 min)](#kde-plasma-tour-5-min)
4. [Apps You Actually Have](#apps-you-actually-have)
5. [Terminal Crash Course](#terminal-crash-course)
6. [Customizing KDE Plasma](#customizing-kde-plasma)
7. [NixOS Superpower — Rebuild + Rollback](#nixos-superpower)
8. [Cybersecurity Lab](#cybersecurity-lab)
9. [Cheat Sheets](#cheat-sheets)
10. [Troubleshooting](#troubleshooting)
11. [For Admins (Elias)](#for-admins-elias)

---

## Quick Start
- **Super** opens search — type anything.
- **Panel** = launcher, task manager, favorites, notifications, and system tray.
- **System Monitor** shows CPU/RAM and process details.
- Open **Console**, run:
  ```bash
  fastfetch
  tldr ls
  ```
- Open **Welcome** again: Super → `welcome`

## Meet the 3 Linux Stations
All three run the **same NixOS config**, different desktops:

- **This: beattie — KDE Plasma** — polished, simple, and customizable. Best first desktop.
- **Gaming station** — Hyprland tiling, Wayland-native, and gaming-focused.
- **Omarchy station** — Hyprland tiling, keyboard-driven, for power users.

Try all three. Same apps, same terminal, different shell.

## KDE Plasma Tour (5 min)
- **Activities / Super:** overview, workspaces, search.
- **Panel:** launch applications, pin favorites, and switch windows.
- **Workspaces:** use the workspace switcher or Meta+Tab.
- **Window tiling:** drag windows to screen edges; use `Alt+Tab` to switch.
- **Notifications:** the system tray contains calendar, network, sound, and power controls.
- **Night Light:** Settings → Displays → Night Light (3500K preset, easy on eyes).
- **KDE Connect:** pair your phone (same Wi-Fi) → share files/clipboard. Firewall is open for the KDE Connect range.

## Apps You Actually Have

### System
- **Discover** — graphical app store and Flatpak frontend.
- **System Settings** — colors, themes, displays, input, and window behavior.
- **Kate** — editor; **Konsole** — terminal; **Dolphin** — file manager.
- **Baobab**, **KDE Plasma System Monitor**, and **KCalc**

### Everyday
- **Browsers:** LibreWolf (privacy), Brave
- **Files:** Dolphin — `Ctrl+L` location, `Ctrl+H` hidden files.
- **Editors:** VSCodium, Obsidian, LibreOffice
- **Media:** VLC, Celluloid, Loupe (images), Evince (PDF), GIMP, Inkscape
- **Comms:** Thunderbird, Signal, Nextcloud

### Terminal (both installed)
- **Konsole** — KDE terminal and beginner default.
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

**Shared aliases on every supported host:**
```
tundra rb     → pull GitHub + activate
tundra rbu    → pull + update flake.lock + build, no activation
rbb           → build only
rbe           → evaluate only
rbt           → temporary test activation
rbr           → rollback
ll / la / l   → eza variants
cat           → bat
helpme        → fzf tldr
```

MOTD prints on new shell: `Welcome to Beattie Linux...` with hints.

## Customizing KDE Plasma
- **Appearance:** System Settings → Colors & Themes → dark Breeze variant and green accent.
- **Panel:** right-click the panel → enter edit mode to change position, size, and widgets.
- **Window behavior:** System Settings → Window Management.
- **Display/night light:** System Settings → Display & Monitor.
- **KDE Connect:** pair a phone on the same network; the firewall range is already configured.

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

# update all inputs, then build without activation
cd /etc/nixos
nix flake update
nix build .#nixosConfigurations.beattie.config.system.build.toplevel
# review the lockfile/build, then use rb to activate

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
- **Forgot demo password?** Login as elias, `sudo passwd demo`.
- **Wallpaper not showing?** `home.file` links it to `~/.config/nix-config/wallpapers/wallpaper.jpg` — run `rb` to re-apply dconf.
- **Docker permission?** `groups` should include docker — re-login after `rb`.

## For Admins (Elias)
- **Repo:** `~/Developer/nix-config` → symlinked to `/etc/nixos` on target.
- **Generate hw config on target:** `sudo nixos-generate-config --show-hardware-config > hosts/beattie/hardware-configuration.nix`
- **Build:** `sudo nixos-rebuild switch --flake /etc/nixos#beattie --impure` (also `#beattie` alias)
- **Users:** `demo` (auto-login, NOPASSWD sudo for class — remove `security.sudo.extraRules` if you want password), `elias` (your admin).
- **Hostnames:** `beattie` (flake attrs `beattie` + `beattie`).
- **Flatpak:** `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
- **To lock down:** comment `services.displayManager.autoLogin`, set `users.users.demo.initialPassword = null`, add `users.users.demo.hashedPassword = "..."` or require passwd change.

---

*Questions? Open an issue in nix-config or ask Elias. Have fun — you can't break NixOS, you just rollback.*
