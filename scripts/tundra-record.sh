#!/usr/bin/env bash
# Screen recording wrapper for the desktop launcher.
#
# wf-recorder is a bare CLI tool with no GUI, so it gets a .desktop entry
# (modules/nixos/launchers.nix) that runs this inside foot. The wrapper exists
# to supply the flags that make the output predictable: a timestamped file in
# ~/Videos, system audio, and a fixed framerate. It also reports the result,
# because otherwise a recording ends silently when you press Ctrl+C.
#
# Flag names verified against wf-recorder 0.6.0, where -f is the output file
# (-d is the encoder device, not a directory) and -r is the framerate.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Records the screen until you press Ctrl+C."
    echo ""
    echo "Options:"
    echo "  -f, --framerate N   Framerate to record at (default: 30)"
    echo "  -d, --dir PATH      Output directory (default: ~/Videos)"
    echo "  -n, --no-audio      Record video only"
    echo "  -h, --help          Show this help message"
}

FRAMERATE=30
OUTPUT_DIR="${HOME}/Videos"
AUDIO_ARGS=(-a)

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--framerate)
            FRAMERATE="$2"
            shift 2
            ;;
        -d|--dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -n|--no-audio)
            AUDIO_ARGS=()
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if ! [[ "$FRAMERATE" =~ ^[0-9]+$ ]]; then
    print_error "Framerate must be a number, got: $FRAMERATE"
    exit 1
fi

if ! command -v wf-recorder >/dev/null 2>&1; then
    print_error "wf-recorder is not available in this session"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

timestamp="$(date +%Y-%m-%d-%H%M%S)"
output_file="${OUTPUT_DIR}/recording-${timestamp}.mp4"

print_info "Recording to ${output_file}"
print_info "Press Ctrl+C to stop."

# wf-recorder exits on SIGINT and writes the container, so the trap has to
# report afterwards rather than in the handler itself.
set +e
wf-recorder -f "$output_file" -r "$FRAMERATE" -y "${AUDIO_ARGS[@]}"
status=$?
set -e

# wf-recorder can leave a zero-byte file behind if it never got a frame.
if [[ ! -s "$output_file" ]]; then
    rm -f "$output_file"
    if [[ $status -eq 0 ]]; then
        print_warning "Recording was too short to produce a file"
    else
        print_error "Recording failed (wf-recorder exited with $status)"
    fi
    exit $status
fi

size="$(du -h "$output_file" | cut -f1)"
print_success "Saved ${output_file} (${size})"

if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Screen Recorder" "Recording saved" \
        "$(basename "$output_file") — ${size}" \
        -h string:sound-name:canberra-ok
fi
