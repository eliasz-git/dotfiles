# Contributing to dotfiles

Thank you for considering a contribution to this Nix configuration repository!

## Before You Start

1. **Read the [README](../README.md)** for the repository overview, supported hosts, and architecture.
2. **Check [DEPRECATED.md](../DEPRECATED.md)** before adding any package — purged or abandoned projects must not be re-added.
3. **Read [VALIDATION.md](./VALIDATION.md)** for the safety contract, rollback procedure, and pre-change validation steps.
4. **Read [HOSTS.md](./HOSTS.md)** for host inventory, ownership boundaries, and hardware guidance.

## Package Additions

All packages must meet the following criteria:

- **100% FOSS license** (MIT, GPL, Apache 2.0, BSD, etc.)
- **Actively maintained** — recent releases/commits (within ~2 years)
- **Available in nixpkgs** with first-class support
- **Not listed in DEPRECATED.md**

To add a package:

1. Add it to the appropriate `home.packages` or `environment.systemPackages` list in the relevant host/module file.
2. Prefer Home Manager (`home.packages`) for user-facing tools; reserve `environment.systemPackages` for system utilities, drivers, and daemons.
3. Run `./scripts/validate.sh --all` to verify clean evaluation.
4. Run `nix flake check`, `deadnix`, and `statix check` locally.
5. Commit with a conventional message (e.g., `feat:`, `fix:`, `refactor:`).

## Code Style

- Nix code is formatted with **alejandra** and linted with **statix**.
- Shell scripts use `shellcheck`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).
- Keep lockfile updates in separate commits from feature changes.

## CI Pipeline

Every push and pull request runs [`.github/workflows/nix-ci.yml`](../.github/workflows/nix-ci.yml):

1. `nix flake check --accept-flake-config`
2. `deadnix` — dead code detection
3. `statix check` — anti-pattern linting
4. NixOS system builds (laptop, mini1, mini2, desktop)
5. Home Manager builds (mini1, mini2)
6. Darwin evaluation (macbook)

CI runs on GitHub Actions using the Determinate Systems Nix installer with magic-nix-cache.

## Secrets

Never commit secrets, `.env` files, or credentials to the repository. Secrets are managed via [agenix](https://github.com/ryantm/agenix) and stored in `secrets/` (encrypted with `age`).

## Questions

Open an issue on [Codeberg](https://codeberg.org/eliasz/dotfiles/issues) for questions or discussion.
