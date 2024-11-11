#!/bin/bash

chosen=$(printf " Lock\n󰍃 Logout\n󰛧 Screenoff\n󰈆 Suspend\n Restart\n󰐥 Shutdown" | rofi -dmenu -i -p " ")

case "$chosen" in
	" Lock") ~/.config/hypr/scripts/lock;;
	"󰍃 Logout") killall Hyprland;;
	"󰛧 Screenoff") ~/.config/hypr/scripts/offscreen;;
	"󰈆 Suspend") systemctl suspend ;;
	" Restart") systemctl reboot ;;
	"󰐥 Shutdown") systemctl poweroff;;
	*) exit 1 ;;
esac

