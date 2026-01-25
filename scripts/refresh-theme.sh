#!/usr/bin/env bash
# Cursor and Theme Refresh Script for NixOS
# Refreshes cursor theme and GTK settings without requiring a full rebuild

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

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --cursor   Refresh cursor theme only"
    echo "  -g, --gtk      Refresh GTK theme only"
    echo "  -a, --all      Refresh all themes (default)"
    echo ""
    echo "This script refreshes cursor and GTK themes on NixOS with Hyprland."
    echo ""
}

refresh_cursor() {
    print_info "Refreshing cursor theme..."
    
    # Set environment variables for cursor
    export XCURSOR_THEME="Bibata-Modern-Classic"
    export XCURSOR_SIZE=24
    
    # Update Hyprland cursor config if hyprctl is available
    if command -v hyprctl &> /dev/null; then
        hyprctl setcursor "Bibata-Modern-Classic" 24 2>/dev/null || {
            print_warning "Could not set cursor via hyprctl (Hyprland may not be running)"
        }
    fi
    
    # Update gsettings if available (for GTK apps)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
    fi
    
    print_success "Cursor theme refreshed"
}

refresh_gtk() {
    print_info "Refreshing GTK theme..."
    
    # Update gsettings if available
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "Everforest-Dark-BL" 2>/dev/null || {
            print_warning "Everforest GTK theme not found, trying alternatives..."
            gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
        }
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
    fi
    
    # Create or update GTK settings files
    local gtk3_settings="$HOME/.config/gtk-3.0/settings.ini"
    local gtk4_settings="$HOME/.config/gtk-4.0/settings.ini"
    
    mkdir -p "$(dirname "$gtk3_settings")" "$(dirname "$gtk4_settings")"
    
    # GTK 3 settings
    cat > "$gtk3_settings" << EOF
[Settings]
gtk-theme-name=Everforest-Dark-BL
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=true
EOF
    
    # GTK 4 settings
    cat > "$gtk4_settings" << EOF
[Settings]
gtk-theme-name=Everforest-Dark-BL
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=true
EOF
    
    print_success "GTK theme refreshed"
}

refresh_hyprland() {
    print_info "Refreshing Hyprland environment..."
    
    if command -v hyprctl &> /dev/null && pgrep -x "Hyprland" > /dev/null; then
        # Reload Hyprland config
        hyprctl reload 2>/dev/null || print_warning "Could not reload Hyprland config"
        print_success "Hyprland refreshed"
    else
        print_warning "Hyprland not running, skipping reload"
    fi
}

# Default action
ACTION="all"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -c|--cursor)
            ACTION="cursor"
            shift
            ;;
        -g|--gtk)
            ACTION="gtk"
            shift
            ;;
        -a|--all)
            ACTION="all"
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
echo "║           🎨 Theme Refresh - Everforest                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

case "$ACTION" in
    cursor)
        refresh_cursor
        ;;
    gtk)
        refresh_gtk
        ;;
    all)
        refresh_cursor
        refresh_gtk
        refresh_hyprland
        ;;
esac

echo ""
print_success "Theme refresh complete!"
print_info "Note: Some applications may need to be restarted to apply changes."
echo ""
