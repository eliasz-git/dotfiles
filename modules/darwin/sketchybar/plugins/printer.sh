#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Check printer status using lpstat
ICON="󰐪"
COLOR=$BLUE
LABEL=""

# Check if CUPS is running and if there are any printers configured
if command -v lpstat &> /dev/null; then
  # Get list of printers
  PRINTER_COUNT=$(lpstat -p 2>/dev/null | grep -c "printer")
  
  if [ "$PRINTER_COUNT" -gt 0 ]; then
    # Check if any printer has jobs
    JOB_COUNT=$(lpstat -o 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$JOB_COUNT" -gt 0 ]; then
      ICON="󰐪"  # Printer with jobs
      COLOR=$GREEN
      LABEL="$JOB_COUNT"
    else
      ICON="󰐪"  # Printer ready
      COLOR=$BLUE
    fi
  else
    ICON="󰐫"  # No printer configured
    COLOR=$YELLOW
  fi
else
  ICON="󰐫"
  COLOR=$RED
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="$LABEL"
