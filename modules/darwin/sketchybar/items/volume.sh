#!/bin/bash

sketchybar --add item volume right \
           --set volume background.color=$ITEM_BG_COLOR \
                        background.padding_left=6 \
                        background.padding_right=6 \
                        script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change 
