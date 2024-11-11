#!/usr/bin/env bash
pkill swaybg
swaybg -o 'eDP-1' -i "$HOME/.background" -m fill &

notify-send "Wallpaper Changed"
exit
