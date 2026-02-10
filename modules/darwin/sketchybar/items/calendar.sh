#!/bin/bash

sketchybar --add item calendar right \
           --set calendar icon=􀧞  \
                          update_freq=30 \
                          background.color=$ITEM_BG_COLOR \
                          background.padding_left=6 \
                          background.padding_right=6 \
                          script="$PLUGIN_DIR/calendar.sh"
