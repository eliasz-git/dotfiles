#!/usr/bin/env bash
# tundra-focus-tag — one shared workspace list across both displays.
#
# dwl/mango semantics: every monitor keeps its own selected tagset, so
# `view,N` on the focused monitor opens a *second* workspace N there even
# when workspace N already lives on the other display. This script gives
# the Hyprland/GNOME model instead — there is only ONE workspace 3:
#
#   tundra-focus-tag 3      (bind: SUPER+3)
#     - The other display is viewing workspace 3 → focus moves there;
#       no duplicate workspace 3 is created here.
#     - This display is already viewing it → stay put.
#     - Nobody is viewing it → claim it on this display.
#
#   tundra-focus-tag -m 3   (bind: SUPER+SHIFT+3)
#     Send the focused window to workspace 3 wherever it lives.
#
#   tundra-focus-tag -M [3]
#     Move workspace 3 (default: the workspace this display is showing)
#     to the other display and follow it.
#
# Needs mmsg and jq on the session PATH. All state is read once at the
# start so we make exactly two IPC round trips (one get, one dispatch),
# keeping load on mango's IPC minimal.
set -euo pipefail

usage() {
  echo "usage: tundra-focus-tag [-m] <1-9> | tundra-focus-tag -M [1-9]" >&2
  exit 1
}

mode=focus
case "${1:-}" in
  -m) mode=move; shift ;;
  -M) mode=move-workspace; shift ;;
esac
tag="${1:-}"

# ── Read all state once ───────────────────────────────────────────────
monitors=$(mmsg get all-monitors)
clients=$(mmsg get all-clients)

if [[ "$mode" == move-workspace && -z "$tag" ]]; then
  tag=$(jq -r '.monitors[] | select(.active) | .active_tags[0]' <<<"$monitors")
fi
[[ "$tag" =~ ^[1-9]$ ]] || usage

# For -M (move-workspace), "this display" is the keyboard-focus monitor
# that owns the tag being moved. For focus/move modes, target the pointer
# monitor so workspaces are created/claimed where the cursor is.
if [[ "$mode" == move-workspace ]]; then
  current=$(jq -r '[.monitors[] | select(.active).name][0]' <<<"$monitors")
else
  current=$(mmsg get cursorpos | jq -r '.monitor // empty')
fi
[[ -n "$current" && "$current" != "null" ]] || exit 0
other=$(jq -r --arg c "$current" '[.monitors[] | select(.name != $c).name][0]' <<<"$monitors")

# ── Query helpers over cached state ───────────────────────────────────
views_tag() { # prints "yes" when monitor $1 is currently viewing $tag
  jq -r --arg m "$1" --arg t "$tag" '
    [.monitors[]
      | select(.name == $m)
      | .active_tags | map(tostring) | index($t)][0]
    | if . != null then "yes" else "no" end' <<<"$monitors"
}

monitor_that_views_tag() { # prints the monitor viewing $tag, or empty
  jq -r --arg t "$tag" '
    [.monitors[]
      | select((.active_tags | map(tostring) | index($t)) != null)
      | .name][0]' <<<"$monitors"
}

monitor_with_tag_clients() { # prints the monitor with clients tagged $tag, or empty
  jq -r --arg t "$tag" '
    [.clients[]
      | select((.tags | map(tostring) | index($t)) != null)
      | .monitor][0]' <<<"$clients"
}

# ── -M: move whole workspace to the other display ─────────────────────
if [[ "$mode" == move-workspace ]]; then
  [[ -n "${other:-}" ]] || exit 0
  fallback=$([[ "$tag" == 1 ]] && echo 2 || echo 1)

  # Migrate every client tagged $tag onto the other monitor.
  mmsg get all-clients |
    jq -r --arg t "$tag" --arg d "$other" '
      .clients[]
      | select((.tags | map(tostring) | index($t)) != null)
      | select(.monitor != $d)
      | "\(.monitor) \(.id)"' |
    while read -r mon id; do
      mmsg dispatch "tagmon,$other,$tag" "client,$id"
    done

  # If this display was showing it, go back to this display's previous
  # workspace. The other display's workspace stays there, hidden.
  if [[ "$(views_tag "$current")" == "yes" ]]; then
    mmsg dispatch "focusmon,$current"
    mmsg dispatch "view,-1"
    if mmsg get all-monitors | jq -e --arg m "$current" --arg t "$tag" \
      'any(.monitors[] | select(.name == $m) | .active_tags[]; tostring == $t)' >/dev/null; then
      mmsg dispatch "view,$fallback"
    fi
  fi

  # Show the moved workspace on the other display and follow it.
  if [[ "$(views_tag "$other")" != "yes" ]]; then
    mmsg dispatch "viewcrossmon,$tag,$other"
  fi
  mmsg dispatch "focusmon,$other"
  exit 0
fi

# ── -m: send focused window to workspace $tag ─────────────────────────
if [[ "$mode" == move ]]; then
  if [[ -n "${other:-}" && "$(views_tag "$other")" == "yes" ]]; then
    mmsg dispatch "tagcrossmon,$tag,$other"
    mmsg dispatch "focusmon,$current"
  else
    mmsg dispatch "tag,$tag"
  fi
  exit 0
fi

# ── Focus/claim only — never drag a workspace between displays here ────
#
# Priority:
#   1. A monitor is already viewing the tag → focus that monitor.
#   2. A monitor has clients tagged $tag (but isn't viewing it) → go there
#      and view the tag. (Steam on tag 7 of main while main views tag 3.)
#   3. Cursor monitor already viewing it → stay put.
#   4. Nobody has it → create it on the cursor monitor.
viewing=$(monitor_that_views_tag)
if [[ -n "$viewing" && "$viewing" != "null" ]]; then
  mmsg dispatch "focusmon,$viewing"
elif [[ -n "$(monitor_with_tag_clients)" && "$(monitor_with_tag_clients)" != "null" ]]; then
  target=$(monitor_with_tag_clients)
  mmsg dispatch "viewcrossmon,$tag,$target"
elif [[ "$(views_tag "$current")" == "yes" ]]; then
  : # already viewing it on this display; stay put
else
  mmsg dispatch "viewcrossmon,$tag,$current"
fi
