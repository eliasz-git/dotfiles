#!/usr/bin/env bash
# Lock the screen with swaylock.
#
# The themable half lives in ~/.config/tundra/colors/swaylock.conf, written by
# tundra-theme-apply: an associative list of extra swaylock flags (colours,
# clock, fonts). This wrapper owns the structure (blank the screen behind a
# blurred screenshot) and the fragment owns the colours, so a theme switch
# recolours the lock without touching the wrapper.
set -euo pipefail

# Do not lock while a client is in fullscreen. Video and media players are
# usually fullscreen and should keep the screen awake.
if mmsg get all-clients 2>/dev/null | grep -q "\"is_fullscreen\":true"; then
    exit 0
fi

fragment="$HOME/.config/tundra/colors/swaylock.conf"
flags=()
if [[ -r "$fragment" ]]; then
    # shellcheck source=/dev/null
    source "$fragment"
    flags=("${SWAYLOCK_FLAGS[@]:-}")
fi

exec swaylock --screenshots --effect-blur=7x5 "${flags[@]}"