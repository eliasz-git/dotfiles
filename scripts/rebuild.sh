#!/usr/bin/env bash
# Compatibility wrapper. The supported implementation is scripts/tundra-cli.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$SCRIPT_DIR/tundra-cli.sh"

usage() {
  cat <<'EOF'
Usage: scripts/rebuild.sh [OPTIONS] [HOST]

The wrapper delegates to the explicit Tundra CLI:
  --dry-run  evaluate the selected output without building or activating
  --update   update flake.lock and build the selected output, without activation
  --test     temporary NixOS test activation
  --boot     build and add a NixOS boot generation without switching
  (default)  switch the explicitly selected host

Supported hosts: macbook laptop gaming-pc beattie mini1 mini2
EOF
}

mode=switch
host=""
while (($#)); do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -u|--update) mode='update' ;;
    -t|--test) mode='test' ;;
    -b|--boot) mode='boot' ;;
    -d|--dry-run) mode='eval' ;;
    macbook|laptop|gaming-pc|beattie|mini1|mini2) host="$1" ;;
    *) echo "Unknown option or host: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

exec "$CLI" "$mode" "$host"
