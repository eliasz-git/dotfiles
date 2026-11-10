# Deprecation Ledger

This file catalogs every purged, archived, or dead program that has been removed
from this repository's Nix / Home Manager configuration, along with the reason
for removal and its approved modern alternative.

**Rule:** No package listed here may be re-added without explicit review and
justification. Before adding any package to `home.packages`,
`environment.systemPackages`, or any `programs.*` declaration, check this
ledger first.

---

## Purged Packages

| Package | Last Active Release | Status | Reason for Removal | Approved Alternative |
|---------|--------------------|--------|-------------------|---------------------|
| `thefuck` | ~2020 (v3.33) | **Abandoned** | No active releases in ~5 years; project is unmaintained. Shell command correction is already covered by `atuin` (shell history) and careful editing. | `atuin` (already declared) |
| `rofi` | ~2022 | **Stale** | X11-dependent, no active Wayland-native development; slow issue response. | `fuzzel` (Wayland-native, Rust, actively maintained) |
| `exa` | ~2020 | **Archived** | Upstream archived in favor of `eza`. | `eza` (active fork with git integration, colors, icons) |
| `neofetch` | ~2022 | **Archived** | Upstream archived; no active development. | `fastfetch` (C-based, actively maintained, lightning fast) |
| `obsidian` | N/A | **Proprietary** | Closed-source; notes locked in proprietary format; not FOSS. | `joplin-desktop` (MIT, E2EE, Markdown-based, actively maintained) |
| `discord` | N/A | **Proprietary** | Closed-source, telemetry-heavy; not FOSS. | `revolt` (FOSS, actively maintained) |

---

## Migration Notes

- **`thefuck` → `atuin`**: `atuin` provides shell history search and sync, which covers the most common use case of `thefuck` (re-running corrected commands). Shell aliases in `modules/shared/shell.nix` handle the rest.
- **`rofi` → `fuzzel`**: `fuzzel` is a Wayland-native application launcher written in Rust. It replaces `rofi` on all Wayland hosts (desktop Mango, laptop Niri). Configuration lives in `modules/nixos/fuzzel.nix`.
- **`exa` → `eza`**: `eza` is an actively maintained fork of `exa` with additional features (git status, icons, tree view). Already declared in `modules/shared/programs.nix`.
- **`neofetch` → `fastfetch`**: `fastfetch` is a C-based system information tool with active releases. Already declared in `modules/shared/programs.nix` and configured in `modules/shared/fastfetch.nix`.
- **`obsidian` → `joplin-desktop`**: Joplin is FOSS (MIT), supports end-to-end encryption, Markdown notes, and flexible sync (WebDAV, OneDrive, Dropbox). Already declared in host `home.packages` lists.
- **`discord` → `revolt`**: Revolt is a FOSS Discord alternative with active development. Already declared in host `home.packages` lists.

---

## How to Use This Ledger

1. Before adding a package, search this file for the package name.
2. If found, do not re-add it; use the approved alternative instead.
3. If a new package needs to be added that is not listed here, verify its upstream maintenance status (GitHub/GitLab activity, recent releases) before adding.
4. When purging a package, add an entry to this table with the reason and alternative.
