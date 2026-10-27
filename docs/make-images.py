#!/usr/bin/env python3
"""Regenerate the images used in the README.

Requirements: `rsvg-convert` (librsvg) and `ffmpeg` on PATH. Both are in the
macbook profile, and any NixOS host can get them with `nix shell nixpkgs#librsvg
nixpkgs#ffmpeg`.

    python3 docs/make-images.py

The text layers are written as SVG and rasterized with rsvg-convert, which gives
exact pixel dimensions and predictable text metrics. This build of rsvg has no
raster image loader, so photographs are composited underneath the text layers by
ffmpeg. Every string in these images comes from the repository: the `tundra`
help text, the theme and wallpaper listings, the palette in
modules/home/themes.nix, the flake outputs, and the files in wallpapers/.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from html import escape

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOTS = os.path.join(REPO, "docs", "screenshots")
BRANDING = os.path.join(REPO, "docs", "branding")
WALLPAPERS = os.path.join(REPO, "wallpapers")

MANTLE = "#272e33"
BASE = "#2d353b"
S0 = "#343f44"
S1 = "#3d484d"
S2 = "#475258"
TEXT = "#d3c6aa"
SUB = "#a7a89c"
SUB1 = "#b0b79c"
BLUE = "#7fbbb3"
GREEN = "#a7c080"
YELLOW = "#dbbc7f"
RED = "#e67e80"
MAUVE = "#d699b6"

MONO = "Menlo, DejaVu Sans Mono, monospace"
SANS = "Helvetica Neue, Inter, DejaVu Sans, sans-serif"


# --------------------------------------------------------------------------
# SVG helpers
# --------------------------------------------------------------------------
def svg_open(w: int, h: int, bg: str | None = MANTLE) -> list[str]:
    head = (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
        f'viewBox="0 0 {w} {h}">'
    )
    out = [head]
    if bg:
        out.append(f'<rect width="{w}" height="{h}" fill="{bg}"/>')
    return out


def text(x, y, s, size=16, fill=TEXT, family=MONO, weight="normal", anchor="start", opacity=1.0):
    a = f' text-anchor="{anchor}"' if anchor != "start" else ""
    o = f' opacity="{opacity}"' if opacity != 1.0 else ""
    return (
        f'<text x="{x}" y="{y}" font-family="{family}" font-size="{size}" fill="{fill}" '
        f'font-weight="{weight}"{a}{o}>{escape(s)}</text>'
    )


def window_chrome(w, h, x, y, title):
    out = [
        f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="14" fill="{BASE}" '
        f'stroke="{S1}" stroke-width="1.5"/>'
    ]
    out.append(
        f'<path d="M{x+1} {y+50}h{w-2}v-{50-14}a14 14 0 0 0 -14 -14h-{w-28}'
        f'a14 14 0 0 0 -14 14z" fill="{S0}"/>'
    )
    for i, c in enumerate((RED, YELLOW, GREEN)):
        out.append(f'<circle cx="{x+32+i*24}" cy="{y+32}" r="7" fill="{c}"/>')
    out.append(text(x + w / 2, y + 37, title, 14, SUB, MONO, anchor="middle"))
    return out


def tick(x, y, color=GREEN):
    """Drawn check mark so the image never depends on an emoji font."""
    return (
        f'<path d="M{x} {y-5} l4 5 l8 -10" fill="none" stroke="{color}" '
        f'stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>'
    )


# --------------------------------------------------------------------------
# 1. terminal.png
# --------------------------------------------------------------------------
LEFT = [
    ("cmd", "$ tundra"),
    ("blank", ""),
    ("hdr", "Tundra CLI v0.3.0: explicit Nix configuration operations"),
    ("blank", ""),
    ("hdr", "USAGE:"),
    ("cli", "tundra <command> [host]"),
    ("blank", ""),
    ("hdr", "READ-ONLY / BUILD:"),
    ("cli", "eval [host]                 Evaluate one output; no build or activation"),
    ("cli", "build [host]                Build one output; no activation"),
    ("cli", "doctor                      Check repository and evaluate all outputs"),
    ("blank", ""),
    ("hdr", "SYSTEM ACTIONS:"),
    ("cli", "test <host>                 Temporary NixOS activation"),
    ("cli", "switch <host>               Activate the selected host"),
    ("cli", "boot <host>                 Build and add a boot generation (NixOS only)"),
    ("cli", "rollback <host>             Roll back the active generation"),
    ("cli", "rb [--no-pull] <host>       Pull fast-forward from GitHub, then activate"),
    ("blank", ""),
    ("hdr", "INPUTS AND OTHER:"),
    ("cli", "rbu [--no-pull] <host>      Pull, update flake.lock, then build"),
    ("cli", "rebuild/update              Compatibility aliases for rb/rbu"),
    ("cli", "theme [current|list]        Show declared theme information"),
    ("cli", "wallpaper [list|set|reload] List and switch wallpapers"),
    ("cli", "github [status|login|watch] Actions, auth, and pull-request status"),
    ("cli", "apps [list|install|remove]  Imperative profile operations"),
    ("cli", "gc --yes                    Destructive garbage collection"),
    ("blank", ""),
    ("hdr", "SUPPORTED HOSTS:"),
    ("hosts", "macbook laptop desktop mini1 mini2"),
]

RIGHT = [
    ("cmd", "$ tundra theme current"),
    ("out", "everforest-blue"),
    ("blank", ""),
    ("cmd", "$ tundra wallpaper list"),
    ("dim", "Available wallpapers in wallpapers/:"),
    ("dim", "- bierstadt-mountainous-landscape-moonlight.jpg"),
    ("dim", "- ryder-moonlight-marine.jpg"),
    ("dim", "- ryder-moonlit-cove.jpg"),
    ("dim", "- saal-forest-landscape-moonlight.jpg"),
    ("dim", "- tani-buncho-blue-green-landscape.jpg"),
    ("more", "+ 5 more, or wallpaper.jpg as the default"),
    ("blank", ""),
    ("cmd", "$ tundra doctor"),
    ("tick", "darwinConfigurations.macbook"),
    ("tick", "homeConfigurations.mini1"),
    ("tick", "homeConfigurations.mini2"),
    ("tick", "nixosConfigurations.laptop"),
    ("tick", "nixosConfigurations.desktop"),
    ("tick", "nixosConfigurations.mini1"),
    ("tick", "nixosConfigurations.mini2"),
    ("ok", "all outputs evaluate"),
    ("ok", "Doctor checks passed"),
]


def render_rows(items, x0, y0, lh, size):
    rows = []
    y = y0
    for kind, line in items:
        if kind == "cmd":
            rows.append(text(x0, y, line, size, GREEN, MONO))
        elif kind == "hdr":
            rows.append(text(x0, y, line, size, BLUE, MONO, weight="bold"))
        elif kind == "hosts":
            rows.append(text(x0, y, line, size, YELLOW, MONO, weight="bold"))
        elif kind == "cli":
            head, _, rest = line.partition("  ")
            rest = rest.strip()
            rows.append(text(x0 + 14, y, head, size, TEXT, MONO))
            if rest:
                col = x0 + 14 + len(line[: line.index(rest)]) * size * 0.6025
                rows.append(text(col, y, rest, size, SUB, MONO))
        elif kind == "out":
            rows.append(text(x0, y, line, size, TEXT, MONO))
        elif kind == "dim":
            rows.append(text(x0, y, line, size, SUB, MONO))
        elif kind == "more":
            rows.append(text(x0, y, line, size, SUB, MONO, opacity=0.7))
        elif kind == "tick":
            rows.append(tick(x0 + 4, y - 4))
            rows.append(text(x0 + 24, y, line, size, TEXT, MONO))
        elif kind == "ok":
            rows.append(text(x0 + 24, y, "[OK] " + line, size, GREEN, MONO, weight="bold"))
        y += lh
    return rows, y


def terminal_svg():
    W, H = 1600, 1000
    x, y, w, h = 48, 44, W - 96, H - 88
    out = svg_open(W, H)
    out += window_chrome(w, h, x, y, "elias@macbook  ~/.config/nix-config")

    size, lh = 14.5, 25
    top = y + 92
    lrows, lend = render_rows(LEFT, x + 40, top, lh, size)
    out += lrows

    divider_x = x + 776
    out.append(
        f'<line x1="{divider_x}" y1="{y+62}" x2="{divider_x}" y2="{y+h-26}" '
        f'stroke="{S1}" stroke-width="1"/>'
    )
    rrows, _ = render_rows(RIGHT, divider_x + 32, top, lh, size)
    out += rrows

    out.append(f'<rect x="{x+40}" y="{lend-16}" width="8" height="19" fill="{GREEN}" opacity="0.6"/>')
    out.append("</svg>")
    return "\n".join(out)


# --------------------------------------------------------------------------
# 2. hosts.png
# --------------------------------------------------------------------------
HOSTS = [
    ("macbook", "darwinConfigurations.macbook", "macOS", "AeroSpace · SketchyBar · Ghostty · Homebrew"),
    ("laptop", "nixosConfigurations.laptop", "NixOS", "Niri · Waybar · portable profile"),
    ("desktop", "nixosConfigurations.desktop", "NixOS", "Mango · mangobar · Steam and gaming stack"),
    ("mini1", "nixosConfigurations.mini1", "headless", "infrastructure services · Home Manager fallback"),
    ("mini2", "nixosConfigurations.mini2", "headless", "media services · Home Manager fallback"),
]


def hosts_svg():
    W, H = 1600, 1000
    out = svg_open(W, H)
    out.append(text(72, 92, "Six explicit outputs", 40, TEXT, SANS, weight="bold"))
    out.append(text(72, 130, "A build for one machine can never be mistaken for validation of another.", 19, SUB, SANS))

    cw, ch = 712, 218
    gx, gy = 72, 190
    for i, (name, outname, plat, desc) in enumerate(HOSTS):
        cx = gx + (i % 2) * (cw + 32)
        cy = gy + (i // 2) * (ch + 26)
        out.append(
            f'<rect x="{cx}" y="{cy}" width="{cw}" height="{ch}" rx="14" fill="{BASE}" '
            f'stroke="{S1}" stroke-width="1.5"/>'
        )
        out.append(f'<rect x="{cx}" y="{cy}" width="5" height="{ch}" rx="2.5" fill="{BLUE}" opacity="0.85"/>')
        out.append(text(cx + 32, cy + 54, name, 28, TEXT, SANS, weight="bold"))
        out.append(text(cx + cw - 28, cy + 50, plat, 14, SUB, MONO, anchor="end"))
        out.append(text(cx + 32, cy + 94, outname, 15, BLUE, MONO))
        out.append(
            f'<line x1="{cx+32}" y1="{cy+118}" x2="{cx+cw-28}" y2="{cy+118}" '
            f'stroke="{S2}" stroke-width="1" opacity="0.7"/>'
        )
        out.append(text(cx + 32, cy + 156, desc, 17, SUB1, SANS))
        out.append(text(cx + 32, cy + 186, "flakes on · pinned lockfile · explicit host argument", 13, SUB, MONO, opacity=0.75))

    out.append(text(72, H - 52, "One flake, one lockfile, no implicit activation. Hardware configs stay host-owned.", 16, SUB, MONO, opacity=0.8))
    out.append("</svg>")
    return "\n".join(out)


# --------------------------------------------------------------------------
# 3. theme.png
# --------------------------------------------------------------------------
PALETTE = [
    ("base", "#2d353b"),
    ("mantle", "#272e33"),
    ("surface0", "#343f44"),
    ("surface1", "#3d484d"),
    ("surface2", "#475258"),
    ("text", "#d3c6aa"),
    ("subtext1", "#b0b79c"),
    ("subtext0", "#a7a89c"),
    ("blue", "#7fbbb3"),
    ("teal", "#83c092"),
    ("green", "#a7c080"),
    ("yellow", "#dbbc7f"),
    ("peach", "#e69875"),
    ("red", "#e67e80"),
    ("mauve", "#d699b6"),
    ("pink", "#d699b6"),
]


def theme_svg():
    W, H = 1600, 1000
    out = svg_open(W, H)
    out.append(text(72, 92, "Everforest Blue", 40, TEXT, SANS, weight="bold"))
    out.append(text(72, 130, "The canonical palette in modules/home/themes.nix. Every desktop consumer reads from it.", 19, SUB, SANS))

    cols, cw, ch = 4, 350, 128
    gx, gy = 72, 186
    for i, (name, hexv) in enumerate(PALETTE):
        cx = gx + (i % cols) * (cw + 24)
        cy = gy + (i // cols) * (ch + 22)
        out.append(
            f'<rect x="{cx}" y="{cy}" width="{cw}" height="{ch}" rx="12" fill="{BASE}" '
            f'stroke="{S1}" stroke-width="1.5"/>'
        )
        out.append(
            f'<rect x="{cx+14}" y="{cy+14}" width="{cw-28}" height="64" rx="8" '
            f'fill="{hexv}" stroke="{S2}" stroke-width="1"/>'
        )
        out.append(text(cx + 16, cy + 104, name, 17, TEXT, SANS, weight="bold"))
        out.append(text(cx + cw - 16, cy + 104, hexv, 15, SUB, MONO, anchor="end"))

    out.append(f'<line x1="72" y1="{H-108}" x2="{W-72}" y2="{H-108}" stroke="{S1}" stroke-width="1"/>')
    out.append(text(72, H - 66, "Declared themes:  catppuccin-mocha   everforest-blue", 17, SUB, MONO))
    out.append(text(72, H - 36, "tundra theme current  ->  everforest-blue", 17, GREEN, MONO))
    out.append("</svg>")
    return "\n".join(out)


# --------------------------------------------------------------------------
# 4. wallpapers.png (text layer over photographs composited by ffmpeg)
# --------------------------------------------------------------------------
WALLS = [
    ("saal-forest-landscape-moonlight.jpg", "Saal"),
    ("bierstadt-mountainous-landscape-moonlight.jpg", "Bierstadt"),
    ("van-der-neer-moonlit-landscape-with-bridge.jpg", "van der Neer"),
    ("ryder-moonlight-marine.jpg", "Ryder"),
    ("ryder-moonlit-cove.jpg", "Ryder"),
    ("ryder-sailing-by-moonlight.jpg", "Ryder"),
]
WP_CW, WP_CH, WP_GX, WP_GY, WP_COLS = 476, 330, 72, 178, 3
PHOTO_H = WP_CH - 42


def wallpaper_cells():
    for i, (fname, artist) in enumerate(WALLS):
        cx = WP_GX + (i % WP_COLS) * (WP_CW + 24)
        cy = WP_GY + (i // WP_COLS) * (WP_CH + 40)
        yield i, fname, artist, cx, cy


def wallpapers_labels_svg():
    W, H = 1600, 1000
    out = svg_open(W, H, bg=None)
    out.append(text(72, 92, "Wallpaper rotation", 40, TEXT, SANS, weight="bold"))
    out.append(text(72, 130, "Public-domain paintings, rotated every 15 minutes on the desktop host.", 19, SUB, SANS))
    for i, fname, artist, cx, cy in wallpaper_cells():
        out.append(
            f'<rect x="{cx}" y="{cy}" width="{WP_CW}" height="{PHOTO_H}" fill="none" '
            f'stroke="{S1}" stroke-width="1.5"/>'
        )
        out.append(text(cx + 2, cy + WP_CH - 16, artist, 15, TEXT, SANS, weight="bold"))
        out.append(text(cx + WP_CW, cy + WP_CH - 16, fname[:-4], 13, SUB, MONO, anchor="end"))
    out.append(
        text(72, H - 34, "swaybg per monitor · hidden only on the monitor showing a fullscreen window · pinned per host in Nix", 15, SUB, MONO, opacity=0.85)
    )
    out.append("</svg>")
    return "\n".join(out)


# --------------------------------------------------------------------------
# 5. banner (text layer over a photograph composited by ffmpeg)
# --------------------------------------------------------------------------
def banner_labels_svg():
    W, H = 2400, 1200
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
        "<defs>"
        f'<linearGradient id="fade" x1="0" y1="0" x2="0" y2="1">'
        f'<stop offset="0" stop-color="{MANTLE}" stop-opacity="0.78"/>'
        f'<stop offset="0.5" stop-color="{MANTLE}" stop-opacity="0.18"/>'
        f'<stop offset="1" stop-color="{MANTLE}" stop-opacity="0.88"/></linearGradient>'
        f'<linearGradient id="side" x1="0" y1="0" x2="1" y2="0">'
        f'<stop offset="0" stop-color="{MANTLE}" stop-opacity="0.96"/>'
        f'<stop offset="0.55" stop-color="{MANTLE}" stop-opacity="0.30"/>'
        f'<stop offset="1" stop-color="{MANTLE}" stop-opacity="0.0"/></linearGradient>'
        "</defs>",
        f'<rect width="{W}" height="{H}" fill="url(#fade)"/>',
        f'<rect width="{W}" height="{H}" fill="url(#side)"/>',
    ]
    out.append(text(140, 468, "Tundra", 132, TEXT, SANS, weight="bold"))
    out.append(text(140, 542, "Multi-host Nix configuration", 44, BLUE, SANS, weight="bold"))
    out.append(text(140, 602, "macOS, NixOS desktops, a showcase workstation, two headless minis.", 26, SUB1, SANS))
    out.append(f'<rect x="140" y="652" width="120" height="4" rx="2" fill="{GREEN}"/>')

    px = 140
    for p in ["macbook", "laptop", "desktop", "mini1", "mini2"]:
        wdt = 26 + len(p) * 15
        out.append(
            f'<rect x="{px}" y="714" width="{wdt}" height="52" rx="26" fill="{BASE}" '
            f'stroke="{S1}" stroke-width="1.5"/>'
        )
        out.append(text(px + wdt / 2, 748, p, 22, TEXT, MONO, anchor="middle"))
        px += wdt + 16

    sx = 140
    for big, small in [("485", "commits"), ("16h 06m", "tracked"), ("6", "explicit outputs"), ("1", "lockfile")]:
        out.append(text(sx, 952, big, 54, YELLOW, SANS, weight="bold"))
        out.append(text(sx, 992, small, 22, SUB, SANS))
        sx += 300

    for i, c in enumerate((RED, YELLOW, GREEN, BLUE, MAUVE)):
        out.append(f'<circle cx="{W-140-i*44}" cy="{H-120}" r="12" fill="{c}" opacity="0.9"/>')
    out.append("</svg>")
    return "\n".join(out)


# --------------------------------------------------------------------------
# rendering
# --------------------------------------------------------------------------
def rasterize(svg_doc: str, dest: str, w: int, h: int, tmp: str, name: str):
    src = os.path.join(tmp, name + ".svg")
    with open(src, "w") as f:
        f.write(svg_doc)
    subprocess.run(["rsvg-convert", "-w", str(w), "-h", str(h), "-o", dest, src], check=True)


def compose_wallpapers(tmp: str):
    labels = os.path.join(tmp, "wallpapers-labels.png")
    photo = "[{}:v]scale={}:{}:force_original_aspect_ratio=increase,crop={}:{},setsar=1,format=rgba[p{}]"
    parts = []
    for idx in range(len(WALLS)):
        parts.append(photo.format(idx + 1, WP_CW, PHOTO_H, WP_CW, PHOTO_H, idx))

    chain = None
    overlays = []
    prev = "[0:v]"
    for idx, _f, _a, cx, cy in wallpaper_cells():
        out = f"[v{idx}]"
        overlays.append(f"{prev}[p{idx}]overlay={cx}:{cy}{out}")
        prev = out
    overlays.append(f"{prev}[{len(WALLS)+1}:v]overlay=0:0[out]")

    cmd = ["ffmpeg", "-y", "-v", "error", "-f", "lavfi", "-i", "color=c=0x272e33:s=1600x1000"]
    for f, _artist in WALLS:
        cmd += ["-i", os.path.join(WALLPAPERS, f)]
    cmd += ["-i", labels]
    cmd += [
        "-filter_complex",
        ";".join(parts + overlays),
        "-map",
        "[out]",
        "-frames:v",
        "1",
        os.path.join(SHOTS, "wallpapers.png"),
    ]
    subprocess.run(cmd, check=True)


def compose_banner(tmp: str):
    labels = os.path.join(tmp, "banner-labels.png")
    graph = (
        "[1:v]scale=2400:1200:force_original_aspect_ratio=increase,crop=2400:1200,setsar=1,"
        "eq=brightness=0.02:saturation=1.15,format=rgba[bg];"
        "[0:v][bg]overlay=0:0[b];"
        "[b][2:v]overlay=0:0[out]"
    )
    cmd = ["ffmpeg", "-y", "-v", "error", "-f", "lavfi", "-i", "color=c=0x272e33:s=2400x1200"]
    cmd += ["-i", os.path.join(WALLPAPERS, "bierstadt-mountainous-landscape-moonlight.jpg"), "-i", labels]
    cmd += ["-filter_complex", graph, "-map", "[out]", "-frames:v", "1", os.path.join(BRANDING, "tundra-banner-2x1.png")]
    subprocess.run(cmd, check=True)


def main() -> int:
    for tool in ("rsvg-convert", "ffmpeg"):
        if not shutil.which(tool):
            print(f"missing dependency: {tool}", file=sys.stderr)
            return 1
    os.makedirs(SHOTS, exist_ok=True)
    os.makedirs(BRANDING, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmp:
        rasterize(terminal_svg(), os.path.join(SHOTS, "terminal.png"), 1600, 1000, tmp, "terminal")
        rasterize(hosts_svg(), os.path.join(SHOTS, "hosts.png"), 1600, 1000, tmp, "hosts")
        rasterize(theme_svg(), os.path.join(SHOTS, "theme.png"), 1600, 1000, tmp, "theme")
        rasterize(wallpapers_labels_svg(), os.path.join(tmp, "wallpapers-labels.png"), 1600, 1000, tmp, "wallpapers-labels")
        rasterize(banner_labels_svg(), os.path.join(tmp, "banner-labels.png"), 2400, 1200, tmp, "banner-labels")
        compose_wallpapers(tmp)
        compose_banner(tmp)

    for name in ("terminal.png", "hosts.png", "theme.png", "wallpapers.png"):
        p = os.path.join(SHOTS, name)
        print(f"{os.path.relpath(p, REPO):48} {os.path.getsize(p)/1024:8.0f} KB")
    p = os.path.join(BRANDING, "tundra-banner-2x1.png")
    print(f"{os.path.relpath(p, REPO):48} {os.path.getsize(p)/1024:8.0f} KB")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
