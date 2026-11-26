#!/usr/bin/env python3

import subprocess
import sys

# Titlebar 12, list 13: the combination that was confirmed to render without a
# blank gap at the bottom. If a gap shows up after changing a size, check this
# first.
FONT = "JetBrainsMono Nerd Font Propo 13"
TITLE_FONT = "JetBrainsMono Nerd Font Propo Bold 12"

# WindowMaker / NeXTSTEP look in soft gray: one flat gray (same as the
# notification panel) with black outlines on the search field and the
# selected row, square corners.
# "lines" is the fixed number of rows; match it to how many apps you have.
theme_override = """
configuration {
    terminal: "kitty";
}

* {
    gray:   #aeaaae;
    shadow: #555555;
    black:  #000000;
    background-color: transparent;
    text-color: @black;
}

window {
    width: 25em;
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
    content: "Applications";
    expand: false;
    horizontal-align: 0.5;
    padding: 5px;
    border: 0 0 1px 0;
    border-color: @shadow;
    background-color: @gray;
    text-color: @black;
}

inputbar {
    children: [ entry ];
    margin: 6px 6px 4px 6px;
    padding: 5px 7px;
    border: 1px;
    border-color: @black;
    border-radius: 0;
    background-color: @gray;
}

entry {
    placeholder: "Search...";
    placeholder-color: @shadow;
    text-color: @black;
}

listview {
    lines: 7;
    fixed-height: true;
    dynamic: false;
    scrollbar: false;
    spacing: 0;
    margin: 0 6px 2px 6px;
    background-color: transparent;
}

element {
    padding: 3px 5px;
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

element-icon {
    size: 32px;
    background-color: transparent;
}

element-text {
    vertical-align: 0.5;
    background-color: transparent;
    text-color: inherit;
}
"""

try:
    subprocess.run([
        "rofi",
        "-show", "drun",
        "-show-icons",
        "-theme-str", theme_override,
        "-theme-str", f'textbox-title {{ font: "{TITLE_FONT}"; }}',
        "-font", FONT,
    ])
except FileNotFoundError:
    print("Error: 'rofi' is not installed or not found in your system's PATH.", file=sys.stderr)
    sys.exit(1)
