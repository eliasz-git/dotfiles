# Syncthing folder sync

Syncthing keeps selected folders in sync across the hosts in this repository.
It is declared per host in Nix — never installed ad-hoc — and each host owns
its own folder set and GUI bind address.

## Where it runs

| Host | How it runs | GUI address | Folders declared |
|---|---|---|---|
| Desktop | NixOS system service (`services.syncthing`); systemd user service disabled | `127.0.0.1:8384` | 5 sendreceive folders |
| Mini 1 | NixOS system service (`services.syncthing`); systemd user service disabled | `0.0.0.0:8384` | None; vault sync replaces iCloud on Linux |
| MacBook | macOS launchd agent `xyz.syncthing.agent` (`modules/darwin/syncthing.nix`) | Syncthing default | None declared here |

## Desktop folders (`overrideFolders = true`)

The desktop overrides Syncthing's folder database and declares five
`sendreceive` folders, each with staggered versioning
(`maxAge = "31536000"`, one year) and no pinned devices (`devices = [ ]`),
so devices are accepted through the GUI. These are synced **from the Mac** via
Syncthing; the desktop accepts and applies them on rebuild.
`overrideDevices = false`, so no devices are forced at the Nix layer.

| Folder ID | Label | Path | Type | Versioning |
|---|---|---|---|---|
| `eagle-scout` | Eagle Scout | `/home/elias/Documents/Career/Eagle Scout` | sendreceive | staggered, 1 year |
| `school-docs` | School | `/home/elias/Documents/School` | sendreceive | staggered, 1 year |
| `desktop-sync` | Desktop | `/home/elias/Desktop` | sendreceive | staggered, 1 year |
| `backups-sync` | Backups | `/home/elias/Backups` | sendreceive | staggered, 1 year |
| `genealogy-sync` | Genealogy | `/home/elias/Documents/Genealogy` | sendreceive | staggered, 1 year |

## Ports and access

`openDefaultPorts = true` on both NixOS hosts, so Syncthing's default sync and
discovery ports are open.

- Desktop GUI binds to `127.0.0.1:8384` — local access only. Open it at
  `http://localhost:8384` on the desktop.
- Mini 1 GUI binds to `0.0.0.0:8384` — reachable from other hosts on the
  local network (headless infrastructure).

## macOS (MacBook)

Syncthing is **not** a Homebrew cask on the MacBook; it is the `syncthing`
package from `modules/shared/programs.nix`, run as a launchd agent that starts
at login:

- `RunAtLoad = true`, `KeepAlive = true`, `ProcessType = "Background"`
- `STNOUPGRADE = "1"` so an out-of-band upgrade does not nag
- `STNORESTART = "1"` so a crash-loop does not restart before the log is read
- Logs: `~/Library/Logs/syncthing.log` and `syncthing.err.log` (survive reboot)

The activation script in `modules/darwin/syncthing.nix` clears two stale states
before Home Manager bootstraps the agent: a store-symlinked or missing
`$HOME/Library/LaunchAgents/xyz.syncthing.agent.plist`, and a stray syncthing
process holding the config lock and port 8384. It uses no pipes and no `exit`,
so a failure cannot abort the whole activation under `set -euo pipefail`.

## Hermes agent state

The Hermes Agent (Nous Research) portable state syncs Mac ↔ desktop via
Syncthing, but `state.db` stays local per machine.

## Constraints

- Folder paths are host-specific absolute paths; do not share a folder
  declaration across hosts with different users or layouts.
- Syncthing's `config.xml` is user-owned and not managed by Nix, and `.env`
  files / credentials stay outside the repository — never copy them between
  hosts.
- Do not couple Syncthing restarts to a rebuild; restart the service or agent
  only when intentionally changing the folder set.

## See also

- [Host inventory and ownership boundaries](HOSTS.md)
- [Validation and operations contract](VALIDATION.md)