#!/bin/bash

ICLOUD=(
  icon=󰀂
  icon.color=$CYAN
  label.drawing=off
  background.color=$ITEM_BG_COLOR
  background.padding_left=6
  background.padding_right=6
  script="$PLUGIN_DIR/icloud.sh"
  update_freq=120
)

sketchybar --add item icloud right \
           --set icloud "${ICLOUD[@]}" \
           --subscribe icloud system_woke
