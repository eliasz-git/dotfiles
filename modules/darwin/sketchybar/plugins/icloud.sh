#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Check if iCloud Drive is mounted and syncing
ICLOUD_STATUS="unknown"
ICON="󰀂"
COLOR=$CYAN

# Check if iCloud Drive directory exists and is accessible
if [ -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs" ]; then
  # Check if brctl (iCloud control tool) is available
  if command -v brctl &> /dev/null; then
    # Get sync status
    SYNC_STATUS=$(brctl monitor 2>&1 | grep -i "sync" | head -n 1)
    
    if echo "$SYNC_STATUS" | grep -qi "idle\|synced"; then
      ICON="󰀂"  # Cloud check icon
      COLOR=$GREEN
      ICLOUD_STATUS="synced"
    elif echo "$SYNC_STATUS" | grep -qi "sync"; then
      ICON="󰅟"  # Cloud sync icon
      COLOR=$YELLOW
      ICLOUD_STATUS="syncing"
    else
      ICON="󰀂"  # Cloud icon
      COLOR=$CYAN
      ICLOUD_STATUS="online"
    fi
  else
    # brctl not available, just check if directory is accessible
    if [ -r "$HOME/Library/Mobile Documents/com~apple~CloudDocs" ]; then
      ICON="󰀂"
      COLOR=$GREEN
      ICLOUD_STATUS="online"
    else
      ICON="󰅤"  # Cloud offline icon
      COLOR=$RED
      ICLOUD_STATUS="offline"
    fi
  fi
else
  ICON="󰅤"
  COLOR=$RED
  ICLOUD_STATUS="offline"
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label=""
