#!/usr/bin/env python3

import subprocess
import sys

theme_override = """
configuration {
    terminal: "foot";     
}
window {
    width: 25em;          
}
listview {
    lines: 7;             
    scrollbar: false;     
}
element-icon {
    size: 32px;            
}
"""

try:
    subprocess.run([
        "rofi",
        "-show", "drun",
        "-show-icons",
        "-theme-str", theme_override,    
        "-font", "JetBrainsMono Nerd Font Propo 16"     
    ])
except FileNotFoundError:
    print("Error: 'rofi' is not installed or not found in your system's PATH.", file=sys.stderr)
    sys.exit(1)
