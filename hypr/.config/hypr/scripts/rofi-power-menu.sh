#!/bin/bash

chosen=$(printf " Lock\n󰍃 Logout\n󰛧 ScreenOff\n󰈆 Suspend\n Reboot\n󰐥 PowerOff" | rofi -dmenu -i -p " ")

case "$chosen" in
	" Lock") ~/.config/hypr/scripts/lock.sh;;
	"󰍃 Logout") killall Hyprland;;
	"󰛧 ScreenOff") ~/.config/hypr/scripts/offscreen.sh;;
	"󰈆 Suspend") systemctl suspend ;;
	" Reboot") systemctl reboot ;;
	"󰐥 PowerOff") systemctl poweroff;;
	*) exit 1 ;;
esac

