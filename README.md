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
| **HP ProBook 450 G8** | x86_64-linux | Hyprland + Waybar | ✅ Active |

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

### NixOS (Hyprland + Waybar)
- **Compositor**: Hyprland with blur and transparency
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
   - Select "Hyprland" session at SDDM
   - `Super + T` → Terminal
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
<summary><b>NixOS (Hyprland)</b></summary>

| Key | Action |
|-----|--------|
| `Super + T` | Kitty terminal |
| `Super + B` | Librewolf browser |
| `Super + Space` | App launcher |
| `Super + Q` | Close window |
| `Super + F` | Toggle float |
| `Super + H/J/K/L` | Navigate windows |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move to workspace |

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

In `hosts/nixos/home.nix`, modify opacity values:
```nix
windowrulev2 = [
  "opacity 0.90 0.80,class:^(kitty)$"  # More opaque
  "opacity 0.75 0.65,class:^(kitty)$"  # More transparent
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
<summary><b>NixOS: Hyprland won't start</b></summary>

1. Switch to TTY: `Ctrl + Alt + F2`
2. Check logs: `journalctl -u display-manager.service`
3. Try manual start: `Hyprland`

</details>

<details>
<summary><b>macOS: yabai not tiling windows</b></summary>

Check SIP status: `csrutil status`

Should say "disabled". If not, disable in Recovery Mode.

</details>

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
- [Hyprland](https://hyprland.org/) & [yabai](https://github.com/koekeishiya/yabai)

---

**Version Info:**
- nixpkgs: 25.05
- home-manager: release-25.05
- nix-darwin: nix-darwin-25.05
