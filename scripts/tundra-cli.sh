#!/usr/bin/env bash
# tundra-cli — explicit Nix configuration operations
# Usage: tundra <command> [args...]

set -euo pipefail

VERSION="0.3.0"
CONFIG_DIR="${HOME}/.config/tundra"
if [[ -n "${TUNDRA_NIX_CONFIG_DIR:-}" ]]; then
  NIX_CONFIG_DIR="$TUNDRA_NIX_CONFIG_DIR"
elif [[ -f "${HOME}/.config/nix-config/flake.nix" ]]; then
  NIX_CONFIG_DIR="${HOME}/.config/nix-config"
elif [[ -f /etc/nixos/flake.nix ]]; then
  NIX_CONFIG_DIR="/etc/nixos"
else
  NIX_CONFIG_DIR="${HOME}/.config/nix-config"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage_host() {
  echo "Hosts: macbook, laptop, gaming-pc, beattie, mini1, mini2" >&2
}

host_kind() {
  case "$1" in
    macbook) echo darwin ;;
    laptop|gaming-pc|beattie|mini1|mini2) echo nixos ;;
    *) return 1 ;;
  esac
}

resolve_host() {
  local requested="${1:-}"
  if [[ -n "$requested" ]]; then
    if ! host_kind "$requested" >/dev/null; then
      log_error "Unknown host: $requested"
      usage_host
      return 2
    fi
    printf '%s\n' "$requested"
    return 0
  fi

  local machine
  machine="$(hostname -s 2>/dev/null || hostname)"
  case "$(uname -s)" in
    Darwin) [[ "$machine" == "macbook" ]] && printf '%s\n' macbook && return 0 ;;
    Linux)
      case "$machine" in
        laptop|gaming-pc|beattie|mini1|mini2) printf '%s\n' "$machine"; return 0 ;;
      esac
      ;;
  esac

  log_error "Host is ambiguous; refusing to guess from hostname '$machine'."
  echo "Specify one explicitly:" >&2
  usage_host
  return 2
}

flake_attr() {
  local host="$1" kind
  kind="$(host_kind "$host")"
  if [[ "$kind" == darwin ]]; then
    printf '%s\n' ".#darwinConfigurations.${host}.system"
  else
    printf '%s\n' ".#nixosConfigurations.${host}.config.system.build.toplevel"
  fi
}

require_repo() {
  if [[ ! -f "$NIX_CONFIG_DIR/flake.nix" ]]; then
    log_error "flake.nix not found at $NIX_CONFIG_DIR"
    exit 1
  fi
  cd "$NIX_CONFIG_DIR"
}

cmd_theme() {
  case "${1:-current}" in
    current)
      if [[ -f "$CONFIG_DIR/theme" ]]; then cat "$CONFIG_DIR/theme"; else echo "everforest-blue"; fi
      ;;
    list|ls)
      cat <<'EOF'
Available declared themes:
  catppuccin-mocha
  everforest-blue

Theme selection is declarative. Set tundra.theme in the host's Nix configuration,
then run `tundra build <host>` and `tundra switch <host>`.
EOF
      ;;
    set)
      log_error "Runtime theme mutation is disabled; it would diverge from Nix."
      echo "Edit tundra.theme in the intended host configuration instead." >&2
      exit 2
      ;;
    *)
      log_error "Unknown theme command: $1"
      echo "Usage: tundra theme [current|list]" >&2
      exit 2
      ;;
  esac
}

cmd_eval() {
  local host attr
  host="$(resolve_host "${1:-}")"
  attr="$(flake_attr "$host").drvPath"
  require_repo
  log_info "Evaluating $host (no build or activation)..."
  nix eval --raw "$attr"
}

cmd_build() {
  local host attr
  host="$(resolve_host "${1:-}")"
  attr="$(flake_attr "$host")"
  require_repo
  log_info "Building $host without activation..."
  nix build --no-link "$attr"
  log_success "Build completed for $host"
}

