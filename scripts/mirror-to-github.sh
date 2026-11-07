#!/usr/bin/env bash
# Mirror all Codeberg repos to GitHub.
# Run periodically (cron/launchd) to keep GitHub in sync with Codeberg primary.
#
# Repos are expected to have:
#   - remote 'codeberg'  → git@codeberg.org:eliasz/<repo>.git  (primary)
#   - remote 'origin'    → git@github.com:eliasz-git/<repo>.git (mirror)

set -euo pipefail

BASE="/Users/elias/Developer"
LOG_FILE="/Users/elias/.local/share/mirror-to-github.log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Add SSH keys to agent if not already loaded
if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
  ssh-add ~/.ssh/id_ed25519_codeberg >/dev/null 2>&1 || true
  ssh-add ~/.ssh/id_ed25519_github >/dev/null 2>&1 || true
fi

find "$BASE" -maxdepth 4 -name ".git" -type d 2>/dev/null | while read -r gitdir; do
  repo=$(dirname "$gitdir")
  cd "$repo" || continue

  remotes=$(git remote 2>/dev/null || true)
  [ -z "$remotes" ] && continue

  has_codeberg=false
  has_github=false
  for r in $remotes; do
    url=$(git remote get-url "$r" 2>/dev/null || true)
    if echo "$url" | grep -q "codeberg.org:eliasz/"; then
      has_codeberg=true
    fi
    if echo "$url" | grep -q "github.com:eliasz-git/"; then
      has_github=true
    fi
  done

  [ "$has_codeberg" = false ] && continue
  [ "$has_github" = false ] && continue

  reponame=$(basename "$repo")
  log "Mirroring $reponame: codeberg → github"

  # Fetch from codeberg primary
  git fetch codeberg --prune 2>&1 | tee -a "$LOG_FILE" || {
    log "  WARNING: fetch failed for $reponame"
    continue
  }

  # Push all branches and tags to GitHub mirror
  git push origin --all --force 2>&1 | tee -a "$LOG_FILE" || {
    log "  WARNING: push --all failed for $reponame"
  }
  git push origin --tags --force 2>&1 | tee -a "$LOG_FILE" || {
    log "  WARNING: push --tags failed for $reponame"
  }

  log "  Done: $reponame"
done

log "Mirror run complete."
