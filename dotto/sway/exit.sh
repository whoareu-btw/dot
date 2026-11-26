#!/usr/bin/env bash

options=" Lock\n󰒲 Suspend\n󰍃 Logout\n Reboot\n Shutdown"

styling='
*{
  font: "JetBrainsMono Nerd Font Propo 16";
}
window {
    width: 15em;
    padding: 20px;
}
mainbox {
    spacing: 15px;
}
listview {
    lines: 5;
    spacing: 10px;
}
element {
    padding: 10px 15px;
}
'

chosen=$(echo -e "$options" | rofi -dmenu -i -p "󱄉" -theme-str "$styling")

case "$chosen" in
    " Lock")
        swaylock -f -c 000000
        ;;
    "󰒲 Suspend")
        swaylock -c 000000 & sleep 0.5 && systemctl suspend
        ;;
    "󰍃 Logout")
        swaymsg exit
        ;;
    " Reboot")
        systemctl reboot
        ;;
    " Shutdown")
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
