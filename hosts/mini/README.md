# Homelab minis — NixOS headless

> Docs: [`STACKS.md`](./STACKS.md) (what runs where + Compose) · [`BACKUPS.md`](./BACKUPS.md) (gaming PC Restic target + iCloud scope) · [`SECRETS.md`](./SECRETS.md) (sops-nix / .env) · stacks: [`1/stacks/infra/`](./1/stacks/infra/) · [`2/stacks/media/`](./2/stacks/media/)

**Spec (confirmed 16GB each, spare 16GB DDR4 laptop stick optional):**

| host | model | cpu | ram | boot disk | ip (lan) | role |
|------|-------|-----|-----|-----------|----------|------|
| **mini1** | HP ProDesk 600 G1 DM | i3-4160T 2C/4T 3.1GHz Haswell 35W | 16GB DDR3L (max 16GB — spare DDR4 won't fit here) | 256GB SATA SSD | 192.168.1.75 | **infra** |
| **mini2** | HP ProDesk 405 G4 DM | R5 PRO 2400GE 4C/8T + Vega 11 | 16GB DDR4 (max 32GB — spare 16GB stick → 32GB if DDR4) | 256GB NVMe; NFS client of mini1 | 192.168.1.76 | **media** |

Both headless, Tailscale for remote (replaces WireGuard), Docker+Compose for stacks. Mini1 owns the 2TB storage/NAS; mini2 consumes `/mnt/storage` over NFS. The gaming PC is the secondary encrypted backup target; iCloud protects selected personal files. Don't count on spare — configs assume 16GB with 25% zram.

## What changed
- `flake.nix`: added `nixosConfigurations.mini1/mini2` (primary) alongside existing `homeConfigurations.mini1/mini2` (legacy standalone Home Manager fallbacks only).
- `hosts/mini/1/configuration.nix`: headless NixOS for mini1 — NetworkManager + Tailscale, SSH key-only, Docker+Compose, Cockpit :9090, AdGuard Home, NFS/Samba NAS, and mount-aware Home Assistant Compose lifecycle.
- `hosts/mini/2/configuration.nix`: headless NixOS for mini2 — shared headless base + Vega 11 VAAPI (`hardware.graphics`), NFS client mount of mini1's `/mnt/storage`, and Cockpit.
- `hosts/mini/*/hardware-configuration.nix`: placeholders — regenerated on-device via `nixos-generate-config`.
- `hosts/mini/*/home.nix`: now minimal TUI (btop, docker aliases `dps/dcu/dcd/dcl`, `rb/rbu` for nixos-rebuild). mini2 gaming/desktop packages removed.
- `hosts/mini/STACKS.md` + `BACKUPS.md` + `SECRETS.md` + `hosts/mini/*/stacks/*/compose.yaml` — tracked stack definitions, backup runbook, and external-secret guidance. NixOS owns mini1 DNS; do not start the optional Docker AdGuard service at the same time.

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
   # mini2 example — /mnt/storage is an NFS mount from mini1
   mountpoint /mnt/storage
   sudo mkdir -p /etc/stacks/media
   sudo cp -r ~/.config/nix-config/hosts/mini/2/stacks/media/* /etc/stacks/media/
   sudo cp /etc/stacks/media/.env.example /etc/stacks/media/.env; sudo nano /etc/stacks/media/.env  # Mullvad key
   sudo docker compose -f /etc/stacks/media/compose.yaml config
   sudo docker compose -f /etc/stacks/media/compose.yaml up -d
   ```
4. AdGuard is NixOS-managed on mini1; after activation, visit `http://mini1:3000` for its setup UI and configure Unbound (`127.0.0.1:5335`) as the upstream.

## Daily use
```bash
# On either mini, from ~/.config/nix-config
tundra rb   # pull GitHub fast-forward-only, then rebuild the detected mini
tundra rb --no-pull  # rebuild the current checkout without pulling
tundra rbu  # pull, update the flake, and build without activation
# legacy standalone Home Manager fallback only
hms  # home-manager switch --flake .#mini1
```

## Spare 16GB stick
- Check `dmidecode --type memory` — if it's DDR4-3200 SO-DIMM, it fits **mini2 only** (and your ProBook). Pop it in slot 2 → `free -h` should show ~32GB, then lower `zramSwap.memoryPercent = 15` in `hosts/mini/2/configuration.nix`.
- If it's DDR3L, it fits mini1 only but mini1 is already maxed at 16GB (2x8) — no benefit.
- Keep both at 16GB assumption until you test — no config depends on 32GB.

## Storage notes
- mini1: 256GB SSD = OS only. No media mount needed.
- mini2: no authoritative data disk; `/mnt/storage` is an NFS4 automount from mini1 at `192.168.1.75:/mnt/storage`.
- gaming PC: use its existing drive as the encrypted Restic repository first; do not move the boot disk until a replacement and migration plan exist.
- APC Smart-UPS 2200XL: if plugged via USB to mini1, set `services.apcupsd.enable = true` + `configText` in configuration.nix.

## Keeping old behavior
`homeConfigurations.mini1/mini2` remain as legacy standalone Home Manager fallbacks (`home-manager switch --flake .#mini1`). NixOS is the recommended path; the fallback is user-environment-only and does not configure system services.
