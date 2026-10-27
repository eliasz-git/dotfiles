# tundra-dots

![Tundra banner](docs/branding/tundra-banner-2x1.png)

Merged Nix configuration and standalone dotfiles. This is the single source of truth for the live macOS / NixOS system (managed by nix-darwin via `hosts/` and `modules/`) plus standalone dotfiles (`standalone-dotfiles/`) for apps configured directly rather than through nix-darwin.

Host outputs stay explicit so a build for one machine cannot be mistaken for validation of another.

## Supported outputs

| Role | Output | Desktop or services |
|---|---|---|
| MacBook | `darwinConfigurations.macbook` | AeroSpace, SketchyBar, Ghostty, Homebrew |
| Laptop | `nixosConfigurations.laptop` | Niri + Waybar |
| Desktop | `nixosConfigurations.desktop` | Mango + mangobar + Steam/gaming stack |
| Mini 1 | `nixosConfigurations.mini1` | Headless infrastructure |
| Mini 2 | `nixosConfigurations.mini2` | Headless media services |

Standalone Home Manager fallbacks also exist for `mini1` and `mini2`.

See [the host inventory](docs/HOSTS.md) for architecture, ownership boundaries, hardware guidance, and rollback notes.

## First setup

1. Install Git and Nix with flakes enabled.
2. Clone this repository:

   ```sh
   git clone https://github.com/tundra-node/tundra-dots ~/.config/tundra-dots
   cd ~/.config/tundra-dots
   ```

3. Generate the hardware file on the target NixOS machine when required:

   ```sh
   nixos-generate-config --show-hardware-config > hosts/<host>/hardware-configuration.nix
   ```

   Never copy hardware configuration between hosts. Keep credentials and service `.env` files outside the repository.

4. Evaluate before activation:

   ```sh
   ./scripts/validate.sh --all
   tundra eval <host>
   tundra build <host>
   ```

5. Activate only after reviewing the build:

   ```sh
   tundra switch <host>
   ```

For NixOS installation, use the host output directly, for example `nixos-install --flake .#mini1` or `nixos-install --flake .#desktop`. For macOS, use `darwin-rebuild switch --flake .#macbook` after nix-darwin is installed.

## Daily operations

```sh
tundra doctor                 # read-only environment and output checks
tundra eval desktop           # evaluate without building
tundra build desktop          # build without activation
tundra rb desktop             # pull origin/main, then activate
tundra rb --no-pull desktop   # activate current checkout only
tundra test desktop           # temporary NixOS activation
tundra switch desktop         # activate explicitly
tundra boot desktop           # add a boot generation without switching
tundra rollback desktop       # rollback where supported
tundra rbu desktop            # pull, update lockfile, show diff, build; no activation
```

Host detection is deliberately fail-closed. If you omit a host, the command will refuse to guess unless the local hostname is an exact supported host name. Routine builds never run `nix flake update`.

Read [Validation and operations](docs/VALIDATION.md) for the full safety contract and rollback procedure.

## Themes and wallpapers

Everforest Blue is the current desktop theme selection on the active desktop profiles. The canonical Home Manager palette feeds the Linux desktop consumers, while Darwin and headless hosts keep platform-appropriate consumers.

The wallpaper collection includes public-domain painting sources and attribution notes in [wallpapers/README.md](wallpapers/README.md). List or change wallpapers with:

```sh
./scripts/wallpaper.sh --list
./scripts/wallpaper.sh wallpapers/saal-forest-landscape-moonlight.jpg
```

On the desktop, a daemon rotates the painting set every 15 minutes. The daemon runs one `swaybg` per monitor and hides the wallpaper only on a monitor showing a fullscreen window, so fullscreen media or games on one display leave the other display's wallpaper untouched.

## Screenshots

![tundra CLI help and doctor output](docs/screenshots/terminal.png)

![Six explicit host outputs](docs/screenshots/hosts.png)

![Everforest Blue palette](docs/screenshots/theme.png)

![Wallpaper rotation](docs/screenshots/wallpapers.png)

The terminal panel is drawn from the `tundra` help text and a real `doctor` run, with the longest descriptions shortened to fit. The host, palette, and wallpaper graphics are built from `flake.nix`, `modules/home/themes.nix`, and `wallpapers/`, so they cannot drift from the code.

## Repository layout

- `flake.nix`: explicit system and Home Manager outputs.
- `hosts/`: host-owned hardware, services, and role-specific configuration.
- `modules/shared/`: cross-platform CLI/home modules.
- `modules/home/`: Home Manager-wide options such as the canonical palette.
- `modules/nixos/` and `modules/system/`: Linux/NixOS-only consumers and services.
- `modules/darwin/`: macOS-specific consumers.
- `scripts/`: validation and operational helpers.
- `docs/`: maintained output and operations documentation.
- `docs/screenshots/`: images used in this README.
- `standalone-dotfiles/`: standalone configs for apps managed directly rather than through nix-darwin (sketchybar, karabiner, git, bat, starship, tmux, thefuck, topgrade). These complement `modules/darwin/` and `modules/shared/`.

## CI and contribution contract

CI evaluates all supported outputs and builds Linux system targets without activation. Run `./scripts/validate.sh --all` before opening a change. Keep lockfile updates separate and reviewed, preserve host hardware files, and do not add secrets to Nix source or generated documentation.
