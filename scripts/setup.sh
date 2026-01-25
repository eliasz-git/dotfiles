#!/usr/bin/env bash
# NixOS/macOS Nix Configuration Setup Script
# This script helps set up the nix-config for first-time users

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

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       🌲 Nix Configuration Setup - Everforest Theme        ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  This script will help you set up your nix configuration   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

print_info "Detected OS: $OS"
print_info "Config directory: $CONFIG_DIR"
echo ""

# Validate we're in the right directory
if [[ ! -f "$CONFIG_DIR/flake.nix" ]]; then
    print_error "Could not find flake.nix. Make sure this script is run from the nix-config/scripts directory."
    exit 1
fi

# Prompt for user details
echo "Please provide the following details:"
echo ""

read -rp "Enter your system username (e.g., john): " USER_NAME
if [[ -z "$USER_NAME" ]]; then
    print_error "Username cannot be empty"
    exit 1
fi

read -rp "Enter your GitHub username (for git config): " GITHUB_USERNAME
if [[ -z "$GITHUB_USERNAME" ]]; then
    print_error "GitHub username cannot be empty"
    exit 1
fi

read -rp "Enter your email (for git config): " USER_EMAIL
if [[ -z "$USER_EMAIL" ]]; then
    print_error "Email cannot be empty"
    exit 1
fi

echo ""
print_info "Configuration summary:"
echo "  - System user: $USER_NAME"
echo "  - GitHub username: $GITHUB_USERNAME"
echo "  - Email: $USER_EMAIL"
echo ""

read -rp "Is this correct? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    print_warning "Setup cancelled. Run the script again with correct details."
    exit 0
fi

echo ""
print_info "Replacing placeholders in configuration files..."

# Function to replace placeholders
replace_placeholders() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if [[ "$OS" == "darwin" ]]; then
            sed -i '' "s/{user}/$USER_NAME/g" "$file" 2>/dev/null || true
            sed -i '' "s/{username}/$GITHUB_USERNAME/g" "$file" 2>/dev/null || true
            sed -i '' "s/{email}/$USER_EMAIL/g" "$file" 2>/dev/null || true
        else
            sed -i "s/{user}/$USER_NAME/g" "$file" 2>/dev/null || true
            sed -i "s/{username}/$GITHUB_USERNAME/g" "$file" 2>/dev/null || true
            sed -i "s/{email}/$USER_EMAIL/g" "$file" 2>/dev/null || true
        fi
    fi
}

# Replace in all nix files
find "$CONFIG_DIR" -type f -name "*.nix" | while read -r file; do
    replace_placeholders "$file"
    print_info "Processed: $file"
done

print_success "Placeholders replaced successfully!"
echo ""

# OS-specific setup
if [[ "$OS" == "darwin" ]]; then
    print_info "Running macOS-specific setup..."
    
    # Make sketchybar scripts executable
    if [[ -d "$CONFIG_DIR/sketchybar" ]]; then
        chmod +x "$CONFIG_DIR/sketchybar/"*.sh 2>/dev/null || true
        chmod +x "$CONFIG_DIR/sketchybar/items/"*.sh 2>/dev/null || true
        chmod +x "$CONFIG_DIR/sketchybar/plugins/"*.sh 2>/dev/null || true
        print_success "SketchyBar scripts made executable"
    fi
    
    echo ""
    print_info "Next steps for macOS:"
    echo "  1. Update the flake: cd $CONFIG_DIR && nix flake update"
    echo "  2. Build: sudo darwin-rebuild switch --flake $CONFIG_DIR#macbook"
    echo "  3. For full yabai functionality, disable SIP (see README)"
    echo ""
    
elif [[ "$OS" == "nixos" ]]; then
    print_info "Running NixOS-specific setup..."
    
    # Check for hardware-configuration.nix
    if [[ ! -f "$CONFIG_DIR/nixos/hardware-configuration.nix" ]]; then
        print_warning "hardware-configuration.nix not found!"
        if [[ -f "/etc/nixos/hardware-configuration.nix" ]]; then
            print_info "Copying from /etc/nixos/hardware-configuration.nix..."
            cp /etc/nixos/hardware-configuration.nix "$CONFIG_DIR/nixos/hardware-configuration.nix"
            print_success "hardware-configuration.nix copied"
        else
            print_error "Please copy your hardware-configuration.nix to $CONFIG_DIR/nixos/"
        fi
    fi
    
    # Create symlink for /etc/nixos if requested
    echo ""
    read -rp "Create symlink from /etc/nixos to this config? (y/n): " CREATE_SYMLINK
    if [[ "$CREATE_SYMLINK" == "y" || "$CREATE_SYMLINK" == "Y" ]]; then
        if [[ -d "/etc/nixos" && ! -L "/etc/nixos" ]]; then
            print_info "Backing up existing /etc/nixos..."
            sudo mv /etc/nixos /etc/nixos.backup
        fi
        
        if [[ -L "/etc/nixos" ]]; then
            print_warning "Removing existing symlink..."
            sudo rm /etc/nixos
        fi
        
        sudo ln -s "$CONFIG_DIR" /etc/nixos
        print_success "Symlink created: /etc/nixos -> $CONFIG_DIR"
    fi
    
    echo ""
    print_info "Next steps for NixOS:"
    echo "  1. Verify hardware-configuration.nix is in nixos/ directory"
    echo "  2. Update timezone in nixos/configuration.nix if needed"
    echo "  3. Update the flake: cd $CONFIG_DIR && sudo nix flake update"
    echo "  4. Build: sudo nixos-rebuild switch --flake /etc/nixos#laptop"
    echo "  5. Reboot: sudo reboot"
    echo ""
    
else
    print_warning "Unknown OS detected. Manual setup may be required."
fi

print_success "Setup complete! Please review the next steps above."
echo ""
