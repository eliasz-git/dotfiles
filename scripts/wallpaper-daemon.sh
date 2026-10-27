#!/usr/bin/env bash
# Rotate painting wallpapers and hide the desktop background during fullscreen.
#
# One swaybg instance is run per monitor instead of a single global one. A single
# swaybg paints every output it is started for, so taking it down to hide the
# background behind a fullscreen window blanked *all* monitors. Scoping the
# process to `-o <output>` lets a fullscreen window hide only its own monitor,
# while the other displays keep their wallpaper.
set -euo pipefail

WALLPAPER_DIR="${TUNDRA_WALLPAPER_DIR:-${HOME}/.config/nix-config/wallpapers}"
INTERVAL="${TUNDRA_WALLPAPER_INTERVAL:-900}"
CHECK_INTERVAL="${TUNDRA_WALLPAPER_CHECK_INTERVAL:-5}"
REQUEST_FILE="$WALLPAPER_DIR/.wallpaper-request"
# Records which image is on screen. The SDDM greeter has no way to ask swaybg,
# so it reads this at login to show a matching background.
POINTER_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/tundra/wallpaper"

# Home Manager links each wallpaper into ~/.local/share/tundra/wallpapers as a
# symlink to the store, so these are links rather than regular files. Match both,
# otherwise find turns up nothing and the rotation silently falls back to
# wallpaper.jpg forever.
mapfile -t WALLPAPERS < <(
  find "$WALLPAPER_DIR" -maxdepth 1 \( -type f -o -type l \) \
    \( -iname '*-*.jpg' -o -iname '*-*.jpeg' -o -iname '*-*.png' -o -iname '*-*.webp' \) \
    ! -iname 'wallpaper_backup_*' ! -iname '*.backup' | sort
)

if ((${#WALLPAPERS[@]} == 0)); then
  WALLPAPERS=("$WALLPAPER_DIR/wallpaper.jpg")
fi

if [[ "${1:-}" == "--self-test" ]]; then
  for image in "${WALLPAPERS[@]}"; do
    [[ -s "$image" ]] || { echo "missing or empty wallpaper: $image" >&2; exit 1; }
  done
  printf 'wallpaper daemon self-test: %d readable asset(s) in %s\n' "${#WALLPAPERS[@]}" "$WALLPAPER_DIR"
  exit 0
fi

# swaybg PID per output name, e.g. wallpaper_pids[HDMI-A-1]=12345.
declare -A wallpaper_pids=()
current_index=-1
current_image=""
last_change=0

# Write the pointer atomically so a reader never sees a half-written path.
write_pointer() {
  local image="$1"
  mkdir -p "$(dirname "$POINTER_FILE")"
  printf '%s\n' "$image" > "$POINTER_FILE.tmp.$$"
  mv -f "$POINTER_FILE.tmp.$$" "$POINTER_FILE"
}

# Every connected output, in the order mango reports them. mmsg prints a single
# compact JSON document, so grep for the name field directly -- the session has
# neither jq nor python3 on PATH.
list_outputs() {
  mmsg get all-monitors 2>/dev/null | grep -oE '"name":"[^"]*"' | cut -d'"' -f4
}

# Output names whose client presently holds a visible fullscreen or maximized
# window. mmsg emits one compact JSON object per client in field order; within a
# client the monitor is followed by its visibility and fullscreen/maximized
# flags, so a grep for those four tokens reordered by awk pairs each visible
# fullscreen client with the monitor it covers (no jq needed).
fullscreen_output_names() {
  mmsg get all-clients 2>/dev/null | grep -oE \
    '"monitor":"[^"]*"|"is_visible":(true|false)|"is_fullscreen":(true|false)|"is_maximized":(true|false)' |
  awk '
    $0 ~ /"monitor"/ {
      if (pending && visible && (fullscreen || maximized)) print name
      pending = 1
      name = $0; sub(/^"monitor":"/, "", name); sub(/"$/, "", name)
      visible = 0; fullscreen = 0; maximized = 0
      next
    }
    $0 == "\"is_visible\":true" { visible = 1; next }
    $0 == "\"is_fullscreen\":true" { fullscreen = 1; next }
    $0 == "\"is_maximized\":true" { maximized = 1 }
    END { if (pending && visible && (fullscreen || maximized)) print name }
  '
}

stop_output() {
  local output="$1" pid="${wallpaper_pids[$1]:-}"
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  fi
  unset 'wallpaper_pids[$output]'
}

start_output() {
  local output="$1" image="$2"
  stop_output "$output"
  swaybg -o "$output" -i "$image" -m fill >/dev/null 2>&1 &
  wallpaper_pids["$output"]="$!"
  write_pointer "$image"
}

stop_all() {
  local output
  for output in "${!wallpaper_pids[@]}"; do
    stop_output "$output"
  done
}

cleanup() {
  stop_all
}
# EXIT covers normal return and the explicit exit below; INT/TERM must exit, or a
# signal would run cleanup and then resume the loop and repaint the wallpaper.
trap cleanup EXIT
trap 'exit 0' INT TERM

while true; do
  mapfile -t outputs < <(list_outputs)

  # Resolve the outputs covered by a visible fullscreen/maximized client; those
  # have their swaybg stopped so the window "hides" the wallpaper.
  declare -A fullscreen_outputs=()
  while read -r name; do
    [[ -n "$name" ]] && fullscreen_outputs["$name"]=1
  done < <(fullscreen_output_names)

  restart=false
  now="$(date +%s)"

  # wallpaper.sh writes here when the user selects a specific image. Keep the
  # request until fullscreen ends, then honor it before the normal rotation.
  if [[ -s "$REQUEST_FILE" ]]; then
    requested_image="$(cat "$REQUEST_FILE")"
    rm -f "$REQUEST_FILE"
    if [[ -s "$requested_image" ]]; then
      current_image="$requested_image"
      current_index=-1
      last_change="$now"
      restart=true
    fi
  fi

  if [[ "$restart" == false ]] && ((now - last_change >= INTERVAL)); then
    current_index=$(( (current_index + 1) % ${#WALLPAPERS[@]} ))
    current_image="${WALLPAPERS[$current_index]}"
    last_change="$now"
    restart=true
  fi

  # First pass: settle on an image so the visible outputs have something to show.
  if [[ -z "$current_image" ]]; then
    current_index=0
    current_image="${WALLPAPERS[0]}"
    restart=true
  fi

  # Reconcile each connected output: hide it while it holds a fullscreen window,
  # otherwise (re)start its swaybg if it died or the image rotated.
  for output in "${outputs[@]}"; do
    if [[ -n "${fullscreen_outputs[$output]:-}" ]]; then
      stop_output "$output"
    elif [[ "$restart" == true || -z "${wallpaper_pids[$output]:-}" ]] \
      || ! kill -0 "${wallpaper_pids[$output]}" 2>/dev/null; then
      start_output "$output" "$current_image"
    fi
  done

  # Drop outputs that went away (unplugged or disabled).
  for output in "${!wallpaper_pids[@]}"; do
    present=false
    for connected in "${outputs[@]}"; do
      [[ "$connected" == "$output" ]] && present=true
    done
    [[ "$present" == true ]] || stop_output "$output"
  done

  sleep "$CHECK_INTERVAL"
done
