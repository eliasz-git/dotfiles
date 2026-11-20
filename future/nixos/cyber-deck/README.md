# Future NixOS config — Portable Cyber Deck

Planned NixOS configuration for the Pi 4 mini-homelab deck (Project Nomad style).

This is a draft. It will replace the Raspberry Pi OS Lite base after the class project is complete, once NixOS on aarch64 is verified for the Pi 4 hardware.

## Planned modules

- `hardware-configuration.nix` — Pi 4 device tree, boot config
- `networking.nix` — dnsmasq, hostapd, nftables, switch, Wi-Fi AP
- `services/docker.nix` — Jellyfin, Navidrome, Internet in a Box
- `services/i2p.nix` — i2pd or Java I2P router
- `services/tor.nix` — Tor daemon (SOCKS proxy)
- `services/command-center.nix` — Custom web UI (Node/TS or Python)
- `users/users.nix` — elias user, SSH keys

## Hardware

- Raspberry Pi 4 (4 GB)
- aarch64-linux
- 5-inch touchscreen (no desktop environment, CLI + web UI)

## Status

Not active. See `~/Developer/portable-cyber-deck/` for the active class project build.