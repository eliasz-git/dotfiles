#!/usr/bin/env bash
# The per-terminal half of the Tundra screensaver: draws the wordmark as ASCII
# art and resolves it out of a field of random glyphs.
#
# scripts/tundra-screensaver.sh puts this in a fullscreen window on a special
# workspace and passes it the art to draw. It exits on any keypress, which is
# what dismisses the screensaver, and closes the special workspace behind
# itself so the desktop is left clean.
#
# Colours arrive in TUNDRA_SCREEN_* so the effect follows the active theme
# rather than hard-coding a palette.
set -euo pipefail

# gawk indexes the art by character, not byte, so the box-drawing characters in
# the wordmark land in the right columns. Without a UTF-8 locale every glyph
# would count as three and the art would come out shredded.
export LC_ALL="${TUNDRA_SCREEN_LOCALE:-C.utf8}"

ART_FILE="${1:?usage: tundra-screensaver-effect.sh ART_FILE}"
WORKSPACE="${TUNDRA_SCREEN_WORKSPACE:-tundra-screensaver}"
GAWK="${TUNDRA_GAWK:-gawk}"

if ! command -v "$GAWK" >/dev/null 2>&1; then
    echo "gawk is required by the screensaver but is not available" >&2
    exit 1
fi

ESC="$(printf '\033')"

render_pid=""
reader_pid=""

cleanup() {
    # Only ever signal a real child. `kill 0` would take down the whole process
    # group, which from inside a terminal window means the user's shell.
    [[ -n "$reader_pid" ]] && kill "$reader_pid" 2>/dev/null || true
    [[ -n "$render_pid" ]] && kill "$render_pid" 2>/dev/null || true
    printf '%s[?25h%s[?1049l%s' "$ESC" "$ESC" "$ESC"
    stty echo 2>/dev/null || true
    hyprctl dispatch exitspecialworkspace "$WORKSPACE" >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'cleanup; exit 0' INT TERM

printf '%s[?1049h%s[?25l' "$ESC" "$ESC" # alternate screen, hidden cursor
stty -echo 2>/dev/null || true

"$GAWK" -v COLS="$(tput cols 2>/dev/null || echo 200)" \
    -v ROWS="$(tput lines 2>/dev/null || echo 50)" \
    -v ARTFILE="$ART_FILE" \
    -v CYCLE="${TUNDRA_SCREEN_CYCLE:-14}" \
    -v FPS="${TUNDRA_SCREEN_FPS:-12}" \
    -v SEED="${TUNDRA_SCREEN_SEED:-$RANDOM}" \
    -v RAIN="${TUNDRA_SCREEN_RAIN:-a7c080}" \
    -v RAIN_DIM="${TUNDRA_SCREEN_RAIN_DIM:-4a5c3a}" \
    -v INK="${TUNDRA_SCREEN_INK:-d3c6aa}" \
    -v GLINT="${TUNDRA_SCREEN_GLINT:-7fbbb3}" \
    -f - <<'AWK' &
# ASCII art resolving out of noise: the Omarchy screensaver effect.
#
# Each cell of the wordmark has its own settle time, so the word assembles
# unevenly rather than snapping into place all at once. Once assembled it sits
# still with a little flicker, a band of accent colour sweeps across it, and
# then the whole cycle restarts.

function rnd() {
    seed = (seed * 1103515245 + 12345) % 2147483648
    return seed / 2147483648
}

function glyph() {
    return GLYPHS[int(rnd() * nglyphs) + 1]
}

# Expand "#rrggbb" into the semicolon-separated component list that a 24-bit
# colour escape needs. Commas here silently break every colour in the frame.
function rgb(hex,   r, g, b) {
    r = strtonum("0x" substr(hex, 1, 2))
    g = strtonum("0x" substr(hex, 3, 2))
    b = strtonum("0x" substr(hex, 5, 2))
    return r ";" g ";" b
}

BEGIN {
    ESC = sprintf("%c", 27)
    RESET = ESC "[0m"
    C_RAIN = ESC "[38;2;" rgb(RAIN) "m"
    C_DIM = ESC "[38;2;" rgb(RAIN_DIM) "m"
    C_INK = ESC "[38;2;" rgb(INK) "m"
    C_GLINT = ESC "[38;2;" rgb(GLINT) "m"

    nglyphs = split("01２3４5６7８9０" \
        "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ" \
        "░▒▓█▀▄▌▐■□▪▫", GLYPHS, "")

    # Load the art and remember which cells are actually inked.
    nrows = 0
    artw = 0
    while ((getline line < ARTFILE) > 0) {
        sub(/[ \t]+$/, "", line)
        art[++nrows] = line
        if (length(line) > artw) artw = length(line)
        for (i = 1; i <= length(line); i++)
            if (substr(line, i, 1) != " ") {
                ink[nrows SUBSEP i] = 1
                # Spread settle times across the reveal so the word builds up
                # gradually instead of all at once.
                settle[nrows SUBSEP i] = rnd()
            }
    }
    close(ARTFILE)

    if (nrows == 0) exit 1

    # Centre the art, and never clip it: art wider or taller than the window
    # starts at the top-left instead of hanging off the edge.
    offr = int((ROWS - nrows) / 2); if (offr < 0) offr = 0
    offc = int((COLS - artw) / 2); if (offc < 0) offc = 0

    reveal = 3.5
    hold = 5.0
    glint_from = reveal + hold
    glint_len = 2.2

    frame = 0
    while (1) {
        t = frame / FPS
        if (t > CYCLE) { t = 0; frame = 0 }

        # The glint is a soft band travelling left to right once per cycle.
        gpos = -1
        if (t >= glint_from && t <= glint_from + glint_len)
            gpos = (t - glint_from) / glint_len * (COLS + 8) - 4

        out = ESC "[H" ESC "[2J"
        for (r = 1; r <= ROWS; r++) {
            row = ""
            for (c = 1; c <= COLS; c++) {
                ar = r - offr
                ac = c - offc
                ch = " "
                col = ""

                if (ar >= 1 && ar <= nrows && ac >= 1 && ac <= length(art[ar]) && ((ar SUBSEP ac) in ink)) {
                    if (t >= settle[ar SUBSEP ac] * reveal) {
                        ch = substr(art[ar], ac, 1)
                        col = C_INK
                    } else {
                        ch = glyph()
                        col = C_DIM
                    }
                } else if (rnd() < 0.045) {
                    # Sparse background noise, so the field is not a flat void.
                    ch = glyph()
                    col = C_DIM
                }

                if (ch != " ") {
                    if (gpos >= 0 && c >= gpos && c < gpos + 4) col = C_GLINT
                    else if (gpos >= 0 && c >= gpos - 2 && c < gpos) col = C_RAIN
                    row = row col ch
                }
            }
            out = out row RESET "\n"
        }
        printf "%s", out
        fflush()

        frame++
        system("sleep " sprintf("%.3f", 1 / FPS))
    }
}
AWK

render_pid=$!

# Dismiss on any input. This has to start after the renderer so it has a real
# pid to signal. Mouse motion arrives as escape sequences, so it lands here too.
(
    IFS= read -r -n 1 -s _ </dev/tty 2>/dev/null || true
    [[ -n "$render_pid" ]] && kill "$render_pid" 2>/dev/null || true
) &
reader_pid=$!

wait "$render_pid" 2>/dev/null || true
exit 0
