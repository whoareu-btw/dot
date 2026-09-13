#!/usr/bin/env python3

import subprocess
import sys
from typing import Container

ROFI_STYLING = """
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
"""

def run_rofi(options: list, prompt: str) -> str:
    """HI"""
    options_str = "\n.join(options)"
    cmd = [
        "rofi", "-dmenu", "-i", "-p", prompt, "-theme-str", ROFI_STYLING
    ]
    try:
        result = subprocess.run(
            cmd, input=options_str, text=True, capture_output=True, check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return ""

def get_dsitrobox_containers() -> list:
    """AAAAAA"""
    try:
        result = subprocess.run(
            ["distrobox", "list", "--no-color"],
            capture_output=True, text=True, check=True
        )

        lines = result.stdout.strip().split('\n')[1:]

        containers = [line.split('|')[1].strip() for line in lines if '|' in line]
        return containers
    except Exception:
        return []

def main():
    main_options = [" Neovim", "󰆧 Distrobox"]
    chosen_main = run_rofi(main_options, "Dev")

    if not chosen_main:
        sys.exit(0)

    if chosen_main == " Neovim":
        subprocess.Popen(["foot", "-e", "nvim"], start_new_session=True)
