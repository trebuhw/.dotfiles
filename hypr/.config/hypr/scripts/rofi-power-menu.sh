#!/bin/bash

chosen=$(printf " Lock\n󰍃 Logout\n󰛧 Screenoff\n󰈆 Suspend\n Reboot\n󰐥 Poweroff" | rofi -dmenu -i -p " ")

case "$chosen" in
	" Lock") ~/.config/hypr/scripts/lock.sh;;
	"󰍃 Logout") killall Hyprland;;
	"󰛧 Screenoff") ~/.config/hypr/scripts/offscreen.sh;;
	"󰈆 Suspend") systemctl suspend ;;
	" Reboot") systemctl reboot ;;
	"󰐥 Poweroff") systemctl poweroff;;
	*) exit 1 ;;
esac

