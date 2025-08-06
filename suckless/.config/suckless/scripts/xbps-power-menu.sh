#!/bin/sh
options="Wyłącz\nRestart\nWyloguj\nWygaszacz"
choice=$(echo -e "$options" | dmenu -i -p "Void Linux Power Menu:")

case "$choice" in
    "Wyłącz") sudo shutdown -h now ;;
    "Restart") sudo shutdown -r now ;;
    "Wyloguj") pkill dwm ;;
    "Wygaszacz") slock ;;
esac
