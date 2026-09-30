#!/usr/bin/env bash
# Tundra screensaver.
#
# Renders the wordmark as FIGlet art, then plays it fullscreen on a dedicated
# special workspace where the art resolves out of a field of noise. Any keypress
# dismisses it, which is also what Hypridle's screensaver listener fires on
# timeout, so the sequence is: idle, art, a key, desktop.
#
# A special workspace is used rather than moving windows between monitors with
# `hyprctl keyword monitor ...,preferred`. Resizing the output is a lot easier to
# get half-right and leave the desktop in a bad state; the special workspace is
# toggled and cannot strand a monitor.
set -euo pipefail

WORKSPACE="${TUNDRA_SCREEN_WORKSPACE:-tundra-screensaver}"
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

command -v hyprctl >/dev/null 2>&1 || die "hyprctl is not available"
command -v foot >/dev/null 2>&1 || die "foot is not available"
[[ -x "$ASCII" ]] || die "missing $ASCII"
[[ -x "$EFFECT" ]] || die "missing $EFFECT"

# Never stack a second screensaver on top of a running one: a second fullscreen
# window would fight the first for the workspace and neither would clean up.
if hyprctl clients -j 2>/dev/null | grep -q "\"class\": *\"$APP_ID\""; then
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
    # The effect normally closes the workspace itself; this catches the case
    # where it died before it could.
    hyprctl dispatch exitspecialworkspace "$WORKSPACE" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# The wordmark is chosen fresh on every activation, so the screensaver rarely
# looks the same twice in a row.
if [[ "$STYLE" == random ]]; then
    "$ASCII" --random "$WORD" >"$art_file"
else
    "$ASCII" --font "$STYLE" "$WORD" >"$art_file"
fi

# hyprctl dispatch exec runs the command in the compositor's environment, not
# ours, so the theme colours have to be passed through explicitly.
env_prefix=""
for var in TUNDRA_SCREEN_RAIN TUNDRA_SCREEN_RAIN_DIM TUNDRA_SCREEN_INK \
    TUNDRA_SCREEN_GLINT TUNDRA_SCREEN_FPS TUNDRA_SCREEN_CYCLE TUNDRA_GAWK; do
    [[ -n "${!var:-}" ]] && env_prefix+="$var=${!var} "
done
env_prefix+="TUNDRA_SCREEN_WORKSPACE=$WORKSPACE TUNDRA_FIGLET=$FIGLET "

# -T sets the window title and --app-id the class, which is how the singleton
# check above recognises its own window.
hyprctl dispatch exec \
    "[workspace special:$WORKSPACE silent; float; exec $env_prefix foot --app-id=$APP_ID -T $APP_ID $EFFECT $art_file]" \
    >/dev/null

# The workspace has to be shown after the window is mapped, otherwise the toggle
# races the exec and nothing appears.
for _ in $(seq 1 50); do
    if hyprctl clients -j 2>/dev/null | grep -q "\"class\": *\"$APP_ID\""; then
        break
    fi
    sleep 0.05
done

if ! hyprctl clients -j 2>/dev/null | grep -q "\"class\": *\"$APP_ID\""; then
    die "the screensaver window did not start"
fi

hyprctl dispatch togglespecialworkspace "$WORKSPACE" >/dev/null
sleep 0.2
hyprctl dispatch fullscreen 1 >/dev/null
