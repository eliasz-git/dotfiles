#!/usr/bin/env bash
# Render words as FIGlet art using the fonts vendored in themes/tundra/ascii.
#
# This is the piece that lets the screensaver say something other than the
# default wordmark: `tundra-ascii "back in five"` renders the phrase, and
# `tundra-ascii --random` picks one of the styles at random so the same word
# comes out differently each time.
set -euo pipefail

# resolve() follows the symlink Home Manager puts in ~/.local/bin back to the
# real script, so the repository-relative fallback still points somewhere true.
resolve() {
    readlink -f "$1" 2>/dev/null || printf '%s' "$1"
}

SCRIPT_DIR="$(cd "$(dirname "$(resolve "${BASH_SOURCE[0]}")")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
REPO_FONT_DIR="$REPO_DIR/themes/tundra/ascii/fonts"
DATA_FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tundra/ascii/fonts"

# Prefer fonts installed into the data directory; fall back to the checkout so
# the script also works straight from a clone, and an explicit override wins.
if [[ -n "${TUNDRA_ASCII_FONT_DIR:-}" ]]; then
    FONT_DIR="$TUNDRA_ASCII_FONT_DIR"
elif compgen -G "$DATA_FONT_DIR/*.flf" >/dev/null 2>&1; then
    FONT_DIR="$DATA_FONT_DIR"
else
    FONT_DIR="$REPO_FONT_DIR"
fi

FIGLET="${TUNDRA_FIGLET:-figlet}"

usage() {
    cat <<'EOF'
Usage: tundra-ascii [OPTIONS] [WORD...]

Renders text as FIGlet art. With no arguments it renders the default wordmark.

Options:
  -f, --font NAME   Font to use: delta, block, blocks, cybermedium
  -r, --random      Pick a font at random
  -c, --preserve-case
                    Keep the case of the input as typed
  -l, --list        List the available fonts
  -h, --help        Show this help message

Examples:
  tundra-ascii                        # "tundra" in the default style
  tundra-ascii --random               # "tundra" in a random style
  tundra-ascii --font blocks tundra
  tundra-ascii "back in five"

Text is upper-cased unless --preserve-case is given. These are display faces
with uneven coverage of the lowercase range, so upper case is the reliable
looking result; some characters they simply do not carry are dropped by
figlet.
EOF
}

# Short names map onto the vendored .flf files. Keep this list in step with the
# files in FONT_DIR; --list reports whatever is actually there.
font_file() {
    case "$1" in
        delta | delta-corps-priest) echo "DeltaCorpsPriest1.flf" ;;
        block) echo "Block.flf" ;;
        blocks) echo "Blocks.flf" ;;
        cybermedium | cyber) echo "Cybermedium.flf" ;;
        *) echo "" ;;
    esac
}

list_fonts() {
    printf 'Available styles (use with --font):\n'
    for name in delta block blocks cybermedium; do
        file="$(font_file "$name")"
        if [[ -f "$FONT_DIR/$file" ]]; then
            printf '  %-14s %s\n' "$name" "$file"
        fi
    done
    printf '\nAny other file dropped into %s is also usable by its filename.\n' "$FONT_DIR"
}

FONT="delta"
RANDOM_FONT=false
PRESERVE_CASE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f | --font)
            FONT="${2:-}"
            shift 2
            ;;
        -r | --random)
            RANDOM_FONT=true
            shift
            ;;
        -c | --preserve-case)
            PRESERVE_CASE=true
            shift
            ;;
        -l | --list)
            list_fonts
            exit 0
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

WORD="${*:-tundra}"
[[ "$PRESERVE_CASE" == true ]] || WORD="${WORD^^}"

if [[ "$RANDOM_FONT" == true ]]; then
    mapfile -t available < <(
        for name in delta block blocks cybermedium; do
            file="$(font_file "$name")"
            [[ -f "$FONT_DIR/$file" ]] && echo "$name"
        done
    )
    if ((${#available[@]} == 0)); then
        echo "No fonts found in $FONT_DIR" >&2
        exit 1
    fi
    FONT="${available[RANDOM % ${#available[@]}]}"
fi

# An unrecognised --font is treated as a path so a dropped-in font still works.
if [[ -n "$(font_file "$FONT")" ]]; then
    FONT_PATH="$FONT_DIR/$(font_file "$FONT")"
else
    FONT_PATH="$FONT"
fi

if [[ ! -r "$FONT_PATH" ]]; then
    echo "Font not readable: $FONT_PATH" >&2
    exit 1
fi

if ! command -v "$FIGLET" >/dev/null 2>&1; then
    echo "figlet is not available in this session" >&2
    exit 1
fi

"$FIGLET" -f "$FONT_PATH" -w 0 "$WORD"
