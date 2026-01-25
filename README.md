# 🌲 Nix Configuration - Everforest Theme

Multi-system Nix configuration with Everforest Dark Medium color scheme for macOS (M2) and NixOS (Intel laptop).

> **Note**: This configuration uses NixOS/nixpkgs **25.05** and home-manager **release-25.05**.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Systems](#-systems)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [File Structure](#-file-structure)
- [Detailed Installation](#-detailed-installation)
- [Post-Installation](#-post-installation)
- [Usage](#-usage)
- [Customization](#-customization)
- [Known Issues & Solutions](#-known-issues--solutions)
- [Helper Scripts](#-helper-scripts)
- [Troubleshooting](#-troubleshooting)

## 🚀 Quick Start

### One-Liner Setup (Recommended)

After cloning, run the interactive setup script:

```bash
git clone https://github.com/yourusername/nix-config ~/.config/nix-config
cd ~/.config/nix-config
./scripts/setup.sh
```

The setup script will:
- Detect your operating system (macOS or NixOS)
- Prompt for your username, GitHub username, and email
- Replace all placeholders in configuration files
- Provide OS-specific next steps

### Manual Quick Start

**macOS:**
```bash
git clone https://github.com/yourusername/nix-config ~/.config/nix-config
cd ~/.config/nix-config
./darwin/replace.sh youruser yourgithubuser your@email.com
nix flake update
sudo darwin-rebuild switch --flake .#macbook
```

**NixOS:**
```bash
git clone https://github.com/yourusername/nix-config ~/.config/nix-config
sudo cp /etc/nixos/hardware-configuration.nix ~/.config/nix-config/nixos/
sudo ln -sf ~/.config/nix-config /etc/nixos
cd /etc/nixos
./nixos/replace.sh youruser yourgithubuser your@email.com
sudo nix flake update
sudo nixos-rebuild switch --flake .#laptop
```

## 💻 Systems

### macOS (M2 MacBook)
- **Architecture**: aarch64-darwin
- **Window Manager**: yabai (tiling)
- **Status Bar**: SketchyBar
- **Package Manager**: Nix + Homebrew

### NixOS (Intel Laptop)
- **Architecture**: x86_64-linux
- **Window Manager**: Hyprland (Wayland)
- **Status Bar**: Waybar
- **Display Manager**: SDDM with Chili theme
- **Cursor Theme**: Bibata Modern Classic
- **GTK Theme**: Everforest Dark
- **Icons**: Papirus Dark
- **Package Manager**: Nix (pure)

## ✨ Features

### Common Features (Both Systems)
- 🎨 **Everforest Dark Medium** theme throughout
- 🖼️ **Custom wallpapers** - Shared wallpaper folder for both systems
- 🐚 **Zsh** with Starship prompt
- 📝 **Alacritty** terminal (Everforest themed)
- 🔧 **Tmux** with custom Everforest status bar
- 📦 **Development tools**: Git, GitHub CLI, Lazygit, Python, Node.js, Go, Rust
- 🔍 **Modern CLI tools**: eza, bat, fzf, zoxide, ripgrep
- 🎯 **Consistent keybindings** and aliases

### macOS Specific
- 🪟 **yabai** - Tiling window manager with Everforest borders
- 📊 **SketchyBar** - Custom status bar (Everforest themed)
- 🍺 **Homebrew** - For GUI applications
- 🎨 **borders** - Window border highlighting

### NixOS Specific
- 🪟 **Hyprland** - Modern Wayland compositor (Everforest themed)
- 📊 **Waybar** - Translucent status bar (Everforest themed)
- 🔔 **Dunst** - Notification daemon
- 📸 **Screenshot tools** - grim, slurp, swappy
- 🚀 **rofi-wayland** - Application launcher (`Super + Space`)
- 🖼️ **hyprpaper** - Wallpaper manager
- ✨ **Enhanced transparency** - Blur effects and translucent windows
- 🖱️ **Bibata cursors** - Modern cursor theme, system-wide

## 🎨 Everforest Color Palette

```
Background:  #2d353b
Foreground:  #d3c6aa
Green:       #a7c080 (accent)
Red:         #e67e80
Yellow:      #dbbc7f
Blue:        #7fbbb3
Cyan:        #83c092
Magenta:     #d699b6
```

## 📁 File Structure

```
nix-config/
├── .gitignore
├── README.md
├── flake.nix                    # Main flake (nixpkgs 25.05)
│
├── darwin/                      # macOS configurations
│   ├── configuration.nix        # System configuration
│   ├── home.nix                 # User environment
│   └── replace.sh               # Placeholder replacement script
│
├── nixos/                       # NixOS configurations
│   ├── configuration.nix        # System configuration
│   ├── home.nix                 # User environment
│   └── replace.sh               # Placeholder replacement script
│
├── scripts/                     # Helper scripts
│   ├── setup.sh                 # Interactive setup wizard
│   ├── rebuild.sh               # Easy rebuild with options
│   ├── wallpaper.sh             # Wallpaper management
│   └── refresh-theme.sh         # Refresh cursor/GTK themes
│
├── wallpapers/                  # Shared wallpapers
│   └── wallpaper.jpg           # Default wallpaper
│
└── sketchybar/                  # macOS SketchyBar
    ├── colors.sh
    ├── sketchybarrc
    ├── items/
    │   ├── battery.sh
    │   ├── calendar.sh
    │   ├── cpu.sh
    │   ├── front_app.sh
    │   ├── media.sh
    │   ├── spaces.sh
    │   └── volume.sh
    └── plugins/
        ├── battery.sh
        ├── calendar.sh
        ├── cpu.sh
        ├── front_app.sh
        ├── icon_map_fn.sh
        ├── media.sh
        ├── space.sh
        ├── space_windows.sh
        └── volume.sh
```

## 📥 Detailed Installation

### Prerequisites

**macOS:**
- Nix package manager installed ([install guide](https://nixos.org/download.html))
- nix-darwin installed ([install guide](https://github.com/LnL7/nix-darwin))
- Command Line Tools for Xcode

**NixOS:**
- Fresh NixOS installation
- Internet connection

### Step 1: Clone Repository

```bash
# Both systems - clone to ~/.config/nix-config
git clone https://github.com/yourusername/nix-config ~/.config/nix-config
cd ~/.config/nix-config
```

### Step 2: Run Setup Script (Recommended)

```bash
./scripts/setup.sh
```

This handles everything automatically. If you prefer manual setup, continue below.

### Step 3: Manual Setup (Alternative)

#### Replace Placeholders

Edit the following files and replace:
- `{user}` → Your username (e.g., `john`)
- `{username}` → Your GitHub username
- `{email}` → Your GitHub email

**Files to edit:**
- `darwin/configuration.nix`
- `darwin/home.nix`
- `nixos/configuration.nix`
- `nixos/home.nix`
- `flake.nix`

**Using the replace scripts:**

*On macOS:*
```bash
cd darwin
./replace.sh youruser yourgithubuser your@email.com
```

*On NixOS:*
```bash
cd nixos
./replace.sh youruser yourgithubuser your@email.com
```

### Step 4: System-Specific Setup

**macOS:**

1. Make SketchyBar scripts executable:
```bash
chmod +x sketchybar/*.sh
chmod +x sketchybar/items/*.sh
chmod +x sketchybar/plugins/*.sh
```

2. Update and build:
```bash
nix flake update
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook
```

3. For yabai to work fully, disable SIP:
   - Reboot into Recovery Mode (hold Cmd+R during boot on Intel, or hold power button on M1/M2)
   - Open Terminal from Utilities menu
   - Run: `csrutil disable`
   - Reboot

**NixOS:**

1. Copy hardware configuration:
```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/.config/nix-config/nixos/
```

2. Create symlink:
```bash
sudo rm -rf /etc/nixos
sudo ln -s ~/.config/nix-config /etc/nixos
```

3. Update timezone in `nixos/configuration.nix`:
```nix
time.timeZone = "America/New_York";  # Change to your timezone
```

4. Build and reboot:
```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .#laptop
sudo reboot
```

## 🎯 Post-Installation

### First Login (NixOS with Hyprland)

1. At the login screen (SDDM), select "Hyprland" as your session
2. Log in with your user credentials
3. Press `Super + Enter` to open Alacritty terminal
4. Press `Super + Space` to open rofi app launcher

### Verify Git Configuration

```bash
git config --global user.name
git config --global user.email
```

### Refresh Themes (NixOS)

If cursors or GTK themes aren't applied, run:
```bash
./scripts/refresh-theme.sh
```

## 📚 Usage

### Helper Scripts

The `scripts/` directory contains helper utilities:

| Script | Description |
|--------|-------------|
| `setup.sh` | Interactive first-time setup |
| `rebuild.sh` | Easy system rebuild with options |
| `wallpaper.sh` | Change and reload wallpaper |
| `refresh-theme.sh` | Refresh cursor and GTK themes |

**Examples:**
```bash
# Rebuild system
./scripts/rebuild.sh

# Rebuild with flake update
./scripts/rebuild.sh --update

# Test build without committing (NixOS)
./scripts/rebuild.sh --test

# Change wallpaper
./scripts/wallpaper.sh /path/to/new/wallpaper.jpg

# Reload current wallpaper
./scripts/wallpaper.sh --reload

# Refresh themes after changes
./scripts/refresh-theme.sh
```

### Common Commands

**Update System:**
```bash
# Using helper script
./scripts/rebuild.sh --update

# Or manually
update-all  # Shell alias (both systems)
```

**Rebuild System Manually:**
```bash
# macOS
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook

# NixOS
sudo nixos-rebuild switch --flake /etc/nixos#laptop
```

### Shell Aliases

Both systems include these aliases:

```bash
# Navigation
ls → eza --icons
ll → eza -la --icons
cd → z (zoxide)
cat → bat

# Git shortcuts
g → git
gs → git status
gd → git diff
gc → git commit
gp → git push
gl → git pull

# System shortcuts
nixos-rebuild → sudo nixos-rebuild switch --flake /etc/nixos#laptop  # NixOS
darwin-rebuild → sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook  # macOS
```

### Hyprland Keybindings (NixOS)

| Keybinding | Action |
|------------|--------|
| `Super + Enter` | Open terminal (Alacritty) |
| `Super + Space` | Open app launcher (rofi) |
| `Super + Q` | Close window |
| `Super + F` | Toggle floating |
| `Super + H/J/K/L` | Navigate windows (vim-style) |
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Mouse Left` | Move window |
| `Super + Mouse Right` | Resize window |
| `Super + Shift + E` | Exit Hyprland |

## 🎨 Customization

### Change Wallpaper

**Using the helper script:**
```bash
./scripts/wallpaper.sh /path/to/new/wallpaper.jpg
```

**Manual method:**
```bash
cp /path/to/new/wallpaper.jpg ~/.config/nix-config/wallpapers/wallpaper.jpg

# NixOS - Reload hyprpaper
killall hyprpaper; hyprpaper &

# macOS - Set via osascript
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'$HOME'/.config/nix-config/wallpapers/wallpaper.jpg"'
```

### Adjust Transparency (NixOS)

Edit `nixos/home.nix` and modify the opacity values in `windowrulev2`:

```nix
windowrulev2 = [
  "opacity 0.85 0.75,class:^(Alacritty)$"  # First value = focused, second = unfocused
];
```

### Change Cursor Theme (NixOS)

1. Edit `nixos/home.nix`:
```nix
home.pointerCursor = {
  name = "Your-Cursor-Theme";
  package = pkgs.your-cursor-package;
  size = 24;
};
```

2. Rebuild and refresh:
```bash
./scripts/rebuild.sh
./scripts/refresh-theme.sh
```

### Change GTK Theme (NixOS)

1. Edit `nixos/home.nix`:
```nix
gtk.theme = {
  name = "Your-Theme-Name";
  package = pkgs.your-theme-package;
};
```

2. Rebuild and refresh:
```bash
./scripts/rebuild.sh
./scripts/refresh-theme.sh
```

## ⚠️ Known Issues & Solutions

### SDDM Login Screen

**Issue**: Custom SDDM theme not applying or showing default theme.

**Solution**: The configuration uses the `sddm-chili-theme` package. If the theme doesn't appear:
1. Ensure the package is installed: check `environment.systemPackages` in `nixos/configuration.nix`
2. Verify theme files exist: `ls /run/current-system/sw/share/sddm/themes/`
3. Check SDDM config: `cat /etc/sddm.conf`

### Cursor Theme Not Applying

**Issue**: Cursor theme doesn't change system-wide or in specific applications.

**Solution**:
1. Run the theme refresh script: `./scripts/refresh-theme.sh`
2. Ensure `home.pointerCursor` is set in `home.nix`
3. Log out and back in for SDDM changes
4. Some apps (like Firefox) need `XCURSOR_THEME` environment variable

### Wallpaper Not Loading

**Issue**: Wallpaper doesn't appear or is stuck.

**Solution**:
1. Check hyprpaper is running: `pgrep hyprpaper`
2. Verify wallpaper path exists: `ls -la ~/.config/nix-config/wallpapers/`
3. Reload hyprpaper: `./scripts/wallpaper.sh --reload`
4. Check hyprpaper config in `home.nix` uses correct path

### Hyprland Not Starting

**Issue**: Black screen or crash on login.

**Solution**:
1. Switch to TTY (Ctrl+Alt+F2) and login
2. Check Hyprland logs: `cat ~/.local/share/hypr/hyprland.log`
3. Try starting manually: `Hyprland`
4. Ensure graphics drivers are installed

### GTK Apps Look Wrong

**Issue**: GTK applications don't follow the theme.

**Solution**:
1. Run: `./scripts/refresh-theme.sh`
2. Ensure `gtk.enable = true` in `home.nix`
3. Install GTK theme packages: `everforest-gtk-theme`, `papirus-icon-theme`
4. For Flatpak apps, apply separately: `flatpak override --filesystem=~/.themes`

## 🔧 Troubleshooting

### macOS Issues

**SketchyBar not loading:**
```bash
brew services restart sketchybar
```

**yabai not tiling windows:**
```bash
csrutil status  # Check if SIP is disabled
brew services restart yabai
```

### NixOS Issues

**Hyprland not starting:**
```bash
journalctl -u display-manager.service
Hyprland  # Try starting manually
```

**Waybar icons not showing:**
```bash
# Ensure fonts are installed
fc-list | grep -i "JetBrainsMono"
# Rebuild if missing
sudo nixos-rebuild switch --flake /etc/nixos#laptop
```

**Screen sharing not working:**
Add to `nixos/configuration.nix`:
```nix
xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
```

### General Issues

**Flake evaluation errors:**
```bash
nix flake metadata --refresh
```

**Build failures:**
```bash
nix flake update nixpkgs
sudo nixos-rebuild switch --flake /etc/nixos#laptop
```

## 📝 Version Information

| Component | Version |
|-----------|---------|
| nixpkgs | 25.05 |
| home-manager | release-25.05 |
| nix-darwin | nix-darwin-25.05 |
| NixOS stateVersion | 25.05 |

## 📝 Notes

- **macOS users**: Some Homebrew casks may require manual interaction during first install
- **NixOS users**: First build may take 30-60 minutes to download and compile everything
- **Both systems**: The `hardware-configuration.nix` on NixOS is system-specific and should not be committed to git
- **Wallpapers**: Wallpapers are committed to the repo by default. Add `wallpapers/` to `.gitignore` to keep them private

## 🤝 Contributing

Feel free to fork this configuration and adapt it to your needs!

## 📄 License

MIT License - Use freely!

## 🙏 Credits

- [Nix](https://nixos.org/)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [Everforest Theme](https://github.com/sainnhe/everforest)
- [Hyprland](https://hyprland.org/)
- [yabai](https://github.com/koekeishiya/yabai)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [Bibata Cursors](https://github.com/ful1e5/Bibata_Cursor)
