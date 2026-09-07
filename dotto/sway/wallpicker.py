#!/usr/bin/env python3

import os
import sys
import subprocess
from pathlib import Path

def main():
    home = Path.home()
    wall_dir = home / "Wallpapers"
    cache_file = home / ".cache" / "current_wall"

    if not wall_dir.is_dir():
        subprocess.run(["notify-send", f"{wall_dir} not found"])
        sys.exit(1)

    valid_extensions = {".jpg", ".png", ".svg"}

    wall = [
        file for file in wall_dir.iterdir()
        if file.is_file() and file.suffix.lower() in valid_extensions
    ]

    if not wall:
        subprocess.run(["notify-send", f"{wall_dir} not found"])
        sys.exit(1)

    rofi_input = ""
    for wall_path in wall:
        filename = wall_path.name
        rofi_input += f"{filename}\0icon\x1f{wall_path}\n"

    theme_str = """
        window { width: 40%; location: center; anchor: center; }
        listview { columns: 3; lines: 3; spacing: 15px; cycle: true; dynamic: true; }
        element { orientation: vertical; padding: 10px; border-radius: 8px; }
        element-icon { size: 140px; horizontal-align: 0.5; }
        element-text { horizontal-align: 0.5; vertical-align: 0.5; }
    """

    try:
        rofi_process = subprocess.run(
            [
                "rofi", "-dmenu",
                "-p", "Wallpaper",
                "-show-icons",
                "-theme-str", theme_str
            ],
            input=rofi_input.encode('utf-8'),
            capture_output=True,
            check=False
        )
    except FileNotFoundError:
        print("Error: 'rofi' not found")
        sys.exit(1)

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
