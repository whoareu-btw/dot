#!/bin/sh
set -euo pipefail

echo "Applying dotfiles ..."

mkdir -p $HOME/.config
for item in dotto/*; do
    name="${item##*/}"
    if [ "$name" != "nvim" ]; then
        cp -r "$item" "$HOME/.config/"
    fi
done

touch $HOME/.zshrc
cp zsh/zshrc $HOME/.zshrc

mkdir $HOME/Wallpapers
cp Wallpaper/* $HOME/Wallpapers

echo "Done!"
