# Tundra ASCII fonts

FIGlet faces used by `tundra-ascii` and the ASCII screensaver. Each is a `.flf`
file, the plain-text font format `figlet` reads.

| Style | File | Source |
| --- | --- | --- |
| `delta` (default) | `DeltaCorpsPriest1.flf` | [patorjk/figlet.js](https://github.com/patorjk/figlet.js), `fonts/Delta Corps Priest 1.flf` — drawn by CoSMiC cHiLD |
| `block` | `Block.flf` | [xero/figlet-fonts](https://github.com/xero/figlet-fonts) |
| `blocks` | `Blocks.flf` | [xero/figlet-fonts](https://github.com/xero/figlet-fonts) |
| `cybermedium` | `Cybermedium.flf` | [xero/figlet-fonts](https://github.com/xero/figlet-fonts) |

## Provenance and terms

These are third-party fonts, vendored so the screensaver works offline and so
`figlet` has a fixed set of faces to choose from. They are not covered by this
repository's licence, and redistributing them rests on the terms of the
collections above.

- `Block.flf` and `Blocks.flf` each carry a FIGlet permission notice in a
  header comment.
- `DeltaCorpsPriest1.flf` and `Cybermedium.flf` contain no licence header. They
  are included here on the basis that they are freely distributed display faces
  collected by the projects linked above; that is an assumption, not a
  verified grant, and is recorded here so it is visible rather than implied.

If a font needs to be replaced for licensing reasons, drop the new `.flf` in this
directory and add a short name for it in `font_file()` in `scripts/tundra-ascii.sh`.

## Character coverage

These are display faces, not text faces. The `delta` face in particular was
drawn with only letters and spaces, and several of these faces cover the
lowercase range only partially. Two consequences:

- `tundra-ascii` upper-cases its input unless `--preserve-case` is given,
  because upper case is the range these faces actually draw cleanly.
- Characters a face does not carry are dropped silently by `figlet`, so a
  phrase can come out shorter than it went in.
