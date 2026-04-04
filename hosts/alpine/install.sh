#!/usr/bin/env bash
# =============================================================================
#  Alpine Linux (OpenRC) setup script
#  HP ProBook 450 G8 — Gruvbox Dark / Sway / Nix + home-manager
#
#  Usage (as your user, with doas access):
#    chmod +x ~/.config/nix-config/hosts/alpine/install.sh
#    bash ~/.config/nix-config/hosts/alpine/install.sh
#
#  Run AFTER a fresh Alpine install with:
#    - setup-alpine completed (sys install)
#    - User account created and added to wheel
#    - Network connected (nmtui / setup-interfaces)
#    - Community repo enabled in /etc/apk/repositories
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'  GRN='\033[0;32m'  YEL='\033[1;33m'
CYN='\033[0;36m'  BLD='\033[1m'     RST='\033[0m'

info()    { echo -e "${CYN}${BLD}[INFO]${RST} $*"; }
ok()      { echo -e "${GRN}${BLD}[ OK ]${RST} $*"; }
warn()    { echo -e "${YEL}${BLD}[WARN]${RST} $*"; }
die()     { echo -e "${RED}${BLD}[ERR ]${RST} $*" >&2; exit 1; }

# ── Privilege helper — doas only, no sudo ────────────────────────────────────
# (sudo is installed purely as a shim for the Nix multi-user installer)
#need_root() { doas "wind"; }

USERNAME="wind"
CONFIG_DIR="/home/wind/.config/nix-config"
CONFIG_REPO="https://github.com/tundra-node/nix-config"

# =============================================================================
#  PHASE 1 — System packages (APK)
#  APK owns: kernel, init, Wayland compositor, audio, drivers, PAM.
#  Nix owns: every user-facing tool (see hosts/alpine/home.nix).
# =============================================================================
install_apk_packages() {
  info "Updating APK..."
  doas apk update
  doas apk upgrade

  info "Installing system packages..."

  # Core / shell
  doas apk add \
    bash zsh git curl wget rsync openssh \
    doas sudo \
    util-linux pciutils usbutils \
    man-db man-pages less which

  # Wayland / Sway (system compositor — NOT managed by Nix)
  doas apk add \
    seatd dbus dbus-openrc \
    sway swaybg swaylock swayidle \
    xwayland \
    waybar \
    foot \
    fuzzel \
    mako \
    grim slurp wl-clipboard \
    xdg-user-dirs \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    polkit polkit-elogind

  # Audio (PipeWire stack — OpenRC services, not systemd units)
  doas apk add \
    pipewire pipewire-alsa pipewire-pulse \
    wireplumber \
    alsa-utils

  # Network
  doas apk add \
    iwd wpa_supplicant \
    networkmanager networkmanager-tui networkmanager-wifi

  # Intel hardware (ProBook 450 G8: i7-1165G7, Iris Xe)
  doas apk add \
    mesa-dri-gallium \
    intel-media-driver \
    linux-firmware-intel \
    brightnessctl \
    acpid zzz tlp

  # YubiKey (udev rules + PAM at system level)
  doas apk add \
    yubikey-manager libfido2 pam-u2f \
    ccid pcsc-lite pcsc-lite-libs \
    gnupg gnupg-scdaemon

  # Fonts available before Nix activates (Sway/Waybar need them at boot)
  doas apk add \
    font-jetbrains-mono-nerd font-noto-emoji \
    adwaita-icon-theme gtk-murrine-engine

  # Ly display manager (APK 0.6.0 — newer version is in nixpkgs but cannot
  # be used here: Ly runs as root before any user nix profile is mounted)
#  doas apk add ly ly-openrc

  ok "APK packages installed"
}

# =============================================================================
#  PHASE 2 — OpenRC services
# =============================================================================
enable_services() {
  info "Enabling OpenRC services..."

  # udev — required for input devices to be visible to Sway
  doas rc-update add udev         sysinit || true
  doas rc-update add udev-trigger sysinit || true
  doas rc-update add udev-settle  sysinit || true

  # seatd — Wayland seat manager
  doas rc-update add seatd        default || true

  # dbus — required by polkit and desktop portals
  doas rc-update add dbus         default || true

  # Network
  doas rc-update add iwd          default || true
  doas rc-update add networkmanager default || true

  # Hardware / power
  doas rc-update add acpid        default || true
  doas rc-update add tlp          default || true

  # YubiKey smartcard daemon
  doas rc-update add pcscd        default || true

  # Ly display manager (replaces agetty on tty2)
  doas rc-update add ly           default || true
  # Disable the getty that owns tty2 so Ly can take it
  doas rc-update del agetty.tty2  default 2>/dev/null || \
    warn "agetty.tty2 not in runlevel — check /etc/inittab manually"

  # Start services now so we don't need to reboot before testing
  doas rc-service udev         start || true
  doas rc-service udev-trigger start || true
  doas rc-service seatd        start || true
  doas rc-service dbus         start || true
  doas rc-service pcscd        start || true

  ok "Services enabled"
}

# =============================================================================
#  PHASE 3 — User groups
# =============================================================================
setup_groups() {
  info "Adding $USERNAME to required groups..."
  for grp in wheel video audio input seat; do
    doas addgroup "$USERNAME" "$grp" 2>/dev/null || true
  done
  ok "Groups configured"
}

# =============================================================================
#  PHASE 4 — doas config
# =============================================================================
setup_doas() {
  info "Configuring doas..."

  # Create /etc/doas.d if it doesn't exist
  doas mkdir -p /etc/doas.d

  # Wheel group gets full doas access (prompts for password)
  if ! grep -q 'permit.*wheel' /etc/doas.conf 2>/dev/null; then
    doas tee /etc/doas.conf > /dev/null << 'EOF'
# /etc/doas.conf
permit keepenv :wheel
EOF
    ok "doas.conf written"
  else
    ok "doas.conf already configured"
  fi

  # Passwordless suspend — zzz (replaces sudo-based solution)
  doas tee /etc/doas.d/zzz.conf > /dev/null << 'EOF'
permit nopass :wheel cmd /usr/sbin/zzz
EOF
  doas chmod 400 /etc/doas.d/zzz.conf

  # Passwordless /run/user creation — needed in ~/.profile
  doas tee /etc/doas.d/run-user.conf > /dev/null << 'EOF'
permit nopass :wheel cmd /bin/mkdir args -p /run/user
permit nopass :wheel cmd /bin/chown
permit nopass :wheel cmd /bin/chmod
EOF
  doas chmod 400 /etc/doas.d/run-user.conf

  ok "doas configured"
}

# =============================================================================
#  PHASE 5 — /run/user directory
# =============================================================================
setup_runtime_dir() {
  info "Creating /run/user/$UID..."
  RUN_DIR="/run/user/$(id -u)"
  doas mkdir -p "$RUN_DIR"
  doas chown "$(id -un):$(id -gn)" "$RUN_DIR"
  doas chmod 0700 "$RUN_DIR"
  export XDG_RUNTIME_DIR="$RUN_DIR"
  ok "/run/user/$(id -u) ready"
}

# =============================================================================
#  PHASE 6 — YubiKey udev rules
# =============================================================================
setup_yubikey() {
  info "Writing YubiKey udev rules..."
  doas tee /etc/udev/rules.d/70-yubikey.rules > /dev/null << 'UDEV'
# YubiKey OTP + FIDO (HID)
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", MODE="0660", GROUP="input"
# YubiKey CCID (smartcard / GPG)
SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", MODE="0660", GROUP="input"
UDEV
  doas udevadm control --reload-rules || true
  doas udevadm trigger               || true

  info "Registering YubiKey U2F (plug it in and touch it when prompted)..."
  mkdir -p "/home/wind/.config/Yubico"
  pamu2fcfg > "/home/wind/.config/Yubico/u2f_keys" \
    && ok  "U2F key registered at ~/.config/Yubico/u2f_keys" \
    || warn "pamu2fcfg failed — run later: pamu2fcfg > ~/.config/Yubico/u2f_keys"

  ok "YubiKey configured"
}

# =============================================================================
#  PHASE 7 — Download wallpaper
# =============================================================================
download_wallpaper() {
  info "Downloading Gruvbox wallpaper..."
  mkdir -p "/home/wind/Pictures/wallpapers"
  WALL="/home/wind/Pictures/wallpapers/gruvbox.png"
  if curl -fsSL \
    "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/minimalistic/gruvbox-triangles.png" \
    -o "$WALL" 2>/dev/null; then
    ok "Wallpaper saved to $WALL"
  else
    warn "Download failed — Sway will use solid #1d2021 fallback"
    warn "Update output line in ~/.config/sway/config when you have a wallpaper"
  fi
}

# =============================================================================
#  PHASE 8 — Install Nix (Determinate Systems, OpenRC init)
# =============================================================================
install_nix() {
  if command -v nix >/dev/null 2>&1; then
    ok "Nix already installed — skipping"
    _source_nix
    return
  fi

  info "Installing Nix (Determinate Systems, --init openrc)..."
  info "NOTE: The Nix installer uses sudo internally. sudo is installed as a shim."

  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install linux \
        --init none \
        --no-confirm \
        --extra-conf "experimental-features = nix-command flakes"

  _source_nix
  ok "Nix installed"
}

_source_nix() {
  # single-user profile
  if [ -e "/home/wind/.nix-profile/etc/profile.d/nix.sh" ]; then
    # shellcheck source=/dev/null
    . "/home/wind/.nix-profile/etc/profile.d/nix.sh"
    ok "Sourced /home/wind/.nix-profile/etc/profile.d/nix.sh"
    return
  fi

  # multi-user (daemon) profile (fallback)
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck source=/dev/null
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    ok "Sourced /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    return
  fi

  warn "No nix profile found to source — you may need to re-login or run the installer manually"
}

# =============================================================================
#  PHASE 9 — Clone / update nix-config repo
# =============================================================================
setup_config_repo() {
  if [ -d "$CONFIG_DIR" ]; then
    ok "nix-config already at $CONFIG_DIR — skipping clone"
  else
    info "Cloning nix-config..."
    git clone "$CONFIG_REPO" "$CONFIG_DIR"
    ok "Cloned to $CONFIG_DIR"
  fi

  # Ensure nix sees tracked files
  git -C "$CONFIG_DIR" add . 2>/dev/null || true
}

# =============================================================================
#  PHASE 10 — Run home-manager
# =============================================================================
apply_home_manager() {
  info "Running home-manager switch (first run — downloads nixpkgs, takes a while)..."
  info "Coffee break recommended ☕"

  _source_nix

  nix run "github:nix-community/home-manager/release-25.05" -- \
    switch --flake "$CONFIG_DIR#alpine"

  ok "home-manager switch complete"
}

# =============================================================================
#  PHASE 5b — Ly display manager
#  Installed via APK (community repo) — simpler and correct for a system
#  display manager that runs as root before any user nix profile exists.
#  The nixpkgs version (1.3.2) is newer but cannot integrate with OpenRC
#  as a system service from a user-level nix profile.
# =============================================================================
build_ly() {
  # Nothing to build — ly + ly-openrc installed by install_apk_packages()
  ok "Ly installed via APK (ly + ly-openrc)"
}

setup_ly() {
  info "Configuring Ly..."

  doas mkdir -p /etc/ly

  # Write Ly config — Gruvbox Dark colours where supported
  doas tee /etc/ly/config.ini > /dev/null << 'LYCONF'
# Ly display manager config
# /etc/ly/config.ini

# TTY Ly runs on (must match the agetty you disabled)
tty = 2

# Behaviour
animate = true
hide_borders = false
load = true
save = true
clear_password = true
numlock = false

# Clock in top-right (strftime format)
clock = %a %d %b  %H:%M

# Gruvbox Dark terminal palette
# Ly uses standard terminal colour indices — set via the palette below.
# 0=black 1=red 2=green 3=yellow 4=blue 5=purple 6=aqua 7=white
# bg = colour index used for background (0 = black / gb-bg)
# fg = colour index used for foreground (7 = white / gb-fg)
bg = 0
fg = 3

# Input box colours (3=yellow, 0=black)
input_fg = 3
input_bg = 0

# Text colours
label_fg = 7
label_bg = 0

# Border colour (3=yellow)
border_fg = 3
border_bg = 0

# Log paths
log = /var/log/ly.log
session_log = /home/$USER/.local/state/ly-session.log

# Wayland sessions dir
wayland_sessions = /usr/share/wayland-sessions
x11_sessions = /usr/share/xsessions
LYCONF

  ok "Ly config written to /etc/ly/config.ini"

  # Disable the agetty that normally owns tty2 in /etc/inittab
  # Alpine uses /etc/inittab for getty spawning
  if grep -q "^tty2::" /etc/inittab 2>/dev/null; then
    doas sed -i 's|^tty2::|#tty2::|' /etc/inittab
    ok "tty2 getty disabled in /etc/inittab"
  else
    warn "tty2 line not found in /etc/inittab — it may already be disabled"
    warn "Check manually: grep tty2 /etc/inittab"
  fi

  # Remove ~/.profile auto-start of Sway (Ly launches it via .desktop)
  # Ly reads /usr/share/wayland-sessions/sway.desktop — no profile hack needed
  if grep -q "exec sway" "/home/wind/.profile" 2>/dev/null; then
    sed -i '/# Auto-start Sway on tty1 login/,/^fi$/d' "/home/wind/.profile" || true
    ok "Removed tty1 auto-start from ~/.profile (Ly handles session launch now)"
  fi

  ok "Ly configured"
}


# =============================================================================
#  MAIN
# =============================================================================
main() {
  echo ""
  echo -e "${BLD}${CYN}╔══════════════════════════════════════════════╗"
  echo -e "║  Alpine Linux — Gruvbox Dark / Sway / Nix   ║"
  echo -e "║  HP ProBook 450 G8 setup                    ║"
  echo -e "╚══════════════════════════════════════════════╝${RST}"
  echo ""
  info "Running as: $USERNAME"
  info "Config dir: $CONFIG_DIR"
  echo ""

  install_apk_packages
  enable_services
  setup_groups
  setup_doas
  setup_runtime_dir
  setup_yubikey
  download_wallpaper
  build_ly
  setup_ly
  install_nix
  setup_config_repo
  apply_home_manager

  # Set zsh as default shell (home-manager enables it, but shell must be set)
  if ! grep -q "$(which zsh)" /etc/passwd 2>/dev/null; then
    doas chsh -s /bin/zsh "$USERNAME" || \
      warn "chsh failed — run: doas chsh -s /bin/zsh $USERNAME"
  fi

  echo ""
  echo -e "${GRN}${BLD}╔══════════════════════════════════════════════╗"
  echo -e "║  Done!                                       ║"
  echo -e "╚══════════════════════════════════════════════╝${RST}"
  echo ""
  echo "  Reboot — Ly display manager will appear on tty2."
  echo ""
  echo "  Key binds:"
  echo "    Terminal:     Super + Enter"
  echo "    Browser:      Super + B"
  echo "    Files:        Super + E"
  echo "    WiFi TUI:     Super + N   (impala)  or: wifi"
  echo "    Launcher:     Super + D"
  echo "    Lock:         Super + Escape"
  echo ""
  echo "  Nix / home-manager:"
  echo "    hms   — home-manager switch"
  echo "    hmu   — flake update + switch"
  echo "    nsp   — nix shell nixpkgs#<pkg>"
  echo "    ndev  — nix develop (per-project shell)"
  echo ""
  echo "  Network:        wifi  (nmcli TUI)   or  net  (impala)"
  echo "  USB:            usb   (mount helper)"
  echo ""
  echo "  Update git email in ~/.config/nix-config/hosts/alpine/home.nix"
  echo "  then run hms to apply."
  echo ""
  echo -e "${YEL}  YubiKey GPG/SSH:  gpg --card-edit${RST}"
  echo -e "${YEL}  PAM U2F doas:     add to /etc/pam.d/doas:${RST}"
  echo "    auth sufficient pam_u2f.so authfile=~/.config/Yubico/u2f_keys cue"
  echo ""
  echo -e "${YEL}  Librewolf tab bar: copy ~/.librewolf/userChrome-template.css${RST}"
  echo "  to ~/.librewolf/PROFILE/chrome/userChrome.css"
  echo "  set toolkit.legacyUserProfileCustomizations.stylesheets=true"
  echo ""
}

main "$@"