cmd_system_action() {
  local action="$1" host kind success_message="${3:-}"
  host="$(resolve_host "${2:-}")"
  kind="$(host_kind "$host")"
  require_repo

  if [[ "$action" == test || "$action" == boot ]] && [[ "$kind" == darwin ]]; then
    log_error "$action is only supported for NixOS hosts"
    exit 2
  fi

  case "$kind" in
    darwin)
      log_info "Running darwin-rebuild $action for $host (activation may change macOS)..."
      sudo darwin-rebuild "$action" --flake "$NIX_CONFIG_DIR#$host"
      ;;
    nixos)
      log_info "Running nixos-rebuild $action for $host (activation may change the host)..."
      sudo nixos-rebuild "$action" --flake "$NIX_CONFIG_DIR#$host"
      ;;
  esac
  # Reached only when the rebuild exited 0: the script runs under
  # `set -e`, so a failed activation never prints a success line. That matters
  # because an activation failure can be otherwise silent — Home Manager
  # aborts mid-script with no message when an entry trips `set -e`.
  [[ -n "$success_message" ]] || success_message="$action completed for $host"
  log_success "$success_message"
}

cmd_rebuild() {
  local host="" pull=true argument
  while (($#)); do
    argument="$1"
    case "$argument" in
      --no-pull|--offline) pull=false ;;
      macbook|laptop|gaming-pc|beattie|mini1|mini2) host="$argument" ;;
      *) log_error "Unknown rebuild option or host: $argument"; echo "Usage: tundra rb [--no-pull|--offline] [host]" >&2; exit 2 ;;
    esac
    shift
  done

  host="$(resolve_host "$host")"
  require_repo
  if [[ "$pull" == true ]]; then
    if [[ -n "$(git status --porcelain)" ]]; then
      log_error "Refusing to pull with local changes in $NIX_CONFIG_DIR"
      echo "Commit or stash them, or rerun as: tundra rb --no-pull $host" >&2
      exit 1
    fi
    log_info "Pulling latest GitHub revision before rebuilding..."
    git pull --ff-only
  else
    log_warn "Skipping GitHub pull; rebuilding the current checkout"
  fi

  cmd_system_action switch "$host" "$host rebuilt successfully"
}

cmd_rollback() {
  local host kind
  host="$(resolve_host "${1:-}")"
  kind="$(host_kind "$host")"
  require_repo
  log_warn "Rolling back $host. This changes the active system generation."
  if [[ "$kind" == darwin ]]; then
    sudo darwin-rebuild switch --rollback
  else
    sudo nixos-rebuild switch --rollback
  fi
  log_success "Rollback completed for $host"
}

cmd_update() {
  local host="" attr pull=true argument
  while (($#)); do
    argument="$1"
    case "$argument" in
      --no-pull|--offline) pull=false ;;
      macbook|laptop|gaming-pc|beattie|mini1|mini2) host="$argument" ;;
      *) log_error "Unknown update option or host: $argument"; echo "Usage: tundra rbu [--no-pull|--offline] [host]" >&2; exit 2 ;;
    esac
    shift
  done
  host="$(resolve_host "$host")"
  attr="$(flake_attr "$host")"
  require_repo
  if [[ "$pull" == true ]]; then
    if [[ -n "$(git status --porcelain)" ]]; then
      log_error "Refusing to pull with local changes in $NIX_CONFIG_DIR"
      echo "Commit or stash them, or rerun as: tundra rbu --no-pull $host" >&2
      exit 1
    fi
    log_info "Pulling latest GitHub revision before updating inputs..."
    git pull --ff-only
  else
    log_warn "Skipping GitHub pull; updating the current checkout"
  fi
  log_warn "Updating flake.lock; this is a reviewed repository mutation."
  nix flake update
  echo "--- flake.lock changes ---"
  git diff -- flake.lock || true
  log_info "Building updated $host without activation..."
  nix build --no-link "$attr"
  log_success "Inputs updated and $host build verified; nothing was activated"
}

cmd_doctor() {
  local issues=0
  log_info "Read-only health checks"

  if [[ -f "$NIX_CONFIG_DIR/flake.nix" ]]; then log_success "flake.nix exists"; else log_error "flake.nix missing"; ((issues+=1)); fi
  if command -v nix >/dev/null 2>&1; then log_success "$(nix --version)"; else log_error "nix is not in PATH"; ((issues+=1)); fi
  if [[ -d "$NIX_CONFIG_DIR/.git" ]]; then
    if (cd "$NIX_CONFIG_DIR" && git status --porcelain | grep -q .); then log_warn "working tree has uncommitted changes"; else log_success "working tree clean"; fi
  fi
  if [[ -f "$CONFIG_DIR/theme" ]]; then log_info "local theme state: $(cat "$CONFIG_DIR/theme")"; else log_info "theme state is generated by Home Manager"; fi

  if command -v nix >/dev/null 2>&1 && [[ -f "$NIX_CONFIG_DIR/flake.nix" ]]; then
    log_info "Checking all flake outputs (no activation)..."
    if (cd "$NIX_CONFIG_DIR" && nix flake check --all-systems --no-build); then log_success "all outputs evaluate"; else log_error "flake output check failed"; ((issues+=1)); fi
  fi

  if ((issues == 0)); then log_success "Doctor checks passed"; else log_error "$issues issue(s) found"; exit 1; fi
}

