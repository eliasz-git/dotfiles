#!/usr/bin/env bash
# =============================================================================
# Artix Linux (OpenRC) setup script
# Sets up a minimal Artix system with niri, Nix, and Home Manager.
#
# Usage (as the target user, with sudo access):
#   chmod +x install.sh
#   ./install.sh [username]    # defaults to "tundra"
#
# Run this AFTER a fresh Artix basestrap install with:
#   - Network configured (NetworkManager or dhcpcd active)
#   - Your user account created with sudo (wheel) access
# =============================================================================

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}[OK]${RESET}  $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET} $*"; }
die()     { echo -e "${RED}${BOLD}[ERR]${RESET}  $*" >&2; exit 1; }

require_root() {
    [[ $EUID -eq 0 ]] || { echo "[ERR] Must be root" >&2; exit 1; }
}

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"

# =============================================================================
# ROOT SETUP MODE — called internally via: sudo bash "$SCRIPT_PATH" --root-setup "$USERNAME"
# Runs all root-only functions then exits. Never recurses into main.
# =============================================================================
if [[ "${1:-}" == "--root-setup" ]]; then
    USERNAME="${2:-tundra}"

    setup_user_groups() {
        require_root
        info "Adding $USERNAME to system groups…"
        local groups=(wheel networkmanager video input seat audio docker bluetooth lp)
        for group in "${groups[@]}"; do
            getent group "$group" &>/dev/null || groupadd "$group"
            usermod -aG "$group" "$USERNAME"
        done
        getent group seat &>/dev/null || groupadd seat
        success "User groups configured"
    }

    enable_openrc_services() {
        require_root
        info "Enabling OpenRC services…"

        # Write nix-daemon OpenRC service file so it survives reboot
        if [[ ! -f /etc/init.d/nix-daemon ]]; then
            info "  creating nix-daemon OpenRC service…"
            cat > /etc/init.d/nix-daemon <<'EOF'
#!/sbin/openrc-run
description="Nix daemon"
command=/nix/var/nix/profiles/default/bin/nix-daemon
command_background=true
pidfile=/run/nix-daemon.pid
output_log=/var/log/nix-daemon.log
error_log=/var/log/nix-daemon.log

depend() {
    need net
    use logger
}
EOF
            chmod +x /etc/init.d/nix-daemon
            success "  nix-daemon service file created"
        fi

        local services=(
            NetworkManager bluetooth elogind seatd sddm
            tlp thermald cupsd avahi-daemon docker pcscd sshd
            nix-daemon
        )
        for svc in "${services[@]}"; do
            rc-update add "$svc" default 2>/dev/null \
                && info "  enabled: $svc" \
                || warn "  skipped (not found): $svc"
        done
        success "OpenRC services configured"
    }

    configure_mdns() {
        require_root
        info "Configuring mDNS (avahi) in nsswitch…"
        if ! grep -q 'mdns_minimal' /etc/nsswitch.conf; then
            sed -i 's/^\(hosts:.*\)\(dns\)/\1mdns_minimal \2/' /etc/nsswitch.conf
            success "mDNS configured in nsswitch.conf"
        else
            success "mDNS already present in nsswitch.conf"
        fi
    }

    configure_sddm() {
        require_root
        info "Configuring SDDM…"
        mkdir -p /etc/sddm.conf.d
        cat > /etc/sddm.conf.d/artix.conf <<'EOF'
[Theme]
Current=

[Wayland]
SessionDir=/usr/share/wayland-sessions

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell
EOF
        success "SDDM configured"
    }

    configure_keyboard() {
        require_root
        info "Setting console keyboard to Colemak…"
        if [[ ! -f /etc/vconsole.conf ]] || ! grep -q 'KEYMAP=colemak' /etc/vconsole.conf; then
            cat > /etc/vconsole.conf <<'EOF'
KEYMAP=colemak
FONT=default8x16
EOF
        fi
        loadkeys colemak 2>/dev/null || warn "loadkeys not available (will apply after reboot)"
        success "Console keyboard configured"
    }

    configure_tlp() {
        require_root
        info "Writing TLP configuration (HP ProBook 450 G8 / Intel)…"
        cat > /etc/tlp.conf <<'EOF'
# TLP config — HP ProBook 450 G8 / Intel

CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave

CPU_ENERGY_PERF_POLICY_ON_BAT=power
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance

CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=20

CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

INTEL_GPU_MIN_FREQ_ON_AC=0
INTEL_GPU_MIN_FREQ_ON_BAT=0
INTEL_GPU_MAX_FREQ_ON_AC=1300
INTEL_GPU_MAX_FREQ_ON_BAT=600
INTEL_GPU_BOOST_FREQ_ON_AC=1300
INTEL_GPU_BOOST_FREQ_ON_BAT=600

# NOTE: HP ProBook 450 G8 doesn't support charge thresholds via TLP/hp-wmi.
# Use BIOS "HP Battery Health Manager" -> "Maximum battery health" for 80% limit.
START_CHARGE_THRESH_BAT0=40
STOP_CHARGE_THRESH_BAT0=80

PLATFORM_PROFILE_ON_AC=balanced
PLATFORM_PROFILE_ON_BAT=low-power

WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto

USB_AUTOSUSPEND=1
USB_EXCLUDE_AUDIO=1
USB_EXCLUDE_BTUSB=0
USB_EXCLUDE_PHONE=0
USB_EXCLUDE_PRINTER=1
USB_EXCLUDE_WWAN=0

SATA_LINKPWR_ON_AC=med_power_with_dipm
SATA_LINKPWR_ON_BAT=min_power

PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersupersave

WOL_DISABLE=Y

SOUND_POWER_SAVE_ON_AC=0
SOUND_POWER_SAVE_ON_BAT=1
SOUND_POWER_SAVE_CONTROLLER=Y

NMI_WATCHDOG=0
RUNTIME_PM_DRIVER_DENYLIST=""
USB_ALLOWLIST=""
EOF
        success "TLP configuration written"
    }

    configure_pam_u2f() {
        require_root
        info "Setting up PAM U2F for YubiKey…"
        warn "Enroll your YubiKey after setup:"
        warn "  mkdir -p ~/.config/Yubico && pamu2fcfg > ~/.config/Yubico/u2f_keys"
        for pam_file in /etc/pam.d/sudo /etc/pam.d/login; do
            if [[ -f "$pam_file" ]] && ! grep -q 'pam_u2f' "$pam_file"; then
                sed -i '0,/^auth/s//auth\tsufficient\tpam_u2f.so\nauth/' "$pam_file"
                info "  PAM U2F added to $pam_file"
            fi
        done
        success "PAM U2F configured"
    }

    # Run all root functions in order
    setup_user_groups
    enable_openrc_services
    configure_mdns
    configure_sddm
    configure_keyboard
    configure_tlp
    configure_pam_u2f
    exit 0
