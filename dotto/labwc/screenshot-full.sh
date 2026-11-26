#!/bin/sh
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
grim "$dir/fullscreen-$(date +%Y-%m-%d-%H%M%S).png" && notify-send "Ure da real full screenshot"
