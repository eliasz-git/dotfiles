# Supported hosts and outputs

This repository keeps host outputs explicit. A successful evaluation of one host does not validate another host.

| Host | Flake output | System | Role | Desktop | Primary command |
|---|---|---|---|---|---|
| MacBook | `darwinConfigurations.macbook` | `aarch64-darwin` | Personal macOS workstation | AeroSpace, SketchyBar, Ghostty | `tundra switch macbook` |
| Laptop | `nixosConfigurations.laptop` | `x86_64-linux` | NixOS laptop | Niri + Waybar | `tundra switch laptop` |
| Desktop | `nixosConfigurations.desktop` | `x86_64-linux` | Desktop and gaming | Hyprland + Waybar; rotating painting wallpaper hidden during fullscreen | `tundra switch desktop` |
| Beattie | `nixosConfigurations.beattie` | `x86_64-linux` | Showcase and lab workstation | GNOME/KDE configuration owned by host files | `tundra switch beattie` |
| Mini 1 | `nixosConfigurations.mini1` | `x86_64-linux` | Headless infrastructure | None | `tundra switch mini1` |
| Mini 2 | `nixosConfigurations.mini2` | `x86_64-linux` | Headless media services | None | `tundra switch mini2` |

Standalone Home Manager outputs remain available for the minis:

- `homeConfigurations.mini1`
- `homeConfigurations.mini2`

They are fallback/user-environment outputs, not replacements for the NixOS system outputs.

`hosts/alpine/` is retained as legacy material but has no flake output. It is not part of the supported output matrix or CI gate.

## Ownership boundaries

- `modules/shared/`: CLI and cross-platform Home Manager programs only.
- `modules/home/`: Home Manager-wide options and generated user theme data.
- `modules/nixos/`: Linux desktop and NixOS-only Home Manager consumers.
- `modules/system/`: NixOS system-level options and services.
- `modules/darwin/`: nix-darwin and macOS-specific Home Manager consumers.
- `hosts/<name>/`: host hardware, services, role-specific packages, and host selection.

The minis intentionally do not import Hyprland, Waybar, Rofi, or other desktop modules. The desktop owns Hyprland and gaming services. The MacBook owns AeroSpace/SketchyBar/Ghostty rather than Linux desktop components.

## Hardware and secrets

Hardware files belong to their host. `*.example` files are placeholders and must not be copied between machines. Keep passwords, API keys, Tailscale credentials, and media-service `.env` files outside Nix source; use the documented secret or deployment path for each host.

## Rollback

Before activation, prefer `tundra build <host>` or `tundra eval <host>`. On NixOS, use:

```sh
sudo nixos-rebuild switch --rollback
```

For a failed boot, select an earlier generation in the systemd-boot menu. On macOS, retain the previous nix-darwin generation and use the host's `darwin-rebuild` rollback path if needed.