fi

# =============================================================================
# Normal (user) execution starts here — only reached when NOT --root-setup
# =============================================================================

USERNAME="${1:-tundra}"
CONFIG_DIR="/home/$USERNAME/.config/nix-config"
CONFIG_REPO="https://github.com/tundra-node/nix-config"

[[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]] \
    || die "Invalid username: $USERNAME"

# =============================================================================
# 1. UPDATE SYSTEM
# =============================================================================
setup_system() {
    info "Updating package database and system…"
    sudo pacman -Syu --noconfirm
    success "System updated"
}

# =============================================================================
# 2. INSTALL YAY (AUR helper)
# =============================================================================
install_yay() {
    if command -v yay &>/dev/null; then
        success "yay already installed"
        return
    fi
    info "Installing yay AUR helper…"
    sudo pacman -S --noconfirm --needed base-devel git
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    success "yay installed"
}

# =============================================================================
# 3. PACMAN PACKAGES
# =============================================================================
install_pacman_packages() {
    info "Installing system packages via pacman…"

    local base=(base-devel git wget curl nano)

    local init=(
        elogind              # logind replacement for OpenRC
        seatd                # seat management for Wayland
        polkit polkit-gnome  # privilege escalation
    )

    local shell=(zsh)

    local wayland=(
        niri
        sddm
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        qt5-wayland
        qt6-wayland
    )

    local audio=(pipewire pipewire-alsa pipewire-pulse wireplumber rtkit)

    local network=(networkmanager network-manager-applet networkmanager-openvpn)

    local bluetooth=(bluez bluez-utils blueman)

    local power=(tlp thermald powertop)

    local graphics=(mesa vulkan-intel intel-media-driver libva-intel-driver)

    local printing=(
        cups cups-pdf hplip gutenprint
        foomatic-db foomatic-db-engine
        avahi nss-mdns system-config-printer
    )

    local desktop=(thunar thunar-archive-plugin xfce4-terminal)

    local yubikey=(pcsclite libfido2)

    local containers=(docker docker-compose)

    local fonts=(ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji)

    local input=(libinput)

    local misc=(openssh)

    sudo pacman -S --noconfirm --needed \
        "${base[@]}" "${init[@]}" "${shell[@]}" "${wayland[@]}" \
        "${audio[@]}" "${network[@]}" "${bluetooth[@]}" "${power[@]}" \
        "${graphics[@]}" "${printing[@]}" "${desktop[@]}" "${yubikey[@]}" \
        "${containers[@]}" "${fonts[@]}" "${input[@]}" "${misc[@]}"

    success "Pacman packages installed"
}

