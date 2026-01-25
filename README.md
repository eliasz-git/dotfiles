# 🌲 Nix Configuration - Everforest Theme

Multi-system Nix configuration with Everforest Dark Medium color scheme for macOS (M2) and NixOS (Intel laptop).

## 📋 Table of Contents

- [Systems](#-systems)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [File Structure](#-file-structure)
- [Installation](#-installation)
- [Post-Installation](#-post-installation)
- [Usage](#-usage)
- [Customization](#-customization)
- [Troubleshooting](#-troubleshooting)

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
- **Package Manager**: Nix (pure)

## ✨ Features

### Common Features (Both Systems)
- 🎨 **Everforest Dark Medium** theme throughout
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
- 📊 **Waybar** - Status bar (Everforest themed)
- 🔔 **Dunst** - Notification daemon
- 📸 **Screenshot tools** - grim, slurp, swappy
- 🚀 **rofi-wayland** - Application launcher

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
├── flake.nix                    # Main flake for both systems
│
├── darwin/                      # macOS configurations
│   ├── configuration.nix        # System configuration
│   └── home.nix                 # User environment
│
├── nixos/                       # NixOS configurations
│   ├── configuration.nix        # System configuration
│   └── home.nix                 # User environment
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

## 🚀 Installation

### Prerequisites

**macOS:**
- Nix package manager installed
- nix-darwin installed
- Command Line Tools for Xcode

**NixOS:**
- Fresh NixOS installation
- Internet connection

### Step 1: Clone Repository

**macOS:**
```bash
git clone https://github.com/yourusername/nix-config ~/.config/nix-config
cd ~/.config/nix-config
```

**NixOS:**
```bash
# Clone to /etc/nixos (requires sudo)
sudo rm -rf /etc/nixos/*
sudo git clone https://github.com/yourusername/nix-config /etc/nixos
cd /etc/nixos
```

### Step 2: Replace Placeholders

Edit the following files and replace:
- `{user}` → Your username (e.g., `elias`)
- `{username}` → Your GitHub username
- `{email}` → Your GitHub email

**Files to edit:**
- `darwin/configuration.nix`
- `darwin/home.nix`
- `nixos/configuration.nix`
- `nixos/home.nix`
- `flake.nix`

**Quick find and replace:**
```bash
# Replace all placeholders at once
find . -type f -name "*.nix" -exec sed -i '' 's/{user}/yourusername/g' {} +
find . -type f -name "*.nix" -exec sed -i '' 's/{username}/yourgithubusername/g' {} +
find . -type f -name "*.nix" -exec sed -i '' 's/{email}/your@email.com/g' {} +
```

### Step 3: System-Specific Setup

**macOS:**

1. Make SketchyBar scripts executable:
```bash
chmod +x sketchybar/colors.sh
chmod +x sketchybar/sketchybarrc
chmod +x sketchybar/items/*.sh
chmod +x sketchybar/plugins/*.sh
```

2. Update flake:
```bash
nix flake update
```

3. Build system:
```bash
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook
```

4. For yabai to work fully, you need to disable SIP (System Integrity Protection):
   - Reboot into Recovery Mode (hold Cmd+R during boot)
   - Open Terminal from Utilities menu
   - Run: `csrutil disable`
   - Reboot

**NixOS:**

1. Copy hardware configuration:
```bash
# NixOS installer creates this file
sudo cp /etc/nixos/hardware-configuration.nix.backup nixos/hardware-configuration.nix
```

2. Edit `nixos/configuration.nix` to import hardware config:
```nix
imports = [ ./hardware-configuration.nix ];
```

3. Update timezone in `nixos/configuration.nix`:
```nix
time.timeZone = "America/New_York";  # Change to your timezone
```

4. Build system:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#laptop
```

5. Reboot:
```bash
sudo reboot
```

## 🎯 Post-Installation

### First Login (NixOS with Hyprland)

1. At the login screen (SDDM), select "Hyprland" as your session
2. Log in with your user credentials
3. Press `Super + Enter` to open Alacritty terminal

### Configure Git

Git is already configured with your details, but verify:
```bash
git config --global user.name
git config --global user.email
```

### Install Additional Tools

The configuration already includes most tools, but you can add more by editing:
- **macOS**: `darwin/home.nix` → `home.packages`
- **NixOS**: `nixos/home.nix` → `home.packages`

Then rebuild the system.

## 📚 Usage

### Common Commands

**Update System:**
```bash
# macOS
update-all

# NixOS
update-all
```

**Rebuild System Manually:**
```bash
# macOS
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook

# NixOS
sudo nixos-rebuild switch --flake /etc/nixos#laptop
```

**Update Flake Inputs:**
```bash
# macOS
cd ~/.config/nix-config
nix flake update

# NixOS
cd /etc/nixos
sudo nix flake update
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
```

### Hyprland Keybindings (NixOS)

| Keybinding | Action |
|------------|--------|
| `Super + Enter` | Open terminal (Alacritty) |
| `Super + Q` | Close window |
| `Super + F` | Toggle floating |
| `Super + H/J/K/L` | Navigate windows (vim-style) |
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Mouse Left` | Move window |
| `Super + Mouse Right` | Resize window |
| `Super + Shift + E` | Exit Hyprland |

### yabai Keybindings (macOS)

Yabai is controlled via `skhd` (install separately) or via keyboard shortcuts you configure.

## 🎨 Customization

### Change Color Scheme

To change from Everforest to another theme:

1. Update colors in:
   - `darwin/home.nix` or `nixos/home.nix`
   - `sketchybar/colors.sh` (macOS)
   - Hyprland config in `nixos/home.nix` (NixOS)

2. Key color locations:
   - Alacritty: `programs.alacritty.settings.colors`
   - Tmux: `programs.tmux.extraConfig` (theme section)
   - Starship: `programs.starship.settings` (color codes)
   - Hyprland borders: `general."col.active_border"`
   - Waybar: `programs.waybar.style`

### Add Packages

Edit `home.packages` in:
- `darwin/home.nix` (macOS)
- `nixos/home.nix` (NixOS)

Example:
```nix
home.packages = with pkgs; [
  # Add your packages here
  neovim
  firefox
  # ... existing packages
];
```

Then rebuild your system.

### Change Window Manager (NixOS)

To switch from Hyprland to another WM:

1. Edit `nixos/configuration.nix`
2. Replace Hyprland config with your preferred WM
3. Update `nixos/home.nix` to remove Hyprland-specific configs

## 🔧 Troubleshooting

### macOS Issues

**SketchyBar not loading:**
```bash
# Restart SketchyBar
brew services restart sketchybar
```

**yabai not tiling windows:**
```bash
# Check if SIP is disabled
csrutil status

# Restart yabai
brew services restart yabai
```

**Borders not showing:**
```bash
# Restart borders
brew services restart borders
```

### NixOS Issues

**Hyprland not starting:**
```bash
# Check logs
journalctl -u display-manager.service

# Try starting manually
Hyprland
```

**Waybar not showing:**
```bash
# Restart waybar
killall waybar
waybar &
```

**Screen sharing not working:**
```bash
# Install additional portal
# Add to nixos/configuration.nix:
xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
```

### General Issues

**Flake evaluation errors:**
```bash
# Clear flake cache
nix flake metadata --refresh
```

**Build failures:**
```bash
# Update nixpkgs
nix flake update nixpkgs

# Clean build
sudo nixos-rebuild switch --flake /etc/nixos#laptop --recreate-lock-file
```

## 📝 Notes

- **macOS users**: Some Homebrew casks may require manual interaction during first install
- **NixOS users**: First build may take 30-60 minutes to download and compile everything
- **Both systems**: The `hardware-configuration.nix` on NixOS is system-specific and should not be committed to git (it's in `.gitignore`)

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