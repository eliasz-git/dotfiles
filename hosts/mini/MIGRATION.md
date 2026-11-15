# mini2 Docker → NixOS-native migration plan

Goal: everything that has a solid NixOS module runs natively (`services.*`),
so host state is reproducible from `~/.config/dotfiles` and survives
`/mnt/storage` incidents (see the Sep 5 2026 data loss). Services with no
module or a hard Docker requirement stay in `hosts/mini/2/stacks/media/compose.yaml`.

Rules for every phase:

1. One service per rebuild. `tundra rb` on mini2, verify, then next.
2. Native service keeps the same port; tailscale serve (`services.tailscaleServe`)
   needs no change.
3. App data stays at `/mnt/storage/appdata/media/<svc>` (NFS from mini1) —
   set `dataDir`/state dirs accordingly. Do not copy data; containers and
   native services can read the same config dirs.
4. Before flipping a service, `docker compose stop <svc>` on mini2 so old and
   new never run at once.
5. Secrets never in git: `HOMEPAGE_VAR_*`-style vars go to
   `/var/lib/secrets/stacks/media.env` (see `stacks/media/.env.example`).

## Phases

| Phase | Service | Target | Status |
|-------|---------|--------|--------|
| 1 | homepage | `services.homepage-dashboard` (port 3000) | **done 2026-11-15** |
| 2 | sonarr | `services.sonarr`, existing dataDir + BindPaths for `/tv` and `/downloads` | **prepared, deploy next** |
| 2b | radarr, lidarr, prowlarr, bazarr | same modules; validate path mappings per app | pending |
| 3 | tautulli, seerr, flaresolverr, recyclarr | `services.tautulli` / `services.seerr` / `services.flaresolverr` / `services.recyclarr` | pending |
| 4 | navidrome | `services.navidrome` + `ND_LASTFM_*` env (env file) | pending |
| 5 | jellyfin | `services.jellyfin`, VAAPI via `hardware.graphics` | pending |
| 6 | immich (server + ML + postgres + redis) | `services.immich` module, `mediaLocation` → `/mnt/storage/photos` | pending — riskiest, do last |
| stay | arm | Docker only (privileged, `/dev/sr0`) | stays |
| stay | rdt-client | Docker only (no module) | stays |
| stay | maintainerr | Docker unless a module exists when phase 3 happens | stays |

## Verification checklist (per service)

```bash
systemctl status <svc>.service
curl -fsS localhost:<port> | head -1
tailscale serve status   # untouched
dps                      # container gone (if migrated)
```

Then check the app UI still sees its library/indexers (config paths are
shared, not copied — nothing to migrate if the dataDir matches the old
bind mount).

## Rollback

Each phase is one git commit. Roll back with `git revert` + `tundra rb`,
or flip the service back to its compose entry and rebuild.
