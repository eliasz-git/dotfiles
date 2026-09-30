#!/usr/bin/env bash
# Validate the repository without activating or mutating any host.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'EOF'
Usage: scripts/validate.sh [--all]

Runs repository hygiene and shell checks, then evaluates every flake output.
--all is accepted for CI readability; evaluation is always all-systems.
This script never runs nixos-rebuild, darwin-rebuild, activation, or garbage collection.
EOF
}

case "${1:-}" in
  ""|--all) ;;
  -h|--help) usage; exit 0 ;;
  *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
esac

printf '%s\n' '== shell syntax =='
mapfile -t shell_files < <(find scripts hosts -type f -name '*.sh' -print | sort)
if ((${#shell_files[@]})); then
  bash -n "${shell_files[@]}"
fi
printf '%s\n' 'shell syntax: ok'

printf '%s\n' '== repository hygiene =='
if git grep -n -I -E '^(<<<<<<<|=======|>>>>>>>)' -- ':!*.jpg' ':!*.png'; then
  echo 'conflict markers found' >&2
  exit 1
fi
if find . -path './.git' -prune -o -path './.manus' -prune -o -type f -print0 | xargs -0 grep -IlE 'password[[:space:]]*=[[:space:]]*"(changeme|password|secret)"' 2>/dev/null; then
  echo 'placeholder password assignment found; review before deployment' >&2
  exit 1
fi
printf '%s\n' 'repository hygiene: ok'

printf '%s\n' '== Nix output evaluation =='
nix flake check --all-systems --no-build
printf '%s\n' 'Nix output evaluation: ok'

if command -v shellcheck >/dev/null 2>&1; then
  printf '%s\n' '== shellcheck =='
  # The maintained operational entry points are gated here. Legacy installers
  # and the old runtime theme adapter are not yet part of the supported path.
  shellcheck scripts/validate.sh scripts/tundra-cli.sh scripts/rebuild.sh scripts/wallpaper-daemon.sh
else
  printf '%s\n' 'shellcheck: not installed (optional locally; CI may provide it)' >&2
fi

if command -v nixfmt >/dev/null 2>&1; then
  printf '%s\n' '== nixfmt check =='
  mapfile -t nix_files < <(find . -path './.git' -prune -o -path './.manus' -prune -o -type f -name '*.nix' -print | sort)
  nixfmt --check "${nix_files[@]}"
elif command -v alejandra >/dev/null 2>&1; then
  printf '%s\n' '== alejandra check =='
  alejandra --check .
else
  printf '%s\n' 'Nix formatter: not installed (optional locally; CI should pin one)' >&2
fi

printf '%s\n' 'Validation complete.'
