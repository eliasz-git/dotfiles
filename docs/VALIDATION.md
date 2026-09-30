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
tundra rb <host>        # pull origin/main fast-forward-only, then activate
tundra rb --no-pull <host>  # activate the current checkout only
tundra rbu <host>       # pull, update flake.lock, and build; no activation
tundra rbu --no-pull <host> # update/build without pulling
tundra boot <host>      # add a boot generation without switching now
tundra rollback <host>  # roll back the active system where supported
```

Host names are explicit: `macbook`, `laptop`, `desktop`, `beattie`, `mini1`, and `mini2`. Unknown hostnames fail closed; the tool never silently assumes `desktop`.

Every supported Home Manager profile installs the same `tundra` CLI and aliases:

```text
rbb   = tundra build
rbe   = tundra eval
rbt   = tundra test
rbbt  = tundra boot
rbr   = tundra rollback
```

There are intentionally no global `rb` or `rbu` shell aliases; use the explicit `tundra rb` and `tundra rbu` commands. Both pull with `git pull --ff-only` by default and refuse to pull over local changes. Add `--no-pull` for offline/local-checkout operation.

The shared module also provides `ghs`, `ghw`, `ghpr`, and `ghci` for GitHub Actions and pull-request status. CLI equivalents are `tundra github status`, `tundra github watch <run-id>`, and `tundra github pr`.

## Lockfile updates

A normal build does not update inputs. Updating is a reviewed operation:

```sh
tundra rbu <host>
```

This updates `flake.lock`, shows the changed lockfile, and builds the selected host. It does not activate the result. Review and commit the lockfile separately, then run `tundra rb <host>`.

On the gaming host, the Hyprland wallpaper daemon rotates the painting collection every 15 minutes and stops `swaybg` whenever the active window is fullscreen. It resumes the rotation when fullscreen ends.

## Destructive operations

`nix profile install/remove` and garbage collection are imperative operations outside the host declaration. Prefer adding packages to the appropriate Nix module. Never couple garbage collection to a rebuild, and inspect `tundra doctor` before removing generations.
