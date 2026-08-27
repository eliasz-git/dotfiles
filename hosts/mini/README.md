# Homelab minis — NixOS headless

> Docs: [`STACKS.md`](./STACKS.md) (what runs where + compose) · [`SECRETS.md`](./SECRETS.md) (sops-nix / .env) · stacks: [`1/stacks/infra/`](./1/stacks/infra/) · [`2/stacks/media/`](./2/stacks/media/)

**Spec (confirmed 16GB each, spare 16GB DDR4 laptop stick optional):**

| host | model | cpu | ram | boot disk | ip (lan) | role |
|------|-------|-----|-----|-----------|----------|------|
| **mini1** | HP ProDesk 600 G1 DM | i3-4160T 2C/4T 3.1GHz Haswell 35W | 16GB DDR3L (max 16GB — spare DDR4 won't fit here) | 256GB SATA SSD | 192.168.1.75 | **infra** |
| **mini2** | HP ProDesk 405 G4 DM | R5 PRO 2400GE 4C/8T + Vega 11 | 16GB DDR4 (max 32GB — spare 16GB stick → 32GB if DDR4) | 256GB NVMe + 2TB external at `/mnt/storage` | 192.168.1.76 | **media** |

Both headless, Tailscale for remote (replaces WireGuard), Docker+compose for stacks. Don't count on spare — configs assume 16GB with 25% zram.

## What changed
- `flake.nix`: added `nixosConfigurations.mini1/mini2` (primary) alongside existing `homeConfigurations.mini1/mini2` (fallback for Alpine/Artix home-manager only).
- `hosts/mini/1/configuration.nix`: headless NixOS for mini1 — NetworkManager + Tailscale, SSH key-only, Docker+compose, Cockpit :9090, AdGuard Home (disabled until first-boot setup), Caddy (disabled), firewall, zram.
- `hosts/mini/2/configuration.nix`: headless NixOS for mini2 — same base + Vega 11 VAAPI (`hardware.graphics`), `services.jellyfin` stub, `/mnt/storage` automount for 2TB drive, Cockpit.
- `hosts/mini/*/hardware-configuration.nix`: placeholders — regenerated on-device via `nixos-generate-config`.
- `hosts/mini/*/home.nix`: now minimal TUI (btop, docker aliases `dps/dcu/dcd/dcl`, `rb/rbu` for nixos-rebuild). mini2 gaming/desktop packages removed.
- `hosts/mini/STACKS.md` + `SECRETS.md` + `hosts/mini/*/stacks/*/compose.yaml` — ready-to-deploy compose templates (infra AdGuard/kuma, media *arr+Jellyfin via gluetun).

## Docker vs Podman
You asked. **Docker** = most tutorials, linuxserver.io images, gluetun docs, Portainer — just works. **Podman** = daemonless, rootless, more Nix-native but needs `podman-docker` shim and compose compat fixes for gluetun. For a homelab you want to google and paste, Docker wins. We enabled `virtualisation.docker` on both. Flip to podman later by swapping `virtualisation.podman.enable = true; dockerCompat = true;`.

## First boot — fresh NixOS USB
1. Flash NixOS 25.05 minimal ISO, boot mini, then:
   ```bash
   git clone https://github.com/tundra-node/nix-config ~/.config/nix-config
   nixos-generate-config --show-hardware-config > ~/.config/nix-config/hosts/mini/1/hardware-configuration.nix  # or 2
   # edit authorizedKeys in configuration.nix, wifi if needed
   sudo nixos-install --flake ~/.config/nix-config#mini1   # or #mini2
   reboot
   ```
2. `sudo tailscale up` (paste auth or login via browser), `tailscale status` should show both minis on 100.x.y.z.
3. Deploy stacks (see [`STACKS.md`](./STACKS.md)):
   ```bash
   # mini2 example
   sudo mkdir -p /etc/stacks/media
   sudo cp -r ~/.config/nix-config/hosts/mini/2/stacks/media/* /etc/stacks/media/
   sudo cp /etc/stacks/media/.env.example /etc/stacks/media/.env; sudo nano /etc/stacks/media/.env  # Mullvad key
   sudo chown -R 1000:1000 /mnt/storage/media
   sudo docker compose -f /etc/stacks/media/compose.yaml up -d
   ```
4. If AdGuard desired on mini1: set `services.adguardhome.enable = true;` then `rb` and visit `http://mini1:3000`, upstream `1.1.1.1` or Unbound.

## Daily use
```bash
# On either mini, from ~/.config/nix-config
rb   # sudo nixos-rebuild switch --flake .#mini1 (or mini2 per host)
rbu  # flake update + rebuild
# fallback home-manager only (if you boot Alpine/Artix instead)
hms  # home-manager switch --flake .#mini1
```

## Spare 16GB stick
- Check `dmidecode --type memory` — if it's DDR4-3200 SO-DIMM, it fits **mini2 only** (and your ProBook). Pop it in slot 2 → `free -h` should show ~32GB, then lower `zramSwap.memoryPercent = 15` in `hosts/mini/2/configuration.nix`.
- If it's DDR3L, it fits mini1 only but mini1 is already maxed at 16GB (2x8) — no benefit.
- Keep both at 16GB assumption until you test — no config depends on 32GB.

## Storage notes
- mini1: 256GB SSD = OS only. No media mount needed.
- mini2: 2TB external — format ext4 (`mkfs.ext4 -L STORAGE /dev/sdX`) for best NixOS automount. If NTFS, `ntfs3` will mount but permissions get messy — migrate to ext4 when you can.
- APC Smart-UPS 2200XL: if plugged via USB to mini1, set `services.apcupsd.enable = true` + `configText` in configuration.nix.

## Keeping old behavior
`homeConfigurations.mini1/mini2` still exist for Alpine/Artix (`home-manager switch --flake .#mini1`). NixOS is now the recommended path — both use the same `home.nix` so your shell stays consistent.
