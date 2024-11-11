#!/usr/bin/env bash

#! /bin/sh

chosen=$(printf " Power Off\n Restart\n Logout\n Lock" | tofi)

case "$chosen" in
	"Power Off") poweroff ;;
	"Restart") reboot ;;
	"Logout") pkill sway ;;
	"Lock") $HOME/.config/hypr/scripts/offscreen ;;
	*) exit 1 ;;
esac
