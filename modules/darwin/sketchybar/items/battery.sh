#!/bin/bash

sketchybar --add item battery right \
           --set battery update_freq=120 \
                         background.color=$ITEM_BG_COLOR \
                         background.padding_left=6 \
                         background.padding_right=6 \
                         script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery system_woke power_source_change
