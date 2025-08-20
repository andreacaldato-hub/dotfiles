#!/bin/bash

# Capture the output of the command
output=$(hyprctl dispatch swapwindow r 2>&1)

# If it failed, try left
if [[ "$output" == *"Window to swap with not found"* ]]; then
  hyprctl dispatch swapwindow l
fi