cmd_gaming() {
  case "${1:-}" in
    proton) log_info "Available Proton versions:"; ls -1 ~/.steam/steam/compatibilitytools.d/ 2>/dev/null || log_warn "No custom Proton found" ;;
    gamescope) systemctl --user list-units --type=service 2>/dev/null | grep gamescope || log_info "No gamescope services running" ;;
    lutris) lutris --list-games 2>/dev/null || log_warn "Lutris not installed or no games" ;;
    heroic|bottles)
      if command -v "$1" >/dev/null 2>&1; then log_success "$1 installed"; else log_warn "$1 not installed"; fi
      ;;
    *) echo "Usage: tundra gaming [proton|gamescope|lutris|heroic|bottles]" ;;
  esac
}

cmd_github() {
  command -v gh >/dev/null 2>&1 || { log_error "GitHub CLI (gh) is not installed"; exit 1; }
  case "${1:-status}" in
    status|runs) gh run list --limit 10 ;;
    watch) gh run watch "${2:-}" ;;
    pr) gh pr view --web ;;
    workflows) gh workflow list ;;
    login) gh auth login ;;
    auth) gh auth status ;;
    *) log_error "Usage: tundra github [status|login|auth|watch <run-id>|pr|workflows]"; exit 2 ;;
  esac
}

