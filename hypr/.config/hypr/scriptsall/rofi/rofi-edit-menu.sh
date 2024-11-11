#!/usr/bin/env bash

#! /bin/sh

editor="nvim"

chosen=$(printf "
	 backup.sh
	 bash.conf
	 dust.conf
	 fish.alias

		" | rofi -dmenu -i 20 -p " EDIT ")

case "$chosen" in
	"  Power Off") systemctl poweroff ;;
	"  Restart") systemctl reboot ;;
	"  Logout") loginctl terminate-user $USER ;;
	"  Lock") $HOME/.config/swaylock/lock.sh ;;
	*) exit 1 ;;
esac
