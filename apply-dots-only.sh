#!/bin/sh
set -euo pipefail

echo "Applying dotfiles ..."

mkdir -p $HOME/.config
cp -r dotto/* $HOME/.config

touch $HOME/.zshrc
cp zsh/zshrc $HOME/.zshrc

mkdir $HOME/Wallpapers
cp Wallpaper/* $HOME/Wallpapers

echo "Done!"
