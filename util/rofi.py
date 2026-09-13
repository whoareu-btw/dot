#!/usr/bin/env python3

import subprocess
import sys

theme_override = """
configuration {
    terminal: "foot";     /* Instructs Rofi to use 'foot' for terminal-based apps */
}
window {
    width: 25em;          /* Narrows the window */
}
listview {
    lines: 7;             /* Forces exactly 7 items */
    scrollbar: false;     /* Hides the scrollbar */
}
element-icon {
    size: 32px;            /* Makes the icon larger (try 32px or 2.5em if needed) */
}
"""

try:
    subprocess.run([
        "rofi",
        "-show", "drun",
        "-show-icons",
        "-theme-str", theme_override,    # Inject the Fuzzel-like geometry overrides
        "-font", "JetBrainsMono Nerd Font Propo 16"     # Apply the requested font
    ])
except FileNotFoundError:
    print("Error: 'rofi' is not installed or not found in your system's PATH.", file=sys.stderr)
    sys.exit(1)
