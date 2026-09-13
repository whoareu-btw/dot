#!/usr/bin/env python3

import subprocess
import sys

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
  lines: 3;
  spacing: 10px;
}
element {
  padding: 10px 15px;
}
"""

def run_rofi(options: list, prompt: str) -> str:
    options_str = "\n".join(options)
    cmd = [
        "rofi", "-dmenu", "-i", "-p", prompt,
        "-theme-str", ROFI_STYLING
    ]
    try:
        result = subprocess.run(
            cmd, input=options_str, text=True, capture_output=True, check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return ""

def get_distrobox_containers() -> list:
    try:
        result = subprocess.run(
            ["distrobox", "list", "--no-color"], 
            capture_output=True, text=True, check=True, timeout=3
        )
        lines = result.stdout.strip().split('\n')[1:]
        containers = [line.split('|')[1].strip() for line in lines if '|' in line]
        return containers
    except Exception:
        return []

def main():
    while True:
        main_options = [" Neovim", "󰆧 Distrobox Enter", " Distrobox Stop"]
        chosen_main = run_rofi(main_options, " ")

        if not chosen_main:
            sys.exit(0)

        if chosen_main == " Neovim":
            foot_cmd = [
                "foot", 
                "-e", 
                "env", 
                "SHELL=/bin/sh", 
                "nvim"
            ]
            subprocess.Popen(foot_cmd, start_new_session=True)
            break
            
        elif chosen_main in ["󰆧 Distrobox Enter", " Distrobox Stop"]:
            containers = get_distrobox_containers()
            
            if not containers:
                subprocess.run(["rofi", "-e", "No containers found"], input="", text=True)
                continue 
                
            prompt_label = "󰆧 " if "󰆧 " in chosen_main else " "
            chosen_container = run_rofi(containers, prompt_label)
            
            if not chosen_container:
                continue
                
            if "Enter" in chosen_main:
                foot_cmd = [
                    "foot",
                    f"--app-id=distrobox-{chosen_container}",
                    f"--title=Distrobox: {chosen_container}",
                    "-e",
                    "distrobox",
                    "enter",
                    chosen_container,
                    "--",
                    "bash"
                ]
            else:
                foot_cmd = [
                    "foot",
                    f"--app-id=distrobox-stop-{chosen_container}",
                    f"--title=Stopping: {chosen_container}",
                    "-e",
                    "distrobox",
                    "stop",
                    chosen_container
                ]
                
            subprocess.Popen(foot_cmd, start_new_session=True)
            break

if __name__ == "__main__":
    main()
