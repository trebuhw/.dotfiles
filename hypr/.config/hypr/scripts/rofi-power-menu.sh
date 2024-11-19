#!/bin/bash

chosen=$(printf " LOCK\n󰍃 LOGOUT\n󰛧 SCREENOFF\n󰈆 SUSPEND\n REBOOT\n󰐥 POWEROFF" | rofi -dmenu -i -p " ")

case "$chosen" in
	" LOCK") ~/.config/hypr/scripts/lock;;
	"󰍃 LOGOUT") killall Hyprland;;
	"󰛧 SCREENOFF") ~/.config/hypr/scripts/offscreen;;
	"󰈆 SUSPEND") systemctl suspend ;;
	" REBOOT") systemctl reboot ;;
	"󰐥 POWEROFF") systemctl poweroff;;
	*) exit 1 ;;
esac

