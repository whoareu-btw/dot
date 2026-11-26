#!/usr/bin/env python3

from pathlib import Path
import shutil

DOT = Path(__file__).resolve().parent
HOME = Path.home()

def sh():
  src = DOT / "zsh" / "zshrc"
  dest = HOME / ".zshrc"
  if src.exists():
    shutil.copy2(src, dest)
    print(f"Copied zshrc -> {dest}")
  else:
    print(f"Skipped zshrc (not found: {src})")


def dot():
  dotD = HOME / ".config"
  dotD.mkdir(parents=True, exist_ok=True)

  boos = ["labwc", "quickshell", "kitty", "nvim"]
  for boo in boos:
    src = DOT / "dotto" / boo
    dest = dotD / boo
    if src.exists():
      shutil.copytree(src, dest, dirs_exist_ok=True)
      print(f"Copied {boo} -> {dest}")
    else:
      print(f"Skipped {boo} (not found: {src})")

def util():
  src = DOT / "util"
  dest = HOME / "util"
  if src.exists():
    shutil.copytree(src, dest, dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns("dev.py", "rofi.py"))
    print(f"Copied util -> {dest}")
  else:
    print(f"Skipped util (not found: {src})")

def wall():
  src = DOT / "Wallpapers"
  dest = HOME / "Wallpapers"
  if src.exists():
    shutil.copytree(src, dest, dirs_exist_ok=True)
    print(f"Copied Wallpapers -> {dest}")
  else:
    print(f"Skipped Wallpapers (not found: {src})")

if __name__ == "__main__":
  print("Applying dotfiles (Copying everything) ...\n")
  sh()
  dot()
  util()
  wall()
  print("\nDone!")
