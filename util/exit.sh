#!/usr/bin/env bash

options=" Lock\n󰒲 Suspend\n󰍃 Logout\n Reboot\n Poweroff"

styling='
* {
    font: "JetBrainsMono Nerd Font Propo 13";
    gray:   #aeaaae;
    shadow: #555555;
    black:  #000000;
    background-color: transparent;
    text-color: @black;
}

window {
    width: 15em;
    padding: 0;
    border: 1px;
    border-color: @black;
    border-radius: 0;
    background-color: @gray;
}

mainbox {
    padding: 0;
    spacing: 0;
    children: [ textbox-title, inputbar, listview ];
}

textbox-title {
    content: "Exit";
    font: "JetBrainsMono Nerd Font Propo Bold 12";
    expand: false;
    horizontal-align: 0.5;
    padding: 5px;
    border: 0 0 1px 0;
    border-color: @shadow;
    background-color: @gray;
    text-color: @black;
}

inputbar {
    children: [ prompt, entry ];
    spacing: 8px;
    margin: 6px 6px 4px 6px;
    padding: 5px 7px;
    border: 1px;
    border-color: @black;
    border-radius: 0;
    background-color: @gray;
}

prompt {
    text-color: @black;
}

entry {
    placeholder: "Search...";
    placeholder-color: @shadow;
    text-color: @black;
}

listview {
    lines: 5;
    fixed-height: true;
    dynamic: false;
    scrollbar: false;
    spacing: 0;
    margin: 0 6px 2px 6px;
    background-color: transparent;
}

element {
    padding: 5px 7px;
    spacing: 8px;
    border: 1px;
    border-color: transparent;
    border-radius: 0;
}

element normal.normal, element alternate.normal,
element normal.active, element alternate.active,
element normal.urgent, element alternate.urgent {
    background-color: transparent;
    text-color: @black;
}

element selected.normal, element selected.active, element selected.urgent {
    background-color: @gray;
    border-color: @black;
    text-color: @black;
}

element-text {
    vertical-align: 0.5;
    background-color: transparent;
    text-color: inherit;
}
'

chosen=$(echo -e "$options" | rofi -dmenu -i -p "󱄉" -theme-str "$styling")

case "$chosen" in
    " Lock")
      swaylock -f -c 000000
      ;;
    "󰒲 Suspend")
      systemctl suspend
      ;;
    "󰍃 Logout")
      labwc -e
      ;;
    " Reboot")
      systemctl reboot
      ;;
    " Poweroff")
      systemctl poweroff
      ;;
    *)
      exit 0
      ;;
esac
