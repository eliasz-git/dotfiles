#!/bin/bash

PRINTER=(
  icon=󰐪
  icon.color=$BLUE
  label.drawing=off
  background.color=$ITEM_BG_COLOR
  background.padding_left=6
  background.padding_right=6
  script="$PLUGIN_DIR/printer.sh"
  update_freq=60
  click_script="open x-apple.systempreferences:com.apple.preferences.printfax"
)

sketchybar --add item printer right \
           --set printer "${PRINTER[@]}"
