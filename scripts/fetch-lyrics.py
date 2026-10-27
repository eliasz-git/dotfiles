#!/usr/bin/env python3
"""Batch-download synced .lrc lyrics from LRCLIB for the local music library.

Walks the FLAC master tree, fetches time-synced lyrics per track, and writes
.lrc sidecars next to both the FLAC and MP3 copies. Skips tracks that already
have an .lrc, so it's safe to rerun after new imports.
"""

import argparse
import json
import os
import time
import urllib.parse
import urllib.request

from mutagen.flac import FLAC

DEFAULT_FLAC = "/Users/elias/Library/Mobile Documents/com~apple~CloudDocs/Music"
DEFAULT_MP3 = "/Users/elias/Library/Mobile Documents/com~apple~CloudDocs/Music MP3"
API = "https://lrclib.net/api"


def fetch(artist, album, title, duration):
    qs = urllib.parse.urlencode({"artist_name": artist, "album_name": album,
                                 "track_name": title, "duration": int(duration)})
    try:
        with urllib.request.urlopen(f"{API}/get?{qs}", timeout=10) as r:
            d = json.loads(r.read())
            if d.get("syncedLyrics"):
                return d["syncedLyrics"]
    except Exception:
        pass
    qs = urllib.parse.urlencode({"artist_name": artist, "track_name": title})
    try:
        req = urllib.request.Request(f"{API}/search?{qs}",
                                     headers={"User-Agent": "elias-library-sync/1.0"})
        with urllib.request.urlopen(req, timeout=10) as r:
            results = json.loads(r.read())
        for cand in results:
            if cand.get("syncedLyrics") and cand.get("artistName", "").lower() == artist.lower():
                return cand["syncedLyrics"]
    except Exception:
        pass
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--flac-root", default=DEFAULT_FLAC)
    ap.add_argument("--mp3-root", default=DEFAULT_MP3)
    args = ap.parse_args()

    hits, misses, errors = 0, [], 0
    for root, dirs, files in os.walk(args.flac_root):
        for fn in sorted(files):
            if not fn.endswith(".flac"):
                continue
            src = os.path.join(root, fn)
            lrc_path = os.path.join(root, fn[:-len(".flac")] + ".lrc")
            if os.path.exists(lrc_path):
                hits += 1
                continue
            try:
                f = FLAC(src)
            except Exception:
                errors += 1
                continue
            tags = f.tags or {}
            get = lambda k: (tags.get(k) or [""])[0]
            artist = get("albumartist") or get("artist")
            album, title = get("album"), get("title")
            if not artist or not title:
                misses.append(os.path.relpath(src, args.flac_root))
                continue
            lyrics = fetch(artist, album, title, f.info.length)
            time.sleep(0.3)
            rel = os.path.relpath(lrc_path, args.flac_root)
            if lyrics:
                with open(lrc_path, "w") as fh:
                    fh.write(lyrics)
                if args.mp3_root:
                    mp3_lrc = os.path.join(args.mp3_root, os.path.splitext(rel)[0] + ".lrc")
                    os.makedirs(os.path.dirname(mp3_lrc), exist_ok=True)
                    with open(mp3_lrc, "w") as fh:
                        fh.write(lyrics)
                hits += 1
            else:
                misses.append(rel)

    print(f"lyrics found: {hits} | missed: {len(misses)} | read errors: {errors}")
    for m in misses:
        print("  -", m)


if __name__ == "__main__":
    main()
