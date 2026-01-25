#!/usr/bin/env bash
# Rebuild Script for NixOS/macOS
# Simplifies the rebuild process with helpful output

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get script and config directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ -f /etc/os-release ]] && grep -q "NixOS" /etc/os-release; then
        echo "nixos"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -u, --update   Update flake inputs before rebuilding"
    echo "  -t, --test     Build and activate but don't add to bootloader (NixOS only)"
    echo "  -b, --boot     Build and add to bootloader but don't activate (NixOS only)"
    echo "  -d, --dry-run  Show what would be built without building"
    echo ""
    echo "Examples:"
    echo "  $0              # Standard rebuild"
    echo "  $0 --update     # Update flake and rebuild"
    echo "  $0 --test       # Test build without committing"
    echo ""
}

# Parse arguments
UPDATE_FLAKE=false
BUILD_ACTION="switch"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -u|--update)
            UPDATE_FLAKE=true
            shift
            ;;
        -t|--test)
            BUILD_ACTION="test"
            shift
            ;;
        -b|--boot)
            BUILD_ACTION="boot"
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║            🌲 Nix Configuration Rebuild                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

print_info "Detected OS: $OS"
print_info "Build action: $BUILD_ACTION"
print_info "Update flake: $UPDATE_FLAKE"
echo ""

if [[ "$OS" == "unknown" ]]; then
    print_error "Unknown OS. This script supports NixOS and macOS (darwin)."
    exit 1
fi

# Update flake if requested
if [[ "$UPDATE_FLAKE" == true ]]; then
    print_info "Updating flake inputs..."
    cd "$CONFIG_DIR"
    
    if [[ "$OS" == "nixos" ]]; then
        sudo nix flake update
    else
        nix flake update
    fi
    
    print_success "Flake updated"
    echo ""
fi

# Build
if [[ "$OS" == "darwin" ]]; then
    print_info "Rebuilding macOS configuration..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "Dry run - showing what would be built..."
        # Use dry-build to show what would be built without actually building
        nix build --dry-run ".#darwinConfigurations.macbook.system" --flake "$CONFIG_DIR" 2>&1 || {
            print_warning "dry-run not available, showing build plan with nix flake check..."
            nix flake check --no-build "$CONFIG_DIR" 2>&1 || true
        }
        print_info "Dry run complete - no changes were made"
    else
        sudo darwin-rebuild "$BUILD_ACTION" --flake "$CONFIG_DIR#macbook"
    fi
    
elif [[ "$OS" == "nixos" ]]; then
    print_info "Rebuilding NixOS configuration..."
    
    # Determine flake path
    FLAKE_PATH="/etc/nixos"
    if [[ ! -f "$FLAKE_PATH/flake.nix" ]]; then
        FLAKE_PATH="$CONFIG_DIR"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "Dry run - showing what would be built..."
        sudo nixos-rebuild dry-run --flake "$FLAKE_PATH#laptop"
    else
        sudo nixos-rebuild "$BUILD_ACTION" --flake "$FLAKE_PATH#laptop"
    fi
fi

echo ""
print_success "Rebuild completed successfully!"

# Post-build hints
if [[ "$BUILD_ACTION" == "switch" ]]; then
    if [[ "$OS" == "nixos" ]]; then
        echo ""
        print_info "Hints:"
        echo "  - If you changed Hyprland config, it should apply immediately"
        echo "  - If you changed SDDM config, changes apply on next login"
        echo "  - For major changes, consider rebooting: sudo reboot"
    elif [[ "$OS" == "darwin" ]]; then
        echo ""
        print_info "Hints:"
        echo "  - Restart SketchyBar: brew services restart sketchybar"
        echo "  - Restart yabai: brew services restart yabai"
        echo "  - Restart borders: brew services restart borders"
    fi
fi
