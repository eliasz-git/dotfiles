#!/usr/bin/env bash
# NixOS placeholder replacement script
# Usage: ./replace.sh <username> <github_username> <email>
# Or run without arguments for interactive mode

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if arguments provided or interactive mode
if [[ $# -eq 3 ]]; then
    USER_NAME="$1"
    GITHUB_USER="$2"
    EMAIL="$3"
else
    echo "NixOS Configuration - Placeholder Replacement"
    echo "=============================================="
    echo ""
    read -rp "Enter system username: " USER_NAME
    read -rp "Enter GitHub username: " GITHUB_USER
    read -rp "Enter email address: " EMAIL
fi

# Validate inputs
if [[ -z "$USER_NAME" || -z "$GITHUB_USER" || -z "$EMAIL" ]]; then
    print_error "All fields are required"
    exit 1
fi

# Validate email format (basic check)
if [[ ! "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    print_error "Invalid email format"
    exit 1
fi

echo ""
echo "Replacing placeholders with:"
echo "  User: $USER_NAME"
echo "  GitHub: $GITHUB_USER"
echo "  Email: $EMAIL"
echo ""

# Perform replacements
find "$SCRIPT_DIR" -type f -name "*.nix" -exec sed -i "s/tundra/$USER_NAME/g" {} +
find "$SCRIPT_DIR" -type f -name "*.nix" -exec sed -i "s/tundra-node/$GITHUB_USER/g" {} +
find "$SCRIPT_DIR" -type f -name "*.nix" -exec sed -i "s/117379918+tundra-node@users.noreply.github.com/$EMAIL/g" {} +

print_success "Placeholders replaced successfully!"
echo ""
echo "Next steps:"
echo "  1. Copy hardware-configuration.nix to this directory if not present"
echo "  2. Run: sudo nixos-rebuild switch --flake /etc/nixos#laptop"
echo ""