# =============================================================================
# 4. AUR PACKAGES
# =============================================================================
install_aur_packages() {
    info "Installing AUR packages…"

    local aur_packages=(mullvad-vpn-bin)

    if [[ $EUID -eq 0 ]]; then
        su -c "yay -S --noconfirm --needed ${aur_packages[*]}" "$USERNAME"
    else
        yay -S --noconfirm --needed "${aur_packages[@]}"
    fi

    success "AUR packages installed"
}

# =============================================================================
# 5. INSTALL NIX (multi-user)
# =============================================================================
install_nix() {
    if command -v nix &>/dev/null; then
        success "Nix already installed"
        # Daemon may not be running even if nix binary exists — ensure it is
        _ensure_nix_daemon
        return
    fi

    info "Downloading Nix installer…"
    local installer=/tmp/nix-install.sh
    wget -qO "$installer" https://nixos.org/nix/install
    info "Installer saved to $installer — review it before proceeding."
    read -rp "Proceed with Nix installation? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || die "Nix installation cancelled."

    info "Installing Nix (multi-user)…"
    sudo sh "$installer" --daemon
    rm -f "$installer"

    # Source nix profile so nix commands are available in this shell
    # shellcheck source=/dev/null
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    # Nix installer doesn't support OpenRC so daemon won't be running yet.
    # Start it now and rely on the OpenRC service written by --root-setup for persistence.
    _ensure_nix_daemon

    success "Nix installed"
}

# Start nix-daemon if it isn't already running.
_ensure_nix_daemon() {
    if pgrep -x nix-daemon &>/dev/null; then
        success "nix-daemon already running"
        return
    fi

    info "Starting nix-daemon (OpenRC does not auto-start it after install)…"

    if [[ -f /etc/init.d/nix-daemon ]]; then
        sudo rc-service nix-daemon start 2>/dev/null || true
    else
        # Fallback: launch directly in background
        sudo /nix/var/nix/profiles/default/bin/nix-daemon &>/dev/null &
    fi

    # Wait up to 10 seconds for the daemon to be ready
    local retries=10
    while ! pgrep -x nix-daemon &>/dev/null && (( retries-- > 0 )); do
        sleep 1
    done

    if pgrep -x nix-daemon &>/dev/null; then
        success "nix-daemon started"
    else
        die "nix-daemon failed to start. Try manually: sudo nix-daemon &"
    fi
}

