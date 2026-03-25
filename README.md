# 🌲 Nix Configuration

Multi-system Nix configuration with Everforest Dark theme for macOS (M2) and NixOS (Intel laptop).

[![NixOS 25.05](https://img.shields.io/badge/NixOS-25.05-blue.svg)](https://nixos.org)
[![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg)](https://nixos.org)

## 📋 Quick Links

- [Systems](#-systems) - What's configured
- [Quick Start](#-quick-start) - Get running fast
- [Features](#-features) - What's included
- [Installation](#-installation) - Detailed setup
- [Usage](#-usage) - Daily operations

## 💻 Systems

| System | Architecture | WM/DE | Status |
|--------|--------------|-------|--------|
| **MacBook M2** | aarch64-darwin | yabai + SketchyBar | ✅ Active |
| **HP ProBook 450 G8** | x86_64-linux | Niri + Waybar | ✅ Active |

**Shared Features:**
- 🎨 Everforest Dark Medium theme
- 🐚 Zsh + Starship
- 📝 Kitty terminal
- 🔧 Dev tools: Python, Node.js, Go, Rust

## 🚀 Quick Start

### First-Time Setup

```bash
# Clone the repository
git clone https://github.com/tundra-node/nix-config ~/.config/nix-config
cd ~/.config/nix-config

# Run interactive setup
./scripts/setup.sh
```

The setup script will:
1. Detect your OS
2. Prompt for your details (username, email)
3. Configure everything automatically
4. Show you the next steps

### Manual Setup

**macOS:**
```bash
cd hosts/darwin
./replace.sh youruser yourgithubuser your@email.com
cd ../..
nix flake update
sudo darwin-rebuild switch --flake .#macbook
```

**NixOS:**
```bash
# Copy hardware config
sudo cp /etc/nixos/hardware-configuration.nix ./hosts/nixos/

# Replace placeholders (optional - or use setup.sh)
cd hosts/nixos
./replace.sh youruser yourgithubuser your@email.com
cd ../..

# Remove existing /etc/nixos and create symlink
sudo rm -rf /etc/nixos
sudo ln -s ~/.config/nix-config /etc/nixos

# Update and build
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .#laptop
```

## ✨ Features

### macOS (yabai + SketchyBar)
- **Window Manager**: yabai with Everforest borders
- **Status Bar**: Custom SketchyBar with enhanced transparency and modern design
  - **Printing**: Integrated CUPS support with printer status indicator
  - **iCloud**: Live iCloud Drive sync status monitoring
  - System monitors: CPU, Battery, Volume, Calendar
  - Transparent background with subtle shadows for depth
- **Package Manager**: Nix + Homebrew for GUI apps

### NixOS (Niri + Waybar)
- **Compositor**: Niri scrollable tiling Wayland compositor
- **Status Bar**: Enhanced Waybar with full transparency and modern design
  - **Printing**: CUPS support with printer status indicator and multi-driver support
  - **Cloud Sync**: Nextcloud/DavMail integration with live sync status
  - System monitors: CPU, Memory, Battery, Network, Volume
  - Transparent background with shadows and rounded corners
  - iCloud calendar/contacts sync via DavMail or GNOME Online Accounts
- **Login**: SDDM with Chili theme
- **Power**: TLP optimized
- **Extras**: Dunst, rofi, screenshot tools

### Development Environment
```
Languages:  Python 3.12, Node.js 22, Go, Rust
CLI Tools:  bat, eza, fzf, ripgrep, zoxide
Git:        gh, lazygit
Editors:    VSCodium, Neovim (via packages)
```

## 📥 Installation

### Prerequisites

**Both Systems:**
- Nix package manager ([install](https://nixos.org/download.html))
- Git

**macOS Only:**
- nix-darwin ([install](https://github.com/LnL7/nix-darwin))
- Command Line Tools: `xcode-select --install`

**NixOS Only:**
- Fresh NixOS installation

### Step-by-Step

<details>
<summary><b>macOS Installation</b></summary>

1. **Clone repo:**
   ```bash
   git clone https://github.com/tundra-node/nix-config ~/.config/nix-config
   cd ~/.config/nix-config
   ```

2. **Run setup:**
   ```bash
   ./scripts/setup.sh
   ```

3. **For yabai (optional):**
   - Disable SIP in Recovery Mode
   - Reboot holding Cmd+R (Intel) or Power button (M1/M2)
   - Terminal → `csrutil disable`
   - Reboot normally

4. **Post-install:**
   ```bash
   brew services restart sketchybar
   brew services restart yabai
   ```

</details>

<details>
<summary><b>NixOS Installation</b></summary>

1. **Clone repo:**
   ```bash
   git clone https://github.com/tundra-node/nix-config ~/.config/nix-config
   cd ~/.config/nix-config
   ```

2. **Copy hardware config:**
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix ./hosts/nixos/
   ```

3. **Run setup (recommended):**
   ```bash
   ./scripts/setup.sh
   ```
   
   **Or manual setup:**
   ```bash
   # Replace placeholders in config files
   cd hosts/nixos
   ./replace.sh youruser yourgithubuser your@email.com
   cd ../..
   ```

4. **Create symlink to config:**
   ```bash
   # Remove default /etc/nixos directory
   sudo rm -rf /etc/nixos
   
   # Create symlink (no trailing slash!)
   sudo ln -s ~/.config/nix-config /etc/nixos
   
   # Verify it worked
   ls -la /etc/nixos
   # Should show: /etc/nixos -> /home/youruser/.config/nix-config
   ```

5. **Update timezone** in `hosts/nixos/configuration.nix`:
   ```nix
   time.timeZone = "Your/Timezone";  # e.g., "America/New_York"
   ```

6. **Build and reboot:**
   ```bash
   cd /etc/nixos
   sudo nix flake update
   sudo nixos-rebuild switch --flake .#laptop
   sudo reboot
   ```

7. **First login:**
   - Select "Niri" session at SDDM
   - `Super + G` → Terminal (physical T key on Colemak)
   - `Super + Space` → App launcher

</details>

## 📚 Usage

### Helper Scripts

All scripts are in `scripts/`:

```bash
# Rebuild system
./scripts/rebuild.sh

# Update flake and rebuild
./scripts/rebuild.sh --update

# Test without committing (NixOS)
./scripts/rebuild.sh --test

# Change wallpaper
./scripts/wallpaper.sh /path/to/wallpaper.jpg

# Refresh themes (NixOS)
./scripts/refresh-theme.sh
```

### Common Tasks

**Update everything:**
```bash
./scripts/rebuild.sh --update
```

**Edit configuration:**
```bash
# macOS
code ~/.config/nix-config/hosts/darwin/

# NixOS
code ~/.config/nix-config/hosts/nixos/
```

**Add a package:**
1. Edit `home.nix` in your system folder
2. Add to `home.packages = with pkgs; [ your-package ];`
3. Rebuild: `./scripts/rebuild.sh`

### Keybindings

<details>
<summary><b>NixOS (Niri)</b></summary>

Keybindings are **colemak-aware** — they match the same physical key positions as the
original Hyprland config (e.g. the physical `T` key, which is `G` in Colemak, opens the terminal).

| Key | Action |
|-----|--------|
| `Super + G` | Kitty terminal (physical T key) |
| `Super + B` | Brave browser |
| `Super + U` | VSCodium (physical I key) |
| `Super + M` | Lollypop music player |
| `Super + Return` | Thunar file manager |
| `Super + Space` | App launcher (rofi) |
| `Super + Q` | Close window |
| `Super + Shift + F` | Quit niri (physical E key) |
| `Super + T` | Toggle floating (physical F key) |
| `Super + Shift + Return` | Toggle fullscreen |
| `Super + H / I / E / N` | Focus left / right / up / down |
| `Super + Left/Right/Up/Down` | Focus left / right / up / down |
| `Super + Shift + H / I` | Move column left / right |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |

**Media keys work out of the box** (brightness, volume, play/pause)

**Waybar Modules:**
- **Printer Status** 󰐪: Click to open printer manager, shows active print jobs count
- **Cloud Sync** 󰅟: Shows Nextcloud/DavMail sync status (Synced/Connected/Offline)
- **Media** 󰐊: Current playing media with play/pause controls
- **Network** 󰖨: WiFi signal strength or ethernet status
- **CPU** 󰻠: CPU usage percentage
- **Memory** 󰍛: RAM usage percentage
- **Battery** 󰁹: Battery percentage with charging indicator

</details>

<details>
<summary><b>macOS (yabai)</b></summary>

Standard macOS shortcuts apply. Check `modules/darwin/sketchybar/` for custom configs.

**Menu Bar Items:**
- **Printer Status** 󰐪: Click to open printer preferences, shows active print jobs
- **iCloud Status** 󰀂: Monitor iCloud Drive sync status (green=synced, yellow=syncing, cyan=online, red=offline)
- **Calendar** 􀧞: Current date and time
- **Volume** 🔊: System volume with live updates
- **Battery** 🔋: Battery percentage and charging status
- **CPU** 􀧓: CPU usage percentage

</details>

### Shell Aliases

```bash
ll        # eza -la --icons
cat       # bat (syntax highlighting)
cd x      # z x (smart jumping with zoxide)

g         # git
gs        # git status
gc        # git commit
gp        # git push
```

## 🎨 Customization

### Change Theme Colors

Edit the Everforest colors in your `home.nix`:
```nix
# Look for color definitions like:
background = "#2d353b";
foreground = "#d3c6aa";
# Change to your preferred colors
```

### Adjust Transparency (NixOS)

In `hosts/nixos/home.nix`, modify opacity values in the `window-rules` list:
```nix
window-rules = [
  { matches = [ { app-id = "^kitty$"; } ]; opacity = 0.90; }  # More opaque
  { matches = [ { app-id = "^kitty$"; } ]; opacity = 0.75; }  # More transparent
];
```

**Waybar Transparency:**
```nix
# In the style section, adjust module backgrounds:
background-color: rgba(71, 82, 88, 0.5);  # 0.5 = 50% opacity
# Main bar is fully transparent by default
window#waybar {
  background-color: transparent;
}
```

### Configure Printing (NixOS)

The configuration includes CUPS with multiple printer drivers:
- **Printer status** shows in Waybar (click 󰐪 to open manager)
- **Add printers** via `system-config-printer` GUI or:
  ```bash
  lpstat -p  # List printers
  lpadmin -p printer_name -E -v device_uri  # Add printer
  ```
- **Network printer discovery** enabled via Avahi/mDNS
- **Supported drivers**: HP, Epson, Brother, Canon, and generic Gutenprint

### Cloud Sync & iCloud Integration (NixOS)

**Nextcloud** (iCloud Drive alternative):
- Sync status shown in Waybar 󰅟
- Click icon to open Nextcloud client
- Configure via: `nextcloud` → Settings → Add Account

**iCloud Calendar & Contacts Sync**:
1. **Option 1 - DavMail (recommended)**:
   ```bash
   davmail  # Start DavMail gateway
   # Configure Thunderbird to connect to localhost:1080 (IMAP)
   # Use your iCloud credentials
   ```

2. **Option 2 - GNOME Online Accounts**:
   - Add iCloud account in Settings → Online Accounts
   - Sync with Evolution or Thunderbird

**Status Indicators**:
- "Synced" 󰅟: Nextcloud actively syncing
- "Connected" 󰅟: DavMail connected to iCloud
- "Offline" 󰅟: No sync services running

### Adjust Menu Bar Transparency (macOS)

In `modules/darwin/sketchybar/colors.sh`, modify transparency values:
```bash
export BAR_COLOR=0x882d353b        # Semi-transparent (88 = ~53% opacity)
export ITEM_BG_COLOR=0xaa475258    # Item background (aa = ~67% opacity)
# Format: 0xAARRGGBB where AA is alpha (00=transparent, ff=opaque)
```

### Configure Printing (macOS)

The configuration includes CUPS printing support:
- Printer status shows in menu bar (click to open preferences)
- Add printers via System Preferences → Printers & Scanners
- Or use command line: `lpstat -p` to list printers

### iCloud Integration (macOS)

iCloud Drive status is monitored automatically:
- Green 󰀂: Synced and up-to-date
- Yellow 󰅟: Currently syncing
- Cyan 󰀂: Online and connected
- Red 󰅤: Offline or not available

Ensure iCloud Drive is enabled in System Preferences → Apple ID → iCloud.

### Change Wallpaper

```bash
# Quick change
./scripts/wallpaper.sh /path/to/image.jpg

# Or manually
cp image.jpg ~/.config/nix-config/wallpapers/wallpaper.jpg
./scripts/wallpaper.sh --reload
```

## 🔧 Troubleshooting

<details>
<summary><b>Build fails with "error: No such file or directory"</b></summary>

Make sure you've run `git add .` - flakes only include tracked files!

```bash
git add .
git commit -m "Add configuration"
```

</details>

<details>
<summary><b>NixOS: /etc/nixos symlink created inside directory instead of replacing it</b></summary>

This happens if `/etc/nixos` already exists as a directory. Fix:

```bash
# Remove the existing directory
sudo rm -rf /etc/nixos

# Create the symlink correctly (no trailing slash!)
sudo ln -s ~/.config/nix-config /etc/nixos

# Verify
ls -la /etc/nixos
# Should show: /etc/nixos -> /home/youruser/.config/nix-config
```

</details>

<details>
<summary><b>NixOS: Cursor/GTK theme not applying</b></summary>

```bash
./scripts/refresh-theme.sh
# Log out and back in
```

</details>

<details>
<summary><b>NixOS: Niri won't start</b></summary>

1. Switch to TTY: `Ctrl + Alt + F2`
2. Check logs: `journalctl -u display-manager.service`
3. Try manual start: `niri`

</details>

<details>
<summary><b>macOS: yabai not tiling windows</b></summary>

Check SIP status: `csrutil status`

Should say "disabled". If not, disable in Recovery Mode.

</details>

## 🔄 OpenRC — Why It Isn't in the NixOS Config (and Your Options)

NixOS is architecturally inseparable from **systemd**. The entire module system
(`services.*`, `systemd.services`, `boot.loader.systemd-boot`, etc.) generates
systemd units at build time. There is no supported NixOS option to swap systemd for
OpenRC — attempting it would require patching the core of nixpkgs and would break
essentially every service module.

### Your Options

#### Option A — Stay on NixOS (recommended)
Keep using systemd on NixOS. You get the full declarative power of NixOS, niri works
great, and you lose nothing in day-to-day use. Systemd on NixOS is silent and
stays out of your way.

#### Option B — Artix Linux + Nix package manager
[Artix Linux](https://artixlinux.org/) is an Arch-based distribution that ships
**without** systemd and officially supports OpenRC (as well as runit and s6).

1. Install Artix with the OpenRC ISO from <https://artixlinux.org/download.php>
2. Install the Nix package manager on top for declarative user-land packages:
   ```bash
   # Download the installer, inspect it, then run it
   curl -Lo /tmp/nix-install.sh https://nixos.org/nix/install
   less /tmp/nix-install.sh   # review before executing
   sh /tmp/nix-install.sh --no-daemon
   ```
3. Use Home Manager (standalone mode) to manage your dotfiles declaratively:
   ```bash
   nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
   nix-channel --update
   nix-shell '<home-manager>' -A install
   ```
4. Install niri via pacman or the Nix package manager:
   ```bash
   sudo pacman -S niri   # or: nix profile install nixpkgs#niri
   ```
5. Enable niri as a session by creating `/etc/X11/Sessions/niri` or using a display
   manager that supports Wayland sessions (SDDM works well on Artix).

#### Option C — Alpine Linux + Nix
[Alpine Linux](https://alpinelinux.org/) uses OpenRC natively and has a very small
footprint. The process is similar to Option B:
1. Install Alpine Linux (standard edition).
2. Install Nix: follow <https://nixos.org/download.html> (multi-user install).
3. Install niri via `apk add niri` (edge repository) or via Nix.

#### Option D — Gentoo
Gentoo uses OpenRC by default and gives you full control. Install niri from the
`gui-wm/niri` ebuild in the GURU overlay. You can add the Nix package manager on
top for reproducible user environments if desired.

### Summary

| Distro | Init | Niri | Nix packages | Declarative OS config |
|--------|------|------|--------------|-----------------------|
| NixOS | systemd | ✅ | ✅ Native | ✅ Best-in-class |
| Artix | **OpenRC** | ✅ pacman | ✅ via Nix | ⚠️ Home Manager only |
| Alpine | **OpenRC** | ✅ apk/edge | ✅ via Nix | ⚠️ Home Manager only |
| Gentoo | **OpenRC** | ✅ GURU overlay | ✅ via Nix | ⚠️ Portage + Nix |

If the primary goal is running niri on an OpenRC system, **Artix** is the easiest
path. If the priority is a fully declarative configuration, **stay on NixOS**.

## 🤝 Contributing

This is a personal configuration, but feel free to:
- Fork for your own use
- Open issues for bugs
- Submit PRs for improvements

## 📄 License

MIT License - Use freely!

## 🙏 Acknowledgments

- [NixOS](https://nixos.org/) & [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [Everforest](https://github.com/sainnhe/everforest) theme
- [Niri](https://github.com/YaLTeR/niri) & [yabai](https://github.com/koekeishiya/yabai)

---

**Version Info:**
- nixpkgs: 25.05
- home-manager: release-25.05
- nix-darwin: nix-darwin-25.05
