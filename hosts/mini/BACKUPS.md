# Homelab backups

## Topology

- **Primary:** mini1 `/mnt/storage`.
- **Secondary:** encrypted Restic repository on the gaming PC's existing drive.
- **Selective tertiary:** iCloud for photos, documents, and exported recovery material.

The gaming PC's current boot drive stays in the gaming PC. Do not move it as part of the first backup implementation.

The gaming PC is not a runtime dependency for mini1 or mini2. If it is powered off, the minis continue operating and the next backup reports a failure.

## Backup scope

Back up first:

- NixOS configuration and hardware notes
- Compose definitions and stack metadata
- Home Assistant configuration
- Paperless and Immich databases/metadata
- Photos and personal documents
- Music that would be difficult to replace
- Secret metadata and recovery documentation

Exclude by default:

- container images and caches
- temporary downloads
- downloaded movies and TV that can be re-acquired
- transcoding caches

## Initial gaming-PC setup

1. Measure free space on the gaming-PC destination. Do not attempt to mirror the full 2 TB disk onto a smaller destination.
2. Create a restricted account or endpoint that can write only to the Restic repository, for example:
   ```text
   homelab-backup@gaming-pc:/srv/backups/homelab-restic
   ```
3. Use a dedicated SSH key from mini1. Restrict the key on the gaming PC where practical; do not reuse the interactive login key.
4. Create the root-only password file on mini1:
   ```sh
   sudo install -d -m 0700 /var/lib/homelab-backup
   sudo sh -c 'umask 077; read -r -s -p "Restic password: " p; printf "\\n"; printf "%s" "$p" > /var/lib/homelab-backup/restic-password'
   ```
5. Initialize the repository once from mini1 using the final SSH destination:
   ```sh
   sudo restic -r sftp:homelab-backup@gaming-pc:/srv/backups/homelab-restic \
     --password-file /var/lib/homelab-backup/restic-password init
   ```
6. Set `services.homelabBackup.enable = true` in `hosts/mini/1/configuration.nix`, evaluate/build mini1, and activate only after reviewing the result.

Do not put the Restic password, private SSH key, Mullvad key, or app secrets in Git or the Nix store.

## Retention and verification

The NixOS module uses an initial policy of:

- 7 daily snapshots
- 4 weekly snapshots
- 6 monthly snapshots

Verify the repository after the first backup and schedule regular restore tests. A backup is not considered operational until at least one Home Assistant or database-backed restore succeeds.

## iCloud

Use iCloud separately for selected personal files, photos, documents, and exported recovery notes. It is not the primary Linux server backup repository and should not be treated as a replacement for the encrypted Restic repository.
