#!/bin/bash

sketchybar --add item cpu right \
           --set cpu  update_freq=2 \
                      icon=􀧓  \
                      background.color=$ITEM_BG_COLOR \
                      background.padding_left=6 \
                      background.padding_right=6 \
                      script="$PLUGIN_DIR/cpu.sh"
