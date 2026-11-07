#!/usr/bin/env bash
# Mirror Codeberg repos to GitHub.
# Run periodically (cron/systemd timer) to keep GitHub in sync with Codeberg primary.
#
# Each mirrored repo is expected to have two remotes:
#   codeberg → git@codeberg.org:eliasz/<repo>.git   (primary)
#   origin   → git@github.com:eliasz-git/<repo>.git (mirror)
#
# Repos are scanned under $BASE. Only repos that have BOTH a codeberg and a
# github remote are mirrored.

set -euo pipefail

BASE="${MIRROR_BASE:-/home/elias}"
LOG_FILE="${MIRROR_LOG:-/home/elias/.local/share/mirror-to-github.log}"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Load SSH keys into the agent so both remotes authenticate.
if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
fi
ssh-add ~/.ssh/id_ed25519_codeberg >/dev/null 2>&1 || true
ssh-add ~/.ssh/id_ed25519_github   >/dev/null 2>&1 || true

find "$BASE" -maxdepth 5 -name ".git" -type d 2>/dev/null | while read -r gitdir; do
  repo=$(dirname "$gitdir")
  cd "$repo" || continue

  remotes=$(git remote 2>/dev/null || true)
  [ -n "$remotes" ] || continue

  has_codeberg=false
  has_github=false
  for r in $remotes; do
    url=$(git remote get-url "$r" 2>/dev/null || true)
    case "$url" in
      *codeberg.org:eliasz/*) has_codeberg=true ;;
      *github.com:eliasz-git/*) has_github=true ;;
    esac
  done

  [ "$has_codeberg" = true ] || continue
  [ "$has_github" = true ] || continue

  reponame=$(basename "$repo")
  log "Mirroring $reponame: codeberg → github"

  # Fetch from codeberg primary, pruning stale refs.
  git fetch codeberg --prune >>"$LOG_FILE" 2>&1 || {
    log "  WARNING: fetch failed for $reponame"
    continue
  }

  # Push all branches and tags to the GitHub mirror.
  git push origin --all --force >>"$LOG_FILE" 2>&1 || {
    log "  WARNING: push --all failed for $reponame"
  }
  git push origin --tags --force >>"$LOG_FILE" 2>&1 || {
    log "  WARNING: push --tags failed for $reponame"
  }

  log "  Done: $reponame"
done

log "Mirror run complete."
