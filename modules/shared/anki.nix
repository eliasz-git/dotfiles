{ pkgs, ... }:

# Anki — spaced repetition flashcards (see the AI Vault note "Tools & Configs/Anki").
#
# The program comes from nixpkgs `anki-bin`, which wraps the official upstream
# binaries: the signed Anki.app (the same DMG that was installed by hand
# before) on macOS, and the Qt6 tarball inside an FHS environment on Linux.
# Version 26.09.3 matches the build that was in /Applications, so the add-ons
# keep working — AnkiConnect in particular refuses to load below point version
# 260800 (Anki 26.08).
#
# Only the *program* is managed here. Anki's data directory stays entirely
# user-owned and is deliberately NOT managed by Home Manager:
#
#   macOS    ~/Library/Application Support/Anki2
#   Linux    ~/.local/share/Anki2
#
# It holds the collection, the media, prefs21.db (UI preferences) and addons21/.
# Anki writes to all of those at runtime — the add-on updater rewrites
# addons21/<id>/ and every add-on persists its own config.json — so linking any
# of it into the Nix store would make it read-only and break in-app add-on
# updates.
#
# Deck content syncs through AnkiWeb. Add-ons, add-on settings and app
# preferences do NOT sync, so a second device inherits them from a one-time
# copy of the data directory:
#
#   rsync -a --delete \
#     "$HOME/Library/Application Support/Anki2/" \
#     desktop:~/.local/share/Anki2/
#
# Quit Anki before copying so the SQLite WAL is checkpointed. The Elias Shop
# add-on is local-only — AnkiWeb cannot serve it — so it travels with that copy
# rather than being managed here; it is under active development, so it is
# deliberately not vendored into this repository.
#
# Installed add-ons: AnkiConnect 2055492159, Synapse 236979321,
# FSRS Helper 759844606, Elias Shop (local).
{
  home.packages = [ pkgs.anki-bin ];
}
