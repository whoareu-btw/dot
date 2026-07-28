#!/bin/sh

pkill -x fcitx5 
sleep 0.2
exec fcitx5 -d --replace
