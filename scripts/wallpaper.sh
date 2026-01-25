#!/usr/bin/env bash
# Wallpaper Update Script for NixOS/macOS
# Updates the wallpaper and reloads the appropriate services

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
WALLPAPER_DIR="$CONFIG_DIR/wallpapers"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ -f /etc/os-release ]] && grep -q "NixOS" /etc/os-release; then
        echo "nixos"
    else
        echo "linux"
    fi
}

OS=$(detect_os)

usage() {
    echo "Usage: $0 [OPTIONS] [WALLPAPER_PATH]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List available wallpapers"
    echo "  -r, --reload   Reload current wallpaper"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/new/wallpaper.jpg    # Set new wallpaper"
    echo "  $0 --reload                       # Reload current wallpaper"
    echo "  $0 --list                         # List wallpapers"
    echo ""
}

list_wallpapers() {
    print_info "Available wallpapers in $WALLPAPER_DIR:"
    if [[ -d "$WALLPAPER_DIR" ]]; then
        local found=false
        shopt -s nullglob
        for file in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.webp; do
            if [[ -f "$file" ]]; then
                echo "  - $(basename "$file")"
                found=true
            fi
        done
        shopt -u nullglob
        if [[ "$found" == false ]]; then
            print_warning "No image files found"
        fi
    else
        print_error "Wallpaper directory not found"
    fi
}

reload_wallpaper_nixos() {
    print_info "Reloading wallpaper on NixOS (Hyprland)..."
    
    # Get hyprpaper PID for targeted kill
    local hyprpaper_pid
    hyprpaper_pid=$(pgrep -x "hyprpaper" 2>/dev/null || echo "")
    
    # Check if hyprpaper is running
    if [[ -n "$hyprpaper_pid" ]]; then
        print_info "Stopping hyprpaper (PID: $hyprpaper_pid)..."
        kill "$hyprpaper_pid" 2>/dev/null || true
        sleep 0.5
        hyprpaper &
        print_success "Hyprpaper reloaded"
    else
        print_info "Starting hyprpaper..."
        hyprpaper &
        print_success "Hyprpaper started"
    fi
}

reload_wallpaper_darwin() {
    print_info "Reloading wallpaper on macOS..."
    local wallpaper_path="$WALLPAPER_DIR/wallpaper.jpg"
    
    if [[ -f "$wallpaper_path" ]]; then
        osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$wallpaper_path\""
        print_success "Desktop wallpaper updated"
    else
        print_error "Wallpaper file not found: $wallpaper_path"
        exit 1
    fi
}

set_new_wallpaper() {
    local new_wallpaper="$1"
    
    if [[ ! -f "$new_wallpaper" ]]; then
        print_error "File not found: $new_wallpaper"
        exit 1
    fi
    
    # Check if it's an image file
    local mime_type
    mime_type=$(file --mime-type -b "$new_wallpaper" 2>/dev/null || echo "")
    if [[ ! "$mime_type" =~ ^image/ ]]; then
        print_warning "File may not be an image (detected: $mime_type)"
        read -rp "Continue anyway? (y/n): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            exit 0
        fi
    fi
    
    # Determine proper extension based on file type
    local extension="jpg"
    case "$mime_type" in
        image/png) extension="png" ;;
        image/jpeg) extension="jpg" ;;
        image/webp) extension="webp" ;;
    esac
    local target_filename="wallpaper.$extension"
    
    # Backup current wallpaper (any format)
    for existing in "$WALLPAPER_DIR"/wallpaper.{jpg,jpeg,png,webp}; do
        if [[ -f "$existing" ]]; then
            local backup_name
            local existing_ext="${existing##*.}"
            backup_name="wallpaper_backup_$(date +%Y%m%d_%H%M%S).$existing_ext"
            print_info "Backing up current wallpaper to $backup_name"
            cp "$existing" "$WALLPAPER_DIR/$backup_name"
            rm "$existing"
        fi
    done
    
    # Copy new wallpaper with correct extension
    print_info "Copying new wallpaper as $target_filename..."
    cp "$new_wallpaper" "$WALLPAPER_DIR/$target_filename"
    print_success "New wallpaper installed"
    
    print_warning "Note: You may need to update the wallpaper path in home.nix if the extension changed."
    
    # Reload
    if [[ "$OS" == "nixos" || "$OS" == "linux" ]]; then
        reload_wallpaper_nixos
    elif [[ "$OS" == "darwin" ]]; then
        reload_wallpaper_darwin
    fi
}

# Parse arguments
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    -l|--list)
        list_wallpapers
        exit 0
        ;;
    -r|--reload)
        if [[ "$OS" == "nixos" || "$OS" == "linux" ]]; then
            reload_wallpaper_nixos
        elif [[ "$OS" == "darwin" ]]; then
            reload_wallpaper_darwin
        fi
        exit 0
        ;;
    "")
        usage
        exit 1
        ;;
    *)
        set_new_wallpaper "$1"
        ;;
esac
