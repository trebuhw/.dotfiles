#!/usr/bin/env bash

#! /bin/sh

chosen=$(printf " Power Off\n Restart\n Logout\n Lock" | rofi -dmenu -i -p " POWER ")

case "$chosen" in
	"Power Off") $HOME/.config/hypr/scripts/rofi-powermenu.sh ;;
	"Restart") systemctl reboot ;;
	"Logout") loginctl "terminate-user" "$USER" ;;
	"Lock") $HOME/.config/hypr/scripts/lockscreen ;;
	*) exit 1 ;;
esac
