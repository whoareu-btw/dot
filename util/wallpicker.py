#!/usr/bin/env python3
"""Retro wallpaper picker.

A Windows 95 / WindowMaker style rofi window that shows your wallpapers
as a single row of "slides". Flip through them with Left / Right (or
Ctrl+PageUp / Ctrl+PageDown), type to filter, Enter to apply.

Note on the bevels: rofi's `border-color` takes ONE colour, so the raised /
sunken 3D edges are built from two nested boxes. The outer box draws the
bottom+right edge, the inner box draws the top+left edge.
"""

import sys
import subprocess
from pathlib import Path
from string import Template

# --- Look & feel (tweak these) ------------------------------------------------

SLIDES_VISIBLE = 4          # how many wallpapers are shown at once
ICON_SIZE = 168             # thumbnail size in px
# First family found is used. Run `fc-list | grep -i jetbrains` to see which you have.
FONT = "JetBrainsMono Nerd Font, JetBrains Mono 10"
PROMPT = "Find:"            # plain text; a Nerd Font icon shows as a box in this font

# Classic Windows 95 palette. For a WindowMaker feel, try a darker "navy"
# (e.g. #2b2b2b), a greyer "desktop" (e.g. #505075) and a lighter "face".
PALETTE = {
    "face": "#c0c0c0",      # window / button grey
    "light": "#ffffff",     # bevel highlight
    "shadow": "#808080",    # bevel shadow
    "dark": "#000000",      # outer bevel shadow
    "navy": "#000080",      # title bar + selected slide
    "title-fg": "#ffffff",  # title bar / selected text
    "desktop": "#008080",   # the famous teal desktop, behind the slides
    "field": "#ffffff",     # text field background
    "ink": "#000000",       # normal text
}

THEME = Template("""
* {
    $variables
    font: "$font";
    background-color: transparent;
    text-color: @retro-ink;
    border: 0px;
    border-radius: 0px;
    margin: 0px;
    padding: 0px;
    spacing: 0px;
}

/* window frame: outer box = black bottom/right edge, mainbox = white top/left */
window {
    width: ${width}px;
    location: center;
    anchor: center;
    padding: 0px;
    background-color: @retro-face;
    border: 0px 2px 2px 0px;
    border-color: @retro-dark;
}

mainbox {
    children: [ message, field-outer, strip-outer ];
    spacing: 6px;
    padding: 4px;
    background-color: @retro-face;
    border: 2px 0px 0px 2px;
    border-color: @retro-light;
}

/* the title bar */
message {
    padding: 3px 5px;
    border: 0px;
    background-color: @retro-navy;
    text-color: @retro-title-fg;
}
textbox {
    text-color: inherit;
    vertical-align: 0.5;
}

/* sunken text field: white bottom/right edge here, grey top/left on the inputbar */
field-outer {
    children: [ inputbar ];
    expand: false;
    border: 0px 2px 2px 0px;
    border-color: @retro-light;
}
inputbar {
    children: [ prompt, entry ];
    spacing: 8px;
    padding: 4px 6px;
    background-color: @retro-field;
    border: 2px 0px 0px 2px;
    border-color: @retro-shadow;
}
prompt { text-color: @retro-ink; }
entry  { text-color: @retro-ink; }

/* the slide strip: one row, sunken, on a teal "desktop" */
strip-outer {
    children: [ listview ];
    border: 0px 2px 2px 0px;
    border-color: @retro-light;
}
listview {
    columns: $slides;
    lines: 1;
    spacing: 8px;
    padding: 8px;
    cycle: true;
    scrollbar: false;
    fixed-height: true;
    background-color: @retro-desktop;
    border: 2px 0px 0px 2px;
    border-color: @retro-shadow;
}

/* each slide is a grey button with a white frame; the selected one goes navy
   with a black frame, like the default button in a Win95 dialog */
element {
    orientation: vertical;
    padding: 8px;
    spacing: 6px;
    border: 2px;
    border-color: @retro-light;
}
element normal.normal, element alternate.normal {
    background-color: @retro-face;
    text-color: @retro-ink;
    border-color: @retro-light;
}
element selected.normal {
    background-color: @retro-navy;
    text-color: @retro-title-fg;
    border-color: @retro-dark;
}
element-icon {
    size: ${icon}px;
    horizontal-align: 0.5;
}
element-text {
    horizontal-align: 0.5;
    vertical-align: 0.5;
    text-color: inherit;
}
""")


def build_theme():
    variables = "\n    ".join(
        f"retro-{name}: {value};" for name, value in PALETTE.items()
    )
    # slide cell (icon + padding + border), gaps between slides, plus the
    # strip padding/borders, mainbox padding/border and window border
    width = SLIDES_VISIBLE * (ICON_SIZE + 20) + (SLIDES_VISIBLE - 1) * 8 + 32
    return THEME.substitute(
        variables=variables,
        font=FONT,
        width=width,
        icon=ICON_SIZE,
        slides=SLIDES_VISIBLE,
    )


def main():
    home = Path.home()
    wall_dir = home / "Wallpapers"
    cache_file = home / ".cache" / "current_wall"

    if not wall_dir.is_dir():
        subprocess.run(["notify-send", f"{wall_dir} not found"])
        sys.exit(1)

    valid_extensions = {".jpg", ".png", ".svg"}

    wall = sorted(
        (
            file for file in wall_dir.iterdir()
            if file.is_file() and file.suffix.lower() in valid_extensions
        ),
        key=lambda p: p.name.lower(),
    )

    if not wall:
        subprocess.run(["notify-send", f"No wallpapers found in {wall_dir}"])
        sys.exit(1)

    rofi_input = ""
    for wall_path in wall:
        filename = wall_path.name
        rofi_input += f"{filename}\0icon\x1f{wall_path}\n"

    title = f"<b>Select Wallpaper</b>  ({len(wall)} files)"

    try:
        rofi_process = subprocess.run(
            [
                "rofi", "-dmenu",
                # -no-config so your own rofi theme can't fight the retro one
                "-no-config",
                "-p", PROMPT,
                "-mesg", title,
                "-show-icons",
                "-theme-str", build_theme(),
                # Left/Right flip slides instead of moving the text cursor
                "-kb-move-char-back", "Control+b",
                "-kb-move-char-forward", "Control+f",
                "-kb-row-left", "Left,Control+Page_Up",
                "-kb-row-right", "Right,Control+Page_Down",
            ],
            input=rofi_input.encode('utf-8'),
            capture_output=True,
            check=False
        )
    except FileNotFoundError:
        print("Error: 'rofi' not found")
        sys.exit(1)

    # If rofi complains about the theme, show it when run from a terminal
    rofi_errors = rofi_process.stderr.decode('utf-8', 'replace').strip()
    if rofi_errors:
        print(rofi_errors, file=sys.stderr)

    selected_file = rofi_process.stdout.decode('utf-8').strip()

    if selected_file:
        full_path = wall_dir / selected_file

        if full_path.is_file():
            subprocess.run(["pkill", "swaybg"], stderr=subprocess.DEVNULL)

            subprocess.Popen(
                ["swaybg", "-m", "fill", "-i", str(full_path)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )

            cache_file.parent.mkdir(parents=True, exist_ok=True)
            with open(cache_file, "w") as f:
                f.write(str(full_path))


if __name__ == "__main__":
    main()