cmd_wallpaper() {
  local action="${1:-list}" directory target script candidate file
  directory=""
  for candidate in "$HOME/.local/share/tundra/wallpapers" "$NIX_CONFIG_DIR/wallpapers" "$HOME/.config/nix-config/wallpapers"; do
    [[ -d "$candidate" ]] || continue
    shopt -s nullglob
    for file in "$candidate"/*.jpg "$candidate"/*.jpeg "$candidate"/*.png "$candidate"/*.webp; do
      if [[ -f "$file" ]]; then
        directory="$candidate"
        break 2
      fi
    done
    shopt -u nullglob
  done
  [[ -n "$directory" ]] || directory="$NIX_CONFIG_DIR/wallpapers"
  script="$NIX_CONFIG_DIR/scripts/wallpaper.sh"
  [[ -x "$script" ]] || script="$HOME/.local/bin/tundra-wallpaper"

  case "$action" in
    list|ls)
      [[ -d "$directory" ]] || { log_error "Wallpaper directory not found: $directory"; exit 1; }
      shopt -s nullglob
      for file in "$directory"/*.jpg "$directory"/*.jpeg "$directory"/*.png "$directory"/*.webp; do
        [[ -f "$file" ]] || continue
        [[ "$(basename "$file")" == wallpaper_backup_* ]] && continue
        basename "$file"
      done | sort
      shopt -u nullglob
      ;;
    set|select)
      target="${2:-}"
      [[ -n "$target" ]] || { log_error "Wallpaper name or path required"; exit 2; }
      if [[ ! -f "$target" ]]; then target="$directory/$(basename "$target")"; fi
      [[ -f "$target" ]] || { log_error "Wallpaper not found: $target"; exit 1; }
      if [[ -x "$script" ]]; then
        TUNDRA_WALLPAPER_DIR="$directory" "$script" "$target"
      else
        log_error "Wallpaper switcher is unavailable at $script"
        exit 1
      fi
      ;;
    reload)
      [[ -x "$script" ]] || { log_error "Wallpaper switcher is unavailable at $script"; exit 1; }
      TUNDRA_WALLPAPER_DIR="$directory" "$script" --reload
      ;;
    self-test)
      TUNDRA_WALLPAPER_DIR="$directory" "$HOME/.local/bin/tundra-wallpaper-daemon" --self-test
      ;;
    *)
      log_error "Usage: tundra wallpaper [list|set <name>|reload|self-test]"
      exit 2
      ;;
  esac
}

cmd_apps() {
  case "${1:-list}" in
    list)
      log_warn "These are imperative profile operations, not repository declarations."
      nix profile list 2>/dev/null | head -30
      ;;
    install|remove)
      local pkg="${2:-}"
      [[ -n "$pkg" ]] || { log_error "Package name required"; exit 2; }
      log_warn "Imperative profile operation: $1 $pkg"
      if [[ "$1" == install ]]; then nix profile install "nixpkgs#$pkg"; else nix profile remove "$pkg"; fi
      ;;
    *) log_error "Usage: tundra apps [list|install|remove] [package]"; exit 2 ;;
  esac
}

cmd_edit() {
  local editor="${EDITOR:-nvim}"
  case "${1:-config}" in
    config|nix) "$editor" "$NIX_CONFIG_DIR" ;;
    hyprland) "$editor" "$NIX_CONFIG_DIR/modules/nixos/hyprland" ;;
    aerospace) "$editor" "$HOME/.config/aerospace/aerospace.toml" ;;
    sketchybar) "$editor" "$HOME/.config/sketchybar" ;;
    karabiner) "$editor" "$HOME/.config/karabiner" ;;
    shell) "$editor" "$NIX_CONFIG_DIR/modules/shared/shell.nix" ;;
    theme) "$editor" "$NIX_CONFIG_DIR/modules/home/themes.nix" ;;
    *) log_error "Unknown edit target: $1"; exit 2 ;;
  esac
}

cmd_gc() {
  if [[ "${1:-}" != --yes ]]; then
    log_error "Garbage collection deletes unreferenced store paths. Re-run as: tundra gc --yes"
    exit 2
  fi
  log_warn "Running destructive garbage collection"
  nix-collect-garbage -d
}

cmd_help() {
  cat <<EOF
Tundra CLI v$VERSION — explicit Nix configuration operations

USAGE:
  tundra <command> [host]

READ-ONLY / BUILD:
  eval [host]                 Evaluate one output; no build or activation
  build [host]                Build one output; no activation
  doctor                      Check repository and evaluate all outputs

SYSTEM ACTIONS:
  test <host>                 Temporary NixOS activation
  switch <host>               Activate the selected host
  boot <host>                 Build and add a boot generation (NixOS only)
  rollback <host>             Roll back the active generation
  rb [--no-pull] <host>       Pull fast-forward from GitHub, then activate

INPUTS AND OTHER:
  rbu [--no-pull] <host>      Pull fast-forward, update flake.lock, then build
  rebuild/update              Compatibility aliases for rb/rbu
  theme [current|list]         Show declared theme information
  gaming [subcommand]          Gaming utilities
  wallpaper [list|set|reload]   List and switch wallpapers
  github [status|login|watch]   GitHub Actions, auth, and pull-request status
  apps [list|install|remove]   Imperative profile operations (not declarative)
  edit [target]                Open repository configuration
  gc --yes                     Destructive garbage collection
  help                         Show this help

SUPPORTED HOSTS:
  macbook laptop gaming-pc beattie mini1 mini2

Examples:
  tundra eval gaming-pc
  tundra build gaming-pc
  tundra rb gaming-pc
  tundra rb --no-pull gaming-pc
  tundra rbu gaming-pc
  tundra rbu --no-pull gaming-pc
  tundra rbu macbook
EOF
}

case "${1:-help}" in
  theme) cmd_theme "${2:-current}" "${3:-}" ;;
  eval) cmd_eval "${2:-}" ;;
  build) cmd_build "${2:-}" ;;
  test|switch|boot) cmd_system_action "$1" "${2:-}" ;;
  rb|rebuild) shift; cmd_rebuild "$@" ;;
  rollback) cmd_rollback "${2:-}" ;;
  rbu|update) shift; cmd_update "$@" ;;
  doctor) cmd_doctor ;;
  gaming) cmd_gaming "${2:-}" ;;
  github|gh) cmd_github "${2:-}" "${3:-}" ;;
  wallpaper|wallpapers|wp) cmd_wallpaper "${2:-}" "${3:-}" ;;
  apps) cmd_apps "${2:-}" "${3:-}" ;;
  edit) cmd_edit "${2:-}" ;;
  gc) cmd_gc "${2:-}" ;;
  help|--help|-h) cmd_help ;;
  *) log_error "Unknown command: $1"; cmd_help; exit 2 ;;
esac
