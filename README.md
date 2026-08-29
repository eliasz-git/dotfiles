# Nix Configuration

Multi-system Nix flake — navy `#04182F` r/unixporn rice. macOS (AeroSpace + SketchyBar), NixOS and Artix (Niri + Waybar).

## Systems

| System | Arch | WM | Init | Status |
|--------|------|----|------|--------|
| MacBook M2 Air | aarch64-darwin | AeroSpace + SketchyBar + Hammerspoon | launchd | active |
| HP ProBook 450 G8 | x86_64-linux | Niri + Waybar | systemd | active |
| HP ProBook 450 G8 | x86_64-linux | Niri + Waybar | OpenRC (Artix) | active |

## Quick start

```bash
git clone https://github.com/tundra-node/nix-config ~/.config/nix-config
cd ~/.config/nix-config
./scripts/setup.sh
```

macOS:
```bash
cd hosts/darwin && ./replace.sh <user> <github> <email> && cd ../..
nix flake update
sudo darwin-rebuild switch --flake .#macbook --option fallback true
```
Artix: `bash hosts/artix/install.sh`
NixOS: copy `hardware-configuration.nix`, symlink `/etc/nixos`, `sudo nixos-rebuild switch --flake .#laptop`

## Features

- Navy palette `#04182F/#06467E/#116FAE/#68A2C6`; set in `modules/darwin/terminal.nix`, `modules/darwin/sketchybar.nix`, `modules/shared/shell.nix`, `modules/shared/multiplexer.nix`.
- Zsh + Starship + FZF + Zoxide + eza/bat; Ghostty + JetBrainsMono Nerd Font; Helix/micro/nano.
- Dev: Python 3.12, Node 22, Go, Rust; yazi/btop/lazygit/delta + full TUI pack.
- Karabiner hyper (`caps`→`cmd+ctrl`, tap Esc), Raycast + `app-launcher` fzf.
- macOS music: `mpd`/`rmpc` are declared in `homebrew.brews` (daemon run by a nix-darwin `launchd.agents`) to avoid darwin builds; `brew` also provides GUI casks.
- Linux: Niri scrollable tiling, Waybar, SDDM Chili, PipeWire, TLP.

## Keybindings (macOS AeroSpace, hyper = caps)

| Key | Action |
|-----|--------|
| `hyper+h/j/k/l` or arrows | focus |
| `hyper+shift+h/j/k/l` | move window |
| `hyper+1..0` | workspace `1-browsers`..`10-vms` |
| `hyper+shift+1..0` | move to workspace |
| `hyper+t/a/f/q/r` | tile / accordion / fullscreen / close / reload |
| `hyper+enter` | Ghostty |
| `hyper+b` | Safari |
| `hyper+c` | Zed |
| `hyper+n` | `Ghostty -e nano` |
| `hyper+m` | `Ghostty -e rmpc` (music) |
| `hyper+v` | GrayJay (video) |
| `hyper+,` | System Settings |
| `hyper+o` | Obsidian |
| `hyper+space` | Raycast |
| `hyper+/` | `app-launcher` (fzf TUI+GUI) |
| `hyper+tab` / `shift+tab` | dfs next / prev |

## Troubleshooting

- Flakes include only tracked files: `git add .` first.
- Tahoe cache 404 / timeouts: use `--option fallback true`; avoid `beets`/`pass` (pull `libredirect`/`gst-python`) until Determinate 3.22 / nixos-unstable.
- AeroSpace gaps/borders: `hosts/darwin/home.nix` `gaps.*`, `hosts/darwin/configuration.nix` `services.jankyborders`.
- Karabiner hyper not working: check `modules/darwin/karabiner/karabiner.json` and System Settings → Privacy → Input Monitoring.
- SketchyBar not updating on display change: Hammerspoon watcher runs `sketchybar --reload`.
