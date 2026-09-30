# Omarchy Alignment Plan

**Goal:** Bring gaming PC and MacBook configs closer to Omarchy's philosophy while preserving personalized configs (homelab, Beattie, etc.)

---

## Omarchy Philosophy Summary (from analysis)

- **Hyprland-first** with Lua config modules (not hyprlang)
- **Opinionated defaults** with user overrides via `config/hypr/*.lua` files
- **Theme system** with 20+ themes, switchable via CLI
- **Foot terminal** (primary) + Ghostty/Kitty/Alacritty configs
- **Omarchy CLI** for system management (theme, update, apps)
- **Flatpak + Nix** hybrid: Flatpak for GUI apps, Nix for CLI/tools
- **Keybindings:** SUPER as mod, extensive tiling/media/app bindings
- **Waybar** top bar with workspaces, clock, media, tray
- **Rofi** as launcher
- **Dunst** for notifications
- **Gaming-ready:** Steam, Proton-GE, gamescope, mangohud, lact
- **AI integration:** opencode, claude, gemini, copilot
- **Beautiful defaults:** Bibata cursors, Orchis/Papirus themes, JetBrainsMono Nerd Font

## Official reference update

The implementation target is based on the [official Omarchy manual](https://omarchy.org/manual/), not screenshots or third-party dotfiles. The manual emphasizes a cohesive, beautiful Hyprland system built around intentional defaults, switchable themes, curated backgrounds, a CLI-first workflow, and consistent branding across boot unlock, login, screensaver, and desktop surfaces. It also identifies Quickshell as Omarchy's desktop construction kit; this repository will adopt the design principles without replacing the Nix-native Waybar stack prematurely.

For Gaming, the login surface now follows that direction with **graphical SDDM**, a dark Sugar theme, and Hyprland as the default session. The old terminal-greeter experiment is retired because ANSI color tuning cannot provide the same visual hierarchy or branding surface.

---

## Current State vs Target

| Area | Gaming PC (Current) | MacBook (Current) | Omarchy Target | Gap |
|------|---------------------|-------------------|----------------|-----|
| WM | Hyprland (hyprlang) | AeroSpace (i3-style) | Hyprland (Lua-like modular source) | Keep the validated hyprlang output while preserving a future migration path |
| Config format | hyprlang inline | AeroSpace TOML | Lua modules | Both need migration |
| Terminal | foot | Ghostty | foot (primary) | Mac: add foot, keep Ghostty |
| Bar | waybar (top) | sketchybar + borders | waybar | Mac: waybar or sketchybar parity |
| Launcher | wofi | Raycast | rofi | Mac: rofi or keep Raycast |
| Theme | Everforest Blue + dark GTK/Qt | System + custom | Cohesive switchable themes | Extend the canonical palette to every consumer |
| Keybindings | SUPER mod, basic | cmd+ctrl (hyper) | SUPER mod, extensive | Unify to SUPER mod |
| Gaming | Steam, Proton-GE, gamescope | Steam, Crossover, PrismLauncher | Steam, Proton-GE, gamescope | Gaming PC ✅, Mac: add Proton |
| AI tools | hermes-agent | opencode, claude, gemini, copilot | opencode, claude, gemini | Both need opencode |
| Fonts | JetBrainsMono, FiraCode | + VictorMono | JetBrainsMono Nerd Font | Add VictorMono to gaming |
| Notifications | dunst | native | dunst | Mac: add dunst |
| Clipboard | wl-clipboard | native | unified clipboard/history | Add clipboard manager |

---

## Implementation Phases

### Phase 1: Shared Foundation (Both Machines)

**1.1 Theme System**
- Create `modules/shared/themes.nix` with Omarchy theme definitions
- Add `omarchy-theme` CLI tool (theme switcher)
- Support: catppuccin, gruvbox, nord, tokyo-night, kanagawa, rose-pine, everforest, flexoki, matte-black, and more
- Apply GTK, Qt, Hyprland, waybar, rofi, dunst, foot, starship consistently

**1.2 Font Stack**
- Primary: `JetBrainsMono Nerd Font` (both)
- Secondary: `VictorMono Nerd Font` (Mac already has, add to gaming)
- UI: `Inter` or `FiraCode` for monospace alternatives

**1.3 Shell Enhancements (Shared)**
- zsh + starship (already) → enhance with Omarchy-style prompt
- zoxide, fzf, bat, eza, atuin (history), pay-respects
- Aliases: `ls=eza --icons`, `cat=bat`, `cd=z`, `g=git`, `sc=sconnect`

**1.4 Git Config** (already shared) - verify matches Omarchy conventions

---

### Phase 2: Gaming PC (NixOS + Hyprland)

**2.1 Migrate Hyprland Config to Lua Modules**
```
config/hypr/
├── hyprland.lua          # Main entry (like Omarchy)
├── monitors.lua          # Monitor config
├── input.lua             # kb_options = "caps:super", mouse accel flat
├── bindings.lua          # All keybindings (modular)
├── looknfeel.lua         # gaps, borders, blur, rounding, colors
├── autostart.lua         # swaybg, waybar, dunst, apps
└── toggles.lua           # Dynamic toggles (animations, etc.)
```
- Keep `configType = "hyprlang"` in HM but generate from Lua (or switch to Lua via `configFile`)
- Actually: Omarchy uses Lua *at runtime* via `dofile`. NixOS HM expects hyprlang.
- **Decision:** Keep hyprlang in HM, but organize source as Lua-like modules in `modules/nixos/hyprland/` and concatenate

**2.2 Keybindings Expansion (match Omarchy)**
| Binding | Action |
|---------|--------|
| SUPER+Return | Terminal (foot) |
| SUPER+Space | Launcher (wofi → rofi) |
| SUPER+B | Browser (zen-beta) |
| SUPER+E | File manager (thunar or nnn) |
| SUPER+V | Clipboard history |
| SUPER+Shift+E | Exit Hyprland |
| SUPER+F | Fullscreen |
| SUPER+T | Toggle floating |
| SUPER+[1-9] | Workspace |
| SUPER+Shift+[1-9] | Move to workspace |
| SUPER+Arrows | Focus |
| SUPER+Shift+Arrows | Move window |
| SUPER+Ctrl+Arrows | Resize |
| SUPER+Scroll | Workspace switch |
| Media keys | Volume, brightness, media control |
| SUPER+M | Music (rmpc/mpd) |
| SUPER+G | Gaming mode (gamescope) |
| SUPER+S | Screenshot (grim+slurp) |
| SUPER+Shift+S | Screen record |

**2.3 Applications**
- Add: `rofi` (replace wofi), `foot` (primary), `ghostty` (optional), `imv` (image viewer), `mpv` (video)
- Web apps: Discord, Signal, Telegram as native or webapps
- Gaming: `steam`, `proton-ge-bin`, `gamescope`, `gamemode`, `mangohud`, `lact`, `heroic-games-launcher`, `bottles`
- AI: `opencode`, `claude-code`, `gemini-cli`, `copilot-cli`

**2.4 Waybar Enhancement**
- Modules: workspaces, window title, clock, cpu, memory, network, pulseaudio, tray, custom (pacman updates, vpn status)
- Style: match current theme (already good)

**2.5 Dunst Config**
- Position: top-right
- Timeout: 5s
- Actions: buttons for "Open", "Dismiss"
- Match theme colors

**2.6 Rofi Config**
- Theme: match current theme
- Modes: drun, window, ssh, calc, emoji, clipboard (via rofi-greenclip)

**2.7 Clipboard Manager**
- `wl-clipboard` + `cliphist` or `rofi-greenclip` for history

**2.8 Screenshot/Recording**
- `grim` + `slurp` + `swappy` (annotate)
- `wf-recorder` for screen recording
- Binds: SUPER+S (area), SUPER+Shift+S (full), SUPER+Ctrl+S (record)

---

### Phase 3: MacBook (nix-darwin)

**3.1 Window Management**
- **Option A:** Keep AeroSpace + borders (current) — closest to i3/Hyprland on macOS
- **Option B:** Add yabai + skhd (more Hyprland-like)
- **Recommendation:** Keep AeroSpace, enhance to match Omarchy keybindings

**3.2 AeroSpace Config Enhancement**
- Mod: `cmd+ctrl` (hyper) → map to feel like SUPER
- Workspace names: match Omarchy (1-browser, 2-code, 3-term, 4-chat, 5-media, 6-games, 7-docs, 8-sys, 9-vm, 10-misc)
- Layout: tiles default, accordion option
- Gaps: 16px inner/outer
- Floating rules: system prefs, raycast, launchers

**3.3 Terminal**
- Primary: **Ghostty** (already, excellent)
- Add: **foot** via nix (runs on macOS via X11/Wayland? No — foot is Wayland-only)
- Alternative: keep Ghostty, add `wezterm` as backup
- Shell: zsh + starship (already)

**3.4 Bar**
- Keep **sketchybar** (excellent, scriptable)
- Add: workspaces (AeroSpace integration), media, cpu, memory, battery, volume, date
- Style: match theme system

**3.5 Launcher**
- Keep **Raycast** (superior to rofi on macOS)
- Add rofi via nix for consistency? Not needed.

**3.6 Notifications**
- Native macOS (good enough)
- Optional: `dunst` via nix (X11 only)

**3.7 Theme System**
- Apply to: sketchybar, Ghostty, zsh/starship, bat, fzf, nvim
- GTK/Qt not applicable

**3.8 Keybindings (Karabiner-Elements)**
- Caps Lock → Hyper (cmd+ctrl+opt+shift) OR Super (cmd)
- **Recommendation:** Caps Lock → cmd (Left Super equivalent)
- Then AeroSpace uses `cmd+ctrl` as mod → close to SUPER

**3.9 Applications (Homebrew + Nix)**
- Core: `ghostty`, `raycast`, `aerospace`, `borders`, `sketchybar`
- Dev: `opencode`, `claude`, `gemini-cli`, `copilot-cli`, `vscodium`, `zed`, `neovim`
- Media: `iina`, `mpv`, `foobar2000`, `soulseek`, `nicotine-plus`
- Gaming: `steam`, `crossover`, `prismlauncher`, `heroic-games-launcher`
- Utils: `obsidian`, `thunderbird`, `signal`, `discord`, `beeper`, `keepassxc`, `protonvpn`, `tailscale-app`, `lulu`, `oversight`, `knockknock`, `stats`, `betterdisplay`, `calibre`, `gramps`, `tutanota-mail`, `zen`, `tor-browser`
- Fonts: `JetBrainsMono Nerd Font`, `VictorMono Nerd Font`, `FiraCode Nerd Font`, `SF Symbols`

**3.10 AI Tools**
- Add `opencode` (already in brews)
- Add `claude-code` (npm)
- Add `gemini-cli` (npm)
- Add `copilot-cli` (npm)
- Ensure `hermes-agent` works (already)

---

### Phase 4: Shared Tooling & CLI

**4.1 Omarchy-like CLI Tool**
Create `omarchy-cli` (or `tundra-cli`) with:
- `tundra theme <name>` — switch theme
- `tundra rbu` — pull, update flake inputs, and build without activation
- `tundra apps` — list/install applications
- `tundra gaming` — gaming utilities (proton, gamescope, etc.)
- `tundra doctor` — health checks

**4.2 Shared Scripts**
- `refresh-theme.sh` — apply theme to all configs
- `wallpaper.sh` — set wallpaper (swaybg/macOS)
- `fetch-lyrics.py` — already exists

---

### Phase 5: Homelab (mini1, mini2) — Minimal Changes

- Keep headless/server focus
- Add theme-aware fastfetch/motd
- Ensure shared shell/git modules work
- No Hyprland/waybar/rofi needed

---

### Phase 6: Beattie — Minimal Changes

- Keep GNOME showcase
- Apply theme to GTK if possible
- No Hyprland

---

## Migration Strategy

### Gaming PC (Priority 1)
1. Create theme system module
2. Restructure Hyprland config into modular Lua-like files (generate hyprlang)
3. Expand keybindings to match Omarchy
4. Replace wofi → rofi
5. Enhance waybar, dunst
6. Add clipboard manager, screenshot tools
7. Add AI tools (opencode, claude-code)
8. Test on hardware

### MacBook (Priority 2)
1. Apply theme system to sketchybar, Ghostty, starship
2. Enhance AeroSpace keybindings/workspaces
3. Add Karabiner Caps Lock → cmd mapping
4. Add AI tools via Homebrew/Nix
5. Verify all apps themed consistently

---

## Files to Create/Modify

### New Files
```
modules/shared/
├── themes.nix              # Theme definitions + switcher
├── hyprland-keybindings.nix # Shared keybinding definitions (data only)
├── cli-tools.nix           # opencode, claude-code, etc.
└── theme-applicator.sh     # Bash script to apply theme everywhere

modules/nixos/
├── hyprland/
│   ├── monitors.nix
│   ├── input.nix
│   ├── bindings.nix
│   ├── looknfeel.nix
│   ├── autostart.nix
│   └── toggles.nix
├── rofi.nix
├── clipboard.nix
├── screenshot.nix
└── gaming-enhanced.nix     # Extended gaming tools

modules/darwin/
├── aerospace-enhanced.nix  # Enhanced config
├── sketchybar-themes.nix   # Theme-aware sketchybar
├── karabiner-caps.nix      # Caps Lock → cmd
└── macos-apps.nix          # Additional Homebrew apps

hosts/gaming/
├── home.nix                # Updated imports
└── hyprland-config/        # Source Lua-like configs (optional)

hosts/darwin/
├── home.nix                # Updated imports
└── aerospace.toml          # Enhanced (generated or static)
```

### Modified Files
- `flake.nix` — add new modules, ensure unstable packages for latest tools
- `hosts/gaming/configuration.nix` — add new system packages/services
- `hosts/gaming/home.nix` — import new modules, remove wofi, add rofi
- `hosts/darwin/configuration.nix` — add brews/casks
- `hosts/darwin/home.nix` — import new modules
- `modules/shared/shell.nix` — enhance aliases, add atuin
- `modules/shared/fastfetch.nix` — theme-aware

---

## Testing Checklist

### Gaming PC
- [ ] `nix flake check --impure` passes
- [ ] `sudo nixos-rebuild switch --flake .#gaming-pc` succeeds
- [ ] Hyprland starts, keybindings work
- [ ] Waybar shows all modules
- [ ] Rofi launches apps
- [ ] Theme switcher works (GTK, Qt, Hyprland, waybar, rofi, dunst, foot, starship)
- [ ] Steam + Proton-GE runs games
- [ ] gamescope session works
- [ ] mangohud overlays work
- [ ] lact controls GPU
- [ ] Screenshot/recording binds work
- [ ] Clipboard history works
- [ ] AI tools (opencode, claude-code) run

### MacBook
- [ ] `darwin-rebuild switch --flake .#macbook` succeeds
- [ ] AeroSpace starts, workspaces correct
- [ ] Sketchybar shows all modules
- [ ] Theme applied to Ghostty, sketchybar, starship, bat, fzf
- [ ] Karabiner Caps Lock → cmd works
- [ ] AI tools installed and run
- [ ] All Homebrew apps present

---

## Notes & Decisions Needed

1. **Hyprland config format:** Stay with hyprlang in HM (Nix-native) or generate from Lua source? → **Stay hyprlang, organize as modular Nix files**

2. **Theme switching:** Runtime (Omarchy-style) or rebuild? → **Rebuild for system-wide (GTK/Qt), runtime for Hyprland/waybar/rofi/dunst via IPC**

3. **Mac window manager:** Keep AeroSpace or add yabai? → **Keep AeroSpace, enhance**

4. **Foot on Mac?** → **No, Wayland-only. Keep Ghostty primary.**

5. **Rofi on Mac?** → **No, Raycast superior. Skip.**

6. **Flatpak on NixOS?** → **Minimal. Nixpkgs has most things. Flatpak only for proprietary (Discord, Signal, Steam - but Steam in nixpkgs).**

7. **Claude Code / opencode on gaming PC?** → **Yes, via nixpkgs or npm**

8. **VictorMono on gaming PC?** → **Yes, add to fonts.packages**

---

## Rollback Plan

- Each host config is in git — `git revert` or `nixos-rebuild switch --flake .#gaming-pc --rollback`
- Old configs preserved in `home-manager` generations
- Theme system is additive — disable by not importing

---

## Timeline Estimate

| Phase | Effort | Risk |
|-------|--------|------|
| 1: Shared Foundation | 2-3 hrs | Low |
| 2: Gaming PC Hyprland | 4-6 hrs | Medium (hardware test needed) |
| 3: MacBook Enhancement | 2-3 hrs | Low |
| 4: Shared CLI | 1-2 hrs | Low |
| 5-6: Homelab/Beattie | 30 min | Very Low |
| **Total** | **10-15 hrs** | |

---

## Next Steps

1. Review this plan — confirm/modify priorities
2. Start with Phase 1 (themes, shared shell)
3. Phase 2 (gaming PC) — test on hardware
4. Phase 3 (MacBook)
5. Phase 4 (CLI tooling)
