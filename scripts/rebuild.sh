#!/usr/bin/env bash
# Compatibility wrapper. The supported implementation is scripts/tundra-cli.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$SCRIPT_DIR/tundra-cli.sh"

usage() {
  cat <<'EOF'
Usage: scripts/rebuild.sh [OPTIONS] [HOST]

The wrapper delegates to the explicit Tundra CLI:
  (default)  pull origin/main fast-forward-only, then activate the host
  --no-pull  rebuild the current checkout without pulling
  --dry-run  evaluate the selected output without building or activating
  --update   pull, update flake.lock, and build the selected output
  --test     temporary NixOS test activation
  --boot     build and add a NixOS boot generation without switching
  (default)  switch the explicitly selected host

Supported hosts: macbook laptop desktop beattie mini1 mini2
EOF
}

mode=rebuild
host=""
while (($#)); do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -u|--update) mode='update' ;;
    -t|--test) mode='test' ;;
    -b|--boot) mode='boot' ;;
    -d|--dry-run) mode='eval' ;;
    -n|--no-pull|--offline) no_pull=true ;;
    macbook|laptop|desktop|beattie|mini1|mini2) host="$1" ;;
    *) echo "Unknown option or host: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "${no_pull:-false}" == true && "$mode" == rebuild ]]; then
  exec "$CLI" rb --no-pull "$host"
fi
if [[ "$mode" == rebuild ]]; then
  exec "$CLI" rb "$host"
fi
if [[ "${no_pull:-false}" == true && "$mode" == update ]]; then
  exec "$CLI" rbu --no-pull "$host"
fi
if [[ "$mode" == update ]]; then
  exec "$CLI" rbu "$host"
fi
exec "$CLI" "$mode" "$host"
