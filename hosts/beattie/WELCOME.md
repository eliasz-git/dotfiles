# Welcome to Beattie — KDE Plasma 6 Showcase

You are on **beattie**, a NixOS workstation running **KDE Plasma 6 on Wayland**, with SDDM, PipeWire, Flatpak, and a cybersecurity lab toolkit.

> Full guide: open **Beattie Wiki** or `hosts/beattie/WIKI.md`.

## Getting around

- **Meta/Super** opens KDE search; start typing an application name.
- **Alt+Tab** switches windows.
- **Meta+Tab** switches tasks/workspaces.
- Use the **panel** for favorites, notifications, network, sound, and power.
- Open **System Settings** to configure appearance, displays, keyboard, and touchpad.

## Installed essentials

- **Dolphin**, **Konsole**, **Kate**, **Spectacle**, **Okular**, **Gwenview**, and **Discover**
- LibreWolf, Brave, VSCodium, Obsidian, LibreOffice, VLC, Celluloid, GIMP, and Inkscape
- Docker, Wireshark, Nmap, Burp Suite, Ghidra, Metasploit, John, Hashcat, and forensic tools
- `tldr`, `eza`, `bat`, `fzf`, `zoxide`, `btop`, and `fastfetch`

## Terminal starters

```bash
fastfetch
tldr ls
eza --icons
btop
cowsay "I use NixOS btw" | lolcat
```

The shared Nix lifecycle aliases are consistent across hosts:

```text
rb    = tundra switch       # activate after review
rbu   = tundra update       # update lockfile + build; no activation
rbb   = tundra build        # build only
rbe   = tundra eval         # evaluate only
rbt   = tundra test         # temporary NixOS activation
rbbt  = tundra boot         # add boot generation without switching
rbr   = tundra rollback
```

## Appearance and wallpapers

- **Appearance:** System Settings → Colors & Themes → choose a dark Breeze variant.
- **Icons:** Papirus-Dark.
- **Cursor:** Bibata-Modern-Classic.
- **Wallpaper:** choose a painting from `~/.config/nix-config/wallpapers`.

## NixOS lifecycle

Beattie is one flake output: `nixosConfigurations.beattie`.

```bash
./scripts/validate.sh --all
./scripts/tundra-cli.sh eval beattie
./scripts/tundra-cli.sh build beattie
./scripts/tundra-cli.sh switch beattie
```

The actual hardware file belongs on the machine at `hosts/beattie/hardware-configuration.nix`; the checked-in `.example` is only an evaluation fallback. Before installing on new hardware, generate a real file with `nixos-generate-config`.

Rollback by selecting an older systemd-boot generation or running:

```bash
sudo nixos-rebuild switch --rollback
```

## Safety

The demo account is intentionally permissive for a showcase/lab machine. For a personal or network-exposed installation, replace the initial passwords with hashed passwords, remove broad sudo access, and do not scan networks without permission.