# =============================================================================
# 6. ENABLE NIX FLAKES
# =============================================================================
enable_nix_flakes() {
    info "Enabling Nix experimental features (flakes + nix-command)…"

    sudo mkdir -p /etc/nix
    if ! grep -q 'experimental-features' /etc/nix/nix.conf 2>/dev/null; then
        echo 'experimental-features = nix-command flakes' \
            | sudo tee -a /etc/nix/nix.conf > /dev/null
    fi

    mkdir -p "$HOME/.config/nix"
    if ! grep -q 'experimental-features' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
        echo 'experimental-features = nix-command flakes' \
            >> "$HOME/.config/nix/nix.conf"
    fi

    success "Nix flakes enabled"
}

# =============================================================================
# 7. INSTALL HOME MANAGER
# =============================================================================
install_home_manager() {
    if command -v home-manager &>/dev/null; then
        success "home-manager already installed"
        return
    fi

    info "Installing Home Manager…"
    nix-channel --add \
        https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz \
        home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install

    success "Home Manager installed"
}

# =============================================================================
# 8. CLONE CONFIG AND APPLY HOME MANAGER
# =============================================================================
apply_config() {
    info "Setting up nix-config…"

    if [[ -d "$CONFIG_DIR" ]]; then
        warn "$CONFIG_DIR already exists — skipping clone"
    else
        git clone "$CONFIG_REPO" "$CONFIG_DIR"
    fi

    git -C "$CONFIG_DIR" add . 2>/dev/null || true

    info "Applying Home Manager configuration…"
    # Re-source nix profile in case it dropped out of scope
    # shellcheck source=/dev/null
    [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]] \
        && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    home-manager switch --flake "$CONFIG_DIR#artix"

    success "Home Manager configuration applied"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════╗"
    echo -e "║  Artix Linux (OpenRC) + Niri setup       ║"
    echo -e "╚══════════════════════════════════════════╝${RESET}\n"

    info "Setting up Artix for user: $USERNAME"

    # Pacman + AUR (run as user)
    setup_system
    install_pacman_packages
    install_yay
    install_aur_packages

    # Root-only configuration — re-invokes this script with --root-setup flag.
    # That branch runs root functions then exits; main() never fires again.
    info "Running root configuration…"
    sudo bash "$SCRIPT_PATH" --root-setup "$USERNAME"
    success "Root configuration done"

    # User-level: Nix + Home Manager
    install_nix
    enable_nix_flakes
    install_home_manager
    apply_config

    echo ""
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════"
    echo -e "  Setup complete! Next steps:"
    echo -e "═══════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  1. ${BOLD}Enroll YubiKey${RESET} (if using U2F):"
    echo "       mkdir -p ~/.config/Yubico"
    echo "       pamu2fcfg > ~/.config/Yubico/u2f_keys"
    echo ""
    echo -e "  2. ${BOLD}Copy your wallpaper${RESET}:"
    echo "       cp /path/to/wallpaper.jpg $CONFIG_DIR/wallpapers/wallpaper.jpg"
    echo ""
    echo -e "  3. ${BOLD}Reboot${RESET} to start SDDM / OpenRC:"
    echo "       sudo reboot"
    echo ""
    echo -e "  4. At the SDDM login screen, select ${BOLD}Niri${RESET} as the session."
    echo ""
    echo -e "  5. ${BOLD}Update config later${RESET}:"
    echo "       hms   # home-manager switch --flake ~/.config/nix-config#artix"
    echo "       hmu   # nix flake update + home-manager switch"
    echo ""
    echo -e "${YELLOW}NOTE: GPU-accelerated apps (kitty, etc.) installed via Nix may"
    echo -e "need nixGL wrappers on non-NixOS if they fail with OpenGL errors:"
    echo -e "  https://github.com/nix-community/nixGL${RESET}"
    echo ""
}

main "$@"