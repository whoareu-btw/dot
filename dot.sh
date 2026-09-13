#!/usr/bin/env bash
set -euo pipefail

echo "Applying dotfiles ..."

mkdir -p $HOME/.config
cp -r dotto/* $HOME/.config

touch $HOME/.zshrc
cp zsh/zshrc $HOME/.zshrc

touch $HOME/.vimrc
cp vim/vimrc $HOME/.vimrc

mkdir $HOME/Wallpapers
cp Wallpaper/* $HOME/Wallpapers

mkdir $HOME/util
cp util/* $HOME/util

echo "Done!"
