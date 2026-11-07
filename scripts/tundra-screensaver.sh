#!/usr/bin/env bash
# Tundra screensaver.
#
# Renders the wordmark as FIGlet art, then plays it fullscreen on the special
# overlay (tag 0) where the art resolves out of a field of noise. Any keypress
# dismisses it, which is also what swayidle's screensaver listener fires on
# timeout, so the sequence is: idle, art, a key, desktop.
#
# A window rule (see modules/nixos/mango/looknfeel.nix) opens the art window on
# tag 0 silently and fullscreen; this script only checks a singleton is not
# running, spawns the effect, waits for it to map, and reveals the special
# overlay. When the last special window closes, mango leaves the overlay again
# on its own, so there is nothing to tear down on a normal exit.
set -euo pipefail

APP_ID="tundra-screensaver"
WORD="${TUNDRA_SCREEN_WORD:-tundra}"
STYLE="${TUNDRA_SCREEN_STYLE:-random}"

resolve() {
    readlink -f "$1" 2>/dev/null || printf '%s' "$1"
}

SCRIPT_PATH="$(resolve "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
ASCII="$SCRIPT_DIR/tundra-ascii.sh"
EFFECT="$SCRIPT_DIR/tundra-screensaver-effect.sh"

die() {
    echo "tundra-screensaver: $*" >&2
    exit 1
}

command -v mmsg >/dev/null 2>&1 || die "mmsg is not available"
command -v foot >/dev/null 2>&1 || die "foot is not available"
[[ -x "$ASCII" ]] || die "missing $ASCII"
[[ -x "$EFFECT" ]] || die "missing $EFFECT"

# Never stack a second screensaver on top of a running one: a second window on
# the special overlay would fight the first for the tag and neither would
# clean up.
if mmsg get all-clients 2>/dev/null | grep -q "\"appid\":\"$APP_ID\""; then
    exit 0
fi

# Figlet is not on the interactive PATH in a fresh session, so fall back to the
# profile-provided binary when the plain name is missing.
FIGLET="${TUNDRA_FIGLET:-figlet}"
if ! command -v "$FIGLET" >/dev/null 2>&1; then
    [[ -n "${TUNDRA_FIGLET:-}" ]] || die "figlet is not available; set TUNDRA_FIGLET"
fi

art_file="$(mktemp -t tundra-screensaver.XXXXXX.flf)"
cleanup() {
    rm -f "$art_file"
    # If the effect never ran to completion its window is still registered and
    # visible, so put the special overlay away again to leave the desktop clean.
    # When the effect exits normally, mango returns from the overlay by itself
    # once the last special window closes.
    # The window's own is_visible flag always lies within 200 characters after
    # its appid, well before any other client's object begins, so this cannot
    # mistake another focused window for the screensaver.
    if mmsg get all-clients 2>/dev/null |
        grep -qE "\"appid\":\"$APP_ID\".{0,200}\"is_visible\":true"; then
        mmsg dispatch toggle_special_tag >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

# The wordmark is chosen fresh on every activation, so the screensaver rarely
# looks the same twice in a row.
if [[ "$STYLE" == random ]]; then
    "$ASCII" --random "$WORD" >"$art_file"
else
    "$ASCII" --font "$STYLE" "$WORD" >"$art_file"
fi

# mmsg dispatch spawn_shell runs the command through `sh -c` in the compositor's
# environment, not ours, so the theme colours have to be passed explicitly.
env_prefix=""
for var in TUNDRA_SCREEN_RAIN TUNDRA_SCREEN_RAIN_DIM TUNDRA_SCREEN_INK \
    TUNDRA_SCREEN_GLINT TUNDRA_SCREEN_FPS TUNDRA_SCREEN_CYCLE TUNDRA_GAWK; do
    [[ -n "${!var:-}" ]] && env_prefix+="$var=${!var} "
done
env_prefix+="TUNDRA_FIGLET=$FIGLET "

# -T sets the window title and --app-id the class, which the window rule and the
# singleton check above recognise. The rule maps the window to tag 0 silently
# and fullscreen, so the plain spawn is all that is needed here.
mmsg dispatch "spawn_shell,${env_prefix}foot --app-id=$APP_ID -T $APP_ID $EFFECT $art_file" \
    >/dev/null

# The overlay has to be shown after the window is mapped, otherwise the toggle
# races the spawn and nothing appears.
for _ in $(seq 1 50); do
    if mmsg get all-clients 2>/dev/null | grep -q "\"appid\":\"$APP_ID\""; then
        break
    fi
    sleep 0.05
done

if ! mmsg get all-clients 2>/dev/null | grep -q "\"appid\":\"$APP_ID\""; then
    die "the screensaver window did not start"
fi

mmsg dispatch toggle_special_tag >/dev/null