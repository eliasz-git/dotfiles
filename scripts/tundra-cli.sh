#!/usr/bin/env bash
# tundra-cli — Tundra configuration management CLI (Omarchy-inspired)
# Usage: tundra <command> [args...]

set -euo pipefail

VERSION="0.1.0"
CONFIG_DIR="${HOME}/.config/tundra"
NIX_CONFIG_DIR="${HOME}/.config/nix-config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Commands ────────────────────────────────────────────────────────

cmd_theme() {
  case "${1:-current}" in
    current)
      if [ -f "${CONFIG_DIR}/theme" ]; then
        cat "${CONFIG_DIR}/theme"
      else
        echo "catppuccin-mocha"
      fi
      ;;
    list|ls)
      echo "Available themes:"
      for theme in catppuccin-mocha catppuccin-latte catppuccin-frappe catppuccin-macchiato \
                   gruvbox-dark gruvbox-light \
                   nord \
                   tokyo-night tokyo-night-storm tokyo-night-day \
                   kanagawa-wave kanagawa-dragon kanagawa-lotus \
                   rose-pine rose-pine-moon rose-pine-dawn \
                   everforest-dark everforest-light \
                   flexoki-dark flexoki-light \
                   matte-black miasma solitude ristretto osaka-jade last-horizon lupine hackerman ethereal lumon retro-82; do
        echo "  $theme"
      done
      ;;
    set)
      local theme_name="${2:-}"
      if [ -z "$theme_name" ]; then
        log_error "Theme name required"
        echo "Usage: tundra theme set <theme>"
        exit 1
      fi
      mkdir -p "$CONFIG_DIR"
      echo "$theme_name" > "${CONFIG_DIR}/theme"
      log_success "Theme set to: $theme_name"
      log_info "Run 'tundra rebuild' to apply system-wide"
      ;;
    *)
      log_error "Unknown theme command: $1"
      echo "Usage: tundra theme [current|list|set <theme>]"
      exit 1
      ;;
  esac
}

cmd_rebuild() {
  local host="${1:-}"
  if [ -z "$host" ]; then
    # Auto-detect host
    if [ -f /etc/nixos/configuration.nix ] || [ -f /run/current-system/sw/bin/nixos-version ]; then
      host="gaming-pc"
    elif [ "$(uname)" = "Darwin" ]; then
      host="macbook"
    else
      log_error "Could not detect host. Specify: tundra rebuild <gaming-pc|macbook>"
      exit 1
    fi
  fi

  log_info "Rebuilding $host..."
  cd "$NIX_CONFIG_DIR"

  case "$host" in
    gaming-pc)
      sudo nixos-rebuild switch --flake ".#gaming-pc"
      ;;
    macbook)
      sudo darwin-rebuild switch --flake ".#macbook"
      ;;
    laptop)
      sudo nixos-rebuild switch --flake ".#laptop"
      ;;
    mini1)
      sudo nixos-rebuild switch --flake ".#mini1"
      ;;
    mini2)
      sudo nixos-rebuild switch --flake ".#mini2"
      ;;
    beattie)
      sudo nixos-rebuild switch --flake ".#beattie"
      ;;
    beattie-minimal)
      sudo nixos-rebuild switch --flake ".#beattie-minimal"
      ;;
    *)
      log_error "Unknown host: $host"
      exit 1
      ;;
  esac
  log_success "Rebuild complete"
}

cmd_update() {
  log_info "Updating flake..."
  cd "$NIX_CONFIG_DIR"
  nix flake update
  log_success "Flake updated"
  log_info "Run 'tundra rebuild' to apply updates"
}

cmd_doctor() {
  log_info "Running health checks..."

  local issues=0

  # Check flake
  if [ -f "$NIX_CONFIG_DIR/flake.nix" ]; then
    log_success "flake.nix exists"
  else
    log_error "flake.nix not found at $NIX_CONFIG_DIR"
    ((issues++))
  fi

  # Check nix
  if command -v nix >/dev/null 2>&1; then
    log_success "nix available: $(nix --version)"
  else
    log_error "nix not in PATH"
    ((issues++))
  fi

  # Check home-manager
  if command -v home-manager >/dev/null 2>&1; then
    log_success "home-manager available"
  else
    log_warn "home-manager not in PATH (may be via nix shell)"
  fi

  # Check theme state
  if [ -f "${CONFIG_DIR}/theme" ]; then
    log_success "Theme set: $(cat "${CONFIG_DIR}/theme")"
  else
    log_warn "No theme set (default: catppuccin-mocha)"
  fi

  # Check git status
  if [ -d "$NIX_CONFIG_DIR/.git" ]; then
    cd "$NIX_CONFIG_DIR"
    if git status --porcelain | grep -q .; then
      log_warn "Uncommitted changes in nix-config"
    else
      log_success "Git working tree clean"
    fi
  fi

  # Check disk space
  local disk_usage=$(df -h "$HOME" | tail -1 | awk '{print $5}' | tr -d '%')
  if [ "$disk_usage" -gt 90 ]; then
    log_error "Disk usage critical: ${disk_usage}%"
    ((issues++))
  elif [ "$disk_usage" -gt 80 ]; then
    log_warn "Disk usage high: ${disk_usage}%"
  else
    log_success "Disk usage: ${disk_usage}%"
  fi

  # Check Nix store
  if command -v nix >/dev/null 2>&1; then
    local store_size=$(nix store info 2>/dev/null | grep "Store size" | awk '{print $3}' || echo "unknown")
    log_info "Nix store size: $store_size"
  fi

  if [ $issues -eq 0 ]; then
    log_success "All checks passed"
  else
    log_error "$issues issue(s) found"
    exit 1
  fi
}

