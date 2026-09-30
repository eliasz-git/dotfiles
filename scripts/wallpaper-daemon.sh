#!/usr/bin/env bash
# Rotate painting wallpapers and hide the desktop background during fullscreen.
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

wallpaper_pid=""
current_index=-1
last_change=0
hidden=false

stop_wallpaper() {
  if [[ -n "$wallpaper_pid" ]] && kill -0 "$wallpaper_pid" 2>/dev/null; then
    kill "$wallpaper_pid" 2>/dev/null || true
    wait "$wallpaper_pid" 2>/dev/null || true
  fi
  wallpaper_pid=""
}

start_wallpaper() {
  local image="$1"
  stop_wallpaper
  swaybg -i "$image" -m fill >/dev/null 2>&1 &
  wallpaper_pid="$!"
  last_change="$(date +%s)"
  hidden=false
  write_pointer "$image"
}

# Write the pointer atomically so a reader never sees a half-written path.
write_pointer() {
  local image="$1"
  mkdir -p "$(dirname "$POINTER_FILE")"
  printf '%s\n' "$image" > "$POINTER_FILE.tmp.$$"
  mv -f "$POINTER_FILE.tmp.$$" "$POINTER_FILE"
}

is_fullscreen() {
  hyprctl activewindow -j 2>/dev/null \
    | grep -Eq '"fullscreen"[[:space:]]*:[[:space:]]*[12]'
}

cleanup() {
  stop_wallpaper
}
trap cleanup EXIT INT TERM

while true; do
  if is_fullscreen; then
    if [[ "$hidden" == false ]]; then
      stop_wallpaper
      hidden=true
    fi
    sleep "$CHECK_INTERVAL"
    continue
  fi

  # wallpaper.sh writes here when the user selects a specific image. Keep the
  # request until fullscreen ends, then honor it before the normal rotation.
  if [[ -s "$REQUEST_FILE" ]]; then
    requested_image="$(cat "$REQUEST_FILE")"
    rm -f "$REQUEST_FILE"
    if [[ -s "$requested_image" ]]; then
      start_wallpaper "$requested_image"
      current_index=-1
      sleep "$CHECK_INTERVAL"
      continue
    fi
  fi

  now="$(date +%s)"
  if [[ -z "$wallpaper_pid" ]] || ! kill -0 "$wallpaper_pid" 2>/dev/null || ((now - last_change >= INTERVAL)); then
    current_index=$(( (current_index + 1) % ${#WALLPAPERS[@]} ))
    start_wallpaper "${WALLPAPERS[$current_index]}"
  fi
  sleep "$CHECK_INTERVAL"
done
