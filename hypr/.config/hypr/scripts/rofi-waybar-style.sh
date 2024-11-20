#!/bin/bash


WAYBARCONFIG="$HOME/.config/waybar/config-hypr"
WAYBARSTYLE="$HOME/.config/waybar/style.css"


chosen=$(printf " Color\n Black\n None\n" | rofi -dmenu -i -p " WAYBAR STYLE ")

case "$chosen" in
	"Color") ln -sf "$HOME/.config/waybar/color.style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/color.config-hypr" "$WAYBARCONFIG" && ~/.config/hypr/scripts/WaybarRestart.sh ;;
	"Black") ln -sf "$HOME/.config/waybar/black.style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/all-config-hypr" "$WAYBARCONFIG" && ~/.config/hypr/scripts/WaybarRestart.sh ;;
	"None") ln -sf "$HOME/.config/waybar/none.style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/all-config-hypr" "$WAYBARCONFIG" && ~/.config/hypr/scripts/WaybarRestart.sh ;;
	*) exit 1 ;;
esac