cmd_gaming() {
  case "${1:-}" in
    proton)
      log_info "Available Proton versions:"
      ls -1 ~/.steam/steam/compatibilitytools.d/ 2>/dev/null || log_warn "No custom Proton found"
      ;;
    gamescope)
      log_info "Gamescope sessions:"
      systemctl --user list-units --type=service | grep gamescope || log_info "No gamescope services running"
      ;;
    lutris)
      log_info "Lutris games:"
      lutris --list-games 2>/dev/null || log_warn "Lutris not installed or no games"
      ;;
    heroic)
      log_info "Heroic Games Launcher:"
      command -v heroic >/dev/null && log_success "Heroic installed" || log_warn "Heroic not installed"
      ;;
    bottles)
      log_info "Bottles:"
      command -v bottles >/dev/null && log_success "Bottles installed" || log_warn "Bottles not installed"
      ;;
    *)
      echo "Gaming utilities:"
      echo "  tundra gaming proton    - List Proton versions"
      echo "  tundra gaming gamescope - Check gamescope sessions"
      echo "  tundra gaming lutris    - List Lutris games"
      echo "  tundra gaming heroic    - Check Heroic"
      echo "  tundra gaming bottles   - Check Bottles"
      ;;
  esac
}

cmd_apps() {
  case "${1:-list}" in
    list)
      log_info "Installed applications (via nix):"
      nix profile list 2>/dev/null | head -30
      echo ""
      log_info "Home Manager packages:"
      home-manager packages 2>/dev/null | head -30
      ;;
    install)
      local pkg="${2:-}"
      if [ -z "$pkg" ]; then
        log_error "Package name required"
        exit 1
      fi
      log_info "Installing $pkg..."
      nix profile install "nixpkgs#$pkg"
      log_success "Installed $pkg"
      ;;
    remove)
      local pkg="${2:-}"
      if [ -z "$pkg" ]; then
        log_error "Package name required"
        exit 1
      fi
      log_info "Removing $pkg..."
      nix profile remove "$pkg"
      log_success "Removed $pkg"
      ;;
    *)
      log_error "Unknown apps command: $1"
      echo "Usage: tundra apps [list|install|remove] [package]"
      exit 1
      ;;
  esac
}

cmd_edit() {
  local editor="${EDITOR:-nvim}"
  case "${1:-config}" in
    config|nix)
      $editor "$NIX_CONFIG_DIR"
      ;;
    hyprland)
      $editor "$NIX_CONFIG_DIR/modules/nixos/hyprland"
      ;;
    aerospace)
      $editor "$HOME/.config/aerospace/aerospace.toml"
      ;;
    sketchybar)
      $editor "$HOME/.config/sketchybar"
      ;;
    karabiner)
      $editor "$HOME/.config/karabiner"
      ;;
    shell)
      $editor "$NIX_CONFIG_DIR/modules/shared/shell.nix"
      ;;
    theme)
      $editor "$NIX_CONFIG_DIR/modules/shared/themes.nix"
      ;;
    *)
      log_error "Unknown edit target: $1"
      echo "Targets: config, hyprland, aerospace, sketchybar, karabiner, shell, theme"
      exit 1
      ;;
  esac
}

cmd_gc() {
  log_info "Running garbage collection..."
  nix-collect-garbage -d
  log_success "Garbage collection complete"
}

cmd_help() {
  cat <<EOF
tundra-cli v$VERSION — Tundra configuration management

USAGE:
  tundra <command> [args...]

COMMANDS:
  theme [current|list|set <theme>]  Manage themes (20+ available)
  rebuild [host]                    Rebuild system (gaming-pc, macbook, laptop, mini1, mini2, beattie)
  update                            Update flake inputs
  doctor                            Run health checks
  gaming [proton|gamescope|lutris|heroic|bottles]  Gaming utilities
  apps [list|install|remove] [pkg]  Manage nix packages
  edit [config|hyprland|aerospace|sketchybar|karabiner|shell|theme]  Edit config files
  gc                                Run garbage collection
  help                              Show this help

EXAMPLES:
  tundra theme set catppuccin-mocha
  tundra rebuild gaming-pc
  tundra update && tundra rebuild
  tundra doctor
  tundra edit hyprland
  tundra gaming proton
EOF
}

# ── Main ────────────────────────────────────────────────────────────

case "${1:-help}" in
  theme)
    cmd_theme "${2:-}" "${3:-}"
    ;;
  rebuild)
    cmd_rebuild "${2:-}"
    ;;
  update)
    cmd_update
    ;;
  doctor)
    cmd_doctor
    ;;
  gaming)
    cmd_gaming "${2:-}"
    ;;
  apps)
    cmd_apps "${2:-}" "${3:-}"
    ;;
  edit)
    cmd_edit "${2:-}"
    ;;
  gc)
    cmd_gc
    ;;
  help|--help|-h)
    cmd_help
    ;;
  *)
    log_error "Unknown command: $1"
    cmd_help
    exit 1
    ;;
esac