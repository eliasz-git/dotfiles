#!/usr/bin/env bash
set -euo pipefail

USERNAME="elias"
CONFIG_DIR="/home/elias/.config/nix-config"
CONFIG_REPO="https://github.com/tundra-node/nix-config"

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
die() { echo "[ERR] $*" >&2; exit 1; }

install_pacman_packages() {
  info "Installing system packages via pacman..."

  sudo pacman -S --noconfirm --needed base-devel git wget curl nano

  # Wayland / Niri
  sudo pacman -S --noconfirm --needed niri sddm xdg-desktop-portal xdg-desktop-portal-gtk qt5-wayland qt6-wayland

  # Audio
  sudo pacman -S --noconfirm --needed pipewire pipewire-alsa pipewire-pulse wireplumber rtkit

  # Network
  sudo pacman -S --noconfirm --needed networkmanager network-manager-applet networkmanager-openvpn

  # Remove Intel-specific graphics, install AMD stack
  sudo pacman -Rns --noconfirm intel-media-driver libva-intel-driver vulkan-intel || true
  sudo pacman -S --noconfirm --needed mesa vulkan-radeon libva-mesa-driver mesa-vdpau

  # Containers
  sudo pacman -S --noconfirm --needed docker docker-compose

  # Fonts
  sudo pacman -S --noconfirm --needed ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

  ok "Pacman packages installed"
}

install_aur_packages() {
  info "Installing AUR packages via yay..."
  if command -v yay &>/dev/null; then
    yay -S --noconfirm --needed ollama-rocm steam
  else
    warn "yay not found — skipping AUR installs (ollama, steam)"
  fi
}

install_nix() {
  info "Installing Nix (multi-user)..."
  if command -v nix &>/dev/null; then
    info "Nix already installed"
    return
  fi
  wget -qO /tmp/nix-install.sh https://nixos.org/nix/install
  sudo sh /tmp/nix-install.sh --daemon
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
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
  home-manager switch --flake "$CONFIG_DIR#mini2"
}

main() {
  install_pacman_packages
  install_aur_packages
  install_nix
  apply_config
  echo "Done. Run: home-manager switch --flake ~/.config/nix-config#mini2"
}

main
