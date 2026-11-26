#!/bin/sh
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
grim -g "$(slurp)" "$dir/area-$(date +%Y-%m-%d-%H%M%S).png" && notify-send "Ure da real area screenshot"
