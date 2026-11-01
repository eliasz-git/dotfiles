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
#     In every case, stray tag-N windows stranded on the other display
#     (window_rule spawns are pinned to a monitor) are gathered onto the
#     display that is viewing workspace N, so the workspace arrives whole.
#
#   tundra-focus-tag -m 3   (bind: SUPER+SHIFT+3)
#     Send the focused window to workspace 3 wherever it lives: across to
#     the other display if that is where workspace 3 is being viewed,
#     otherwise onto workspace 3 on this display (it surfaces the next
#     time workspace 3 is summoned). Focus stays here either way.
#
#   tundra-focus-tag -M [3]
#     Move workspace 3 (default: the workspace this display is showing) to
#     the other display and follow it. Every window on 3 goes with it. If
#     this display was showing 3, it returns to its previous workspace; the
#     other display's old workspace stays there, hidden. No index is
#     duplicated. If 3 is already on the other display, just focus it
#     (repairing a duplicate if both show it). If 3 is hidden, show it on
#     the other display and leave this one alone.
#
# Needs mmsg (mango IPC) and jq on the session PATH. mmsg requires
# MANGO_INSTANCE_SIGNATURE, which keybind spawns inherit from the session.
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

monitors=$(mmsg get all-monitors)
if [[ "$mode" == move-workspace && -z "$tag" ]]; then
  tag=$(jq -r '.monitors[] | select(.active) | .active_tags[0]' <<<"$monitors")
fi
[[ "$tag" =~ ^[1-9]$ ]] || usage

current=$(jq -r '[.monitors[] | select(.active).name][0]' <<<"$monitors")
[[ -n "$current" && "$current" != "null" ]] || exit 0
other=$(jq -r --arg c "$current" '[.monitors[] | select(.name != $c).name][0]' <<<"$monitors")

views_tag() { # prints "yes" when monitor $1 is currently viewing $tag
  mmsg get all-monitors |
    jq -r --arg m "$1" --arg t "$tag" '
      [.monitors[]
        | select(.name == $m)
        | .active_tags | map(tostring) | index($t)][0]
      | if . != null then "yes" else "no" end'
}

move_tag_clients() { # migrate every client tagged $1 onto monitor $2
  local t=$1 dest=$2 mon id
  mmsg get all-clients |
    jq -r --arg t "$t" --arg d "$dest" '
      .clients[]
      | select((.tags | map(tostring) | index($t)) != null)
      | select(.monitor != $d)
      | "\(.monitor) \(.id)"' |
    while read -r mon id; do
      mmsg dispatch "tagmon,$dest,$t" "client,$id"
    done
  if [[ "$(views_tag "$dest")" != "yes" ]]; then
    mmsg dispatch "viewcrossmon,$t,$dest"
  fi
}

gather_home() { # migrate stray tag-$tag clients onto the display viewing them
  move_tag_clients "$tag" "$1"
}

if [[ "$mode" == move-workspace ]]; then
  [[ -n "${other:-}" ]] || exit 0
  fallback=$([[ "$tag" == 1 ]] && echo 2 || echo 1)

  # Move the whole workspace, not just the focused window.
  move_tag_clients "$tag" "$other"

  # If this display was showing it, go back to this display's previous
  # workspace. Do not pull the other display's workspace over here: its
  # windows stay on that display, hidden, ready to be summoned again.
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

if [[ "$mode" == move ]]; then
  if [[ -n "${other:-}" && "$(views_tag "$other")" == "yes" ]]; then
    mmsg dispatch "tagcrossmon,$tag,$other"
    # tagcrossmon may follow the window; bounce focus back so the caller
    # keeps looking at this display. When it does not follow, this is a
    # no-op (this display is already focused).
    mmsg dispatch "focusmon,$current"
  else
    mmsg dispatch "tag,$tag"
  fi
  exit 0
fi

if [[ -n "${other:-}" && "$(views_tag "$other")" == "yes" ]]; then
  gather_home "$other"
  mmsg dispatch "focusmon,$other"
elif [[ "$(views_tag "$current")" == "yes" ]]; then
  gather_home "$current"
else
  mmsg dispatch "view,$tag"
  gather_home "$current"
fi
