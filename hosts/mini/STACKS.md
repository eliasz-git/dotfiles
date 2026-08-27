# Stacks — what runs where

Source of truth for Docker Compose stacks on the two headless minis. Templates live in `hosts/mini/*/stacks/` (tracked), deployed to `/etc/stacks/` on each host via a symlink or `systemd` service.

## Topology

```
Internet
  └─ Deco mesh (192.168.1.1) + DGS-1005G switch
      ├─ mini1 (192.168.1.75) — infra — 256GB SSD — always-on
      └─ mini2 (192.168.1.76) — media — 256GB NVMe + 2TB /mnt/storage — Tailscale exit optional
         └─ 2TB ext (STORAGE) → /mnt/storage/media/{downloads,tv,movies,music,photos}
  Tailscale tailnet (100.x.y.z) — no port forwarding, `tailscale up` on both
```

## mini1 — infra (Haswell, no transcode)

| stack | compose | ports | notes |
|-------|---------|-------|-------|
| `infra` | `hosts/mini/1/stacks/infra/compose.yaml` | 3000 adguard setup, 53 dns, 9090 cockpit | NixOS also has `services.adguardhome` + `services.caddy` natively — pick **one**. Template uses Docker so you can keep it without rebuilding. |
| optional | `caddy` | 80/443 | Only if you want `https://mini1.your-tailnet.ts.net` via Tailscale certs. |
| optional | `uptime-kuma` | 3001 | Uptime monitor for both minis + Deco. |

Deploy:
```bash
sudo mkdir -p /etc/stacks/infra
sudo ln -sf ~/.config/nix-config/hosts/mini/1/stacks/infra/compose.yaml /etc/stacks/infra/compose.yaml
sudo docker compose -f /etc/stacks/infra/compose.yaml up -d
# or enable the systemd unit in configuration.nix (commented example)
```

If you use Nix-native AdGuard (`services.adguardhome.enable = true`), don't run the Docker one — they'll fight on :53.

## mini2 — media (Vega 11 VAAPI)

| stack | compose | ports | via gluetun? |
|-------|---------|-------|--------------|
| `media` | `hosts/mini/2/stacks/media/compose.yaml` | 8096 jellyfin, 2283 immich, 4533 navidrome, 9696 prowlarr, 8989 sonarr, 7878 radarr, 5055 jellyseerr, 9091 transmission | transmission (+ optionally prowlarr/sonarr/radarr) behind gluetun |
| `jellyfin` | same file, `jellyfin` service | 8096/8920 | no — direct LAN+Tailscale, VAAPI `/dev/dri/renderD128` |

Both paths are valid:
- **Native Jellyfin** (`services.jellyfin.enable = true` in `configuration.nix`) — simplest, VAAPI works out of the box, no compose.
- **Docker Jellyfin** (in compose) — keeps everything in one file if you prefer.

Template defaults to Docker Jellyfin so the whole `*arr`+Jellyfin can be `docker compose up -d` without a rebuild. Flip the Nix toggle and comment out the Docker `jellyfin` service if you want native.

### VAAPI check (Vega 11)
```bash
vainfo  # should show VAEntrypointVLD for H264/HEVC
docker exec jellyfin vainfo  # inside container
# Jellyfin → Admin → Playback → Hardware acceleration: VAAPI, device /dev/dri/renderD128
```

### Storage layout (on 2TB ext)

```
/mnt/storage/              # ext4, label=STORAGE, x-systemd.automount
├── media/
│   ├── downloads/         # transmission
│   ├── tv/                # sonarr
│   ├── movies/            # radarr
│   ├── music/             # navidrome
│   └── photos/            # immich
└── backups/               # optional — mini1 can rsync here
```

Format once: `sudo mkfs.ext4 -L STORAGE /dev/sdX` (check `lsblk`). If it's NTFS now, `ntfs3` mounts read-write but permissions are messy — migrate to ext4 when you can.

### Gluetun + Mullvad

Template expects `hosts/mini/2/stacks/media/.env` (gitignored):

```env
VPN_SERVICE_PROVIDER=mullvad
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=your_mullvad_private_key
WIREGUARD_ADDRESSES=10.x.y.z/32
SERVER_CITIES=Stockholm
```

Get the key from Mullvad → WireGuard configuration → generate key. `SERVER_CITIES` can be any Mullvad city.

### Quick start

```bash
# on mini2, after NixOS install
sudo mkdir -p /etc/stacks/media
sudo cp -r ~/.config/nix-config/hosts/mini/2/stacks/media /etc/stacks/media
# create .env from .env.example
sudo cp /etc/stacks/media/.env.example /etc/stacks/media/.env
sudo nano /etc/stacks/media/.env  # fill Mullvad key

# fix perms for linuxserver images (PUID/PGID=1000 = elias)
sudo chown -R 1000:1000 /mnt/storage/media

sudo docker compose -f /etc/stacks/media/compose.yaml up -d
sudo docker ps
```

Update: `sudo docker compose -f /etc/stacks/media/compose.yaml pull && up -d`

## Secrets

See `SECRETS.md` for sops-nix (optional). For now, `.env` files are the simplest and are already `.gitignore`'d (`hosts/mini/*/.env` + `hosts/mini/*/stacks/*/.env`). Don't commit them.

## Logs / debug

```bash
dps                        # docker ps (alias in home.nix)
dcl                        # docker compose logs -f
docker compose -f /etc/stacks/media/compose.yaml logs -f gluetun
docker exec -it jellyfin bash
vainfo; ls -l /dev/dri/
```
