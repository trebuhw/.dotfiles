#! /bin/sh

chosen=$(printf "Lock\nLogout\nscreenoff\nrestart\nshutdown" | rofi -dmenu -i -p " >>> ")

case "$chosen" in
	"Lock") i3lock -c 000000 && ~/.config/dwm/scripts/offscreen-x11;;
	"logout") ~/.config/dwm/scripts/logout;;
	"screenoff") i3lock -c 000000 && ~/.config/dwm/scripts/offscreen-x11;;
	"restart") systemctl reboot ;;
	"shutdown") systemctl poweroff;;
	*) exit 1 ;;
esac
