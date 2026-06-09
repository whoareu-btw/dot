#!/bin/sh

set -euo pipefail

echo "Applying dotfiles ..."

cp -r dotto/* $HOME/.config

cp zsh/zshrc $HOME/.zshrc

mkdir $HOME/Wallpaper

cp Wallpaper/* $HOME/Wallpaper

echo "Done!"
