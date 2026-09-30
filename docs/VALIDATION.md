# Validation and operations contract

## Local validation

Run the read-only gate from the repository root:

```sh
./scripts/validate.sh --all
```

It checks shell syntax, conflict markers, obvious placeholder passwords, and evaluates every flake output with `nix flake check --all-systems --no-build`. `shellcheck`, `nixfmt`, or `alejandra` are used automatically when installed.

The gate does **not** run `nixos-rebuild`, `darwin-rebuild`, activation, profile installation, or garbage collection.

## Host lifecycle

Use the `tundra` command supplied by the host configuration:

```sh
tundra eval <host>      # evaluate the selected output
tundra build <host>     # build without activation
tundra test <host>      # temporary NixOS test activation
tundra switch <host>    # activate the selected host
tundra boot <host>      # add a boot generation without switching now
tundra rollback <host>  # roll back the active system where supported
```

Host names are explicit: `macbook`, `laptop`, `gaming-pc`, `beattie`, `mini1`, and `mini2`. Unknown hostnames fail closed; the tool never silently assumes `gaming-pc`.

Every supported Home Manager profile installs the same `tundra` CLI and aliases:

```text
rb    = tundra switch
rbu   = tundra update
rbb   = tundra build
rbe   = tundra eval
rbt   = tundra test
rbbt  = tundra boot
rbr   = tundra rollback
```

The shared module also provides `ghs`, `ghw`, `ghpr`, and `ghci` for GitHub Actions and pull-request status. CLI equivalents are `tundra github status`, `tundra github watch <run-id>`, and `tundra github pr`.

## Lockfile updates

A normal build does not update inputs. Updating is a reviewed operation:

```sh
tundra update <host>
```

This updates `flake.lock`, shows the changed lockfile, and builds the selected host. It does not activate the result. Review and commit the lockfile separately, then run `tundra switch <host>`.

On the gaming host, the Hyprland wallpaper daemon rotates the painting collection every 15 minutes and stops `swaybg` whenever the active window is fullscreen. It resumes the rotation when fullscreen ends.

## Destructive operations

`nix profile install/remove` and garbage collection are imperative operations outside the host declaration. Prefer adding packages to the appropriate Nix module. Never couple garbage collection to a rebuild, and inspect `tundra doctor` before removing generations.
