#!/usr/bin/env bash
set -euo pipefail

USERNAME="elias"
CONFIG_DIR="/home/elias/.config/nix-config"
CONFIG_REPO="https://github.com/tundra-node/nix-config"

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
die() { echo "[ERR] $*" >&2; exit 1; }

install_apk_packages() {
  info "Updating APK..."
  doas apk update
  doas apk upgrade

  info "Installing trimmed system packages..."

  # Core
  doas apk add bash zsh git curl wget rsync openssh sudo util-linux pciutils usbutils man-db less which

  # Intel GPU drivers (keep as-is)
  doas apk add mesa-dri-gallium linux-firmware-intel

  # Network
  doas apk add iwd wpa_supplicant networkmanager networkmanager-tui networkmanager-wifi

  # Docker
  doas apk add docker docker-cli-compose
  doas rc-update add docker default

  # YubiKey + GPG
  doas apk add yubikey-manager libfido2 pcsc-lite pcsc-lite-libs gnupg gnupg-scdaemon

  # Fonts
  doas apk add font-jetbrains-mono-nerd font-noto-emoji adwaita-icon-theme

  ok "APK packages installed"
}

enable_services() {
  info "Enabling OpenRC services..."
  doas rc-update add udev sysinit || true
  doas rc-update add udev-trigger sysinit || true
  doas rc-update add seatd default || true
  doas rc-update add dbus default || true
  doas rc-update add iwd default || true
  doas rc-update add networkmanager default || true
  # Docker
  doas rc-update add docker default || true
  # YubiKey
  doas rc-update add pcscd default || true

  # Do not enable Ly or any display manager
}

setup_groups() {
  info "Adding $USERNAME to required groups..."
  for grp in wheel video audio input seat docker; do
    doas addgroup "$USERNAME" "$grp" 2>/dev/null || true
  done
}

apply_config() {
  info "Setting up nix-config repo..."
  if [[ -d "$CONFIG_DIR" ]]; then
    warn "$CONFIG_DIR already exists — skipping clone"
  else
    git clone "$CONFIG_REPO" "$CONFIG_DIR"
  fi
  git -C "$CONFIG_DIR" add . 2>/dev/null || true
  [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh || true
  home-manager switch --flake "$CONFIG_DIR#mini1"
}

main() {
  install_apk_packages
  enable_services
  setup_groups
  apply_config
  echo "Done. Run: home-manager switch --flake ~/.config/nix-config#mini1"
}

main
