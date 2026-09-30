# Stacks — what runs where

Source of truth for Docker Compose stacks on the two headless minis. Templates live in `hosts/mini/*/stacks/` (tracked), deployed to `/etc/stacks/` on each host via a symlink or `systemd` service.

## Topology

```
Internet
  └─ Deco mesh (192.168.1.1) + DGS-1005G switch
      ├─ mini1 (192.168.1.75) — infra + NAS — 256GB SSD + 2TB STORAGE — always-on
      │  └─ /mnt/storage/media/{downloads,tv,movies,music,photos}
      ├─ mini2 (192.168.1.76) — media — 256GB NVMe — NFS client of mini1
      └─ desktop — encrypted Restic backup repository; boot disk stays in place
  Tailscale tailnet (100.x.y.z) — no port forwarding, `tailscale up` on both
```

## mini1 — infra (Haswell, no transcode)

| stack | compose | ports | notes |
|-------|---------|-------|-------|
| `infra` | `hosts/mini/1/stacks/infra/compose.yaml` | 3000 adguard setup, 53 dns, 9090 cockpit | NixOS owns AdGuard/Unbound; do not start the Docker AdGuard service at the same time. |
| optional | `caddy` | 80/443 | Only if you want `https://mini1.your-tailnet.ts.net` via Tailscale certs. |
| optional | `uptime-kuma` | 3001 | Uptime monitor for both minis + Deco. |

Deploy (only for services not already owned by NixOS):
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

### Storage layout (on mini1's 2TB ext4 disk, exported to mini2 over NFS)

```
/mnt/storage/              # mini1 local ext4, label=STORAGE; mini2 mounts mini1:/mnt/storage via NFS4
├── media/
│   ├── downloads/         # transmission
│   ├── tv/                # sonarr
│   ├── movies/            # radarr
│   ├── music/             # navidrome
│   └── photos/            # immich
└── backups/               # optional — mini1 can rsync here
```

Format once on mini1 only if needed: `sudo mkfs.ext4 -L STORAGE /dev/sdX` (check `lsblk`). Do not format mini2 for this storage; its `/mnt/storage` is an NFS4 mount from `192.168.1.75`.

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
# on mini2, after NixOS install and after confirming /mnt/storage is mounted from mini1
mountpoint /mnt/storage
sudo install -d -m 0700 /var/lib/secrets/stacks
sudo install -m 0600 hosts/mini/2/stacks/media/.env.example /var/lib/secrets/stacks/media.env
sudoedit /var/lib/secrets/stacks/media.env  # fill Mullvad + Immich DB password

# NixOS installs the tracked Compose file and validates it before starting.
sudo systemctl start homelab-compose-media
sudo docker ps
```

### Existing mini2 data migration

The managed Compose file now stores service state under `/mnt/storage/appdata/media`, not relative to `/etc/stacks/media`. Before starting the managed unit on an existing installation, stop the old stack and copy its state while `/mnt/storage` is mounted:

```bash
sudo docker compose -f /etc/stacks/media/compose.yaml down || true
sudo rsync -aHAX --numeric-ids /etc/stacks/media/data/ /mnt/storage/appdata/media/
sudo systemctl start homelab-compose-media
```

Review the resulting containers and logs before deleting the old local `/etc/stacks/media/data` copy. The migration is intentionally not automatic.

Update: `sudo systemctl restart homelab-compose-media` after reviewing changes. Pull images explicitly with `sudo docker compose -f /etc/stacks/media/compose.yaml pull` when desired.

## Secrets

See `SECRETS.md` for sops-nix (optional). The active media secret is `/var/lib/secrets/stacks/media.env`, outside Git and mode `0600`. Never commit it.

## Logs / debug

```bash
dps                        # docker ps (alias in home.nix)
dcl                        # docker compose logs -f
docker compose -f /etc/stacks/media/compose.yaml logs -f gluetun
docker exec -it jellyfin bash
vainfo; ls -l /dev/dri/
```
