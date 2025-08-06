#!/usr/bin/env bash

# The famous "get a menu of emojis to copy" script.

# Get user selection via dmenu from emoji file.
chosen=$( cat ~/.config/hypr/keybind.md | rofi -dmenu -p "Hyprland key" | awk '{print $1}' )

# Exit if none chosen.
[ -z "$chosen" ] && exit

# If you run this command with an argument, it will automatically insert the
# character. Otherwise, show a message that the emoji has been copied.
if [ -n "$1" ]; then
	xdotool type "$chosen"
else
	printf "$chosen" | xclip -selection clipboard
	notify-send "'$chosen' copied to clipboard." &
fi
