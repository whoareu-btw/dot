#!/usr/bin/env bash

options=" Neovim\n Low level (Distrobox)"

styling='
  * {
    font: "monospace 16";
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

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Dev" -theme-str "$styling")

case "$chosen" in
  " Neovim")
    foot -e nvim
    ;;
  " Low level (Distrobox)")
    foot --hold --app-id="low-level" -e distrobox enter low
    ;;
  *)
    exit 0
    ;;
esac
