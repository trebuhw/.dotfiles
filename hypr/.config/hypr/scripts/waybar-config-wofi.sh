#!/bin/bash

# Files
CONFIG="$HOME/.config/wofi/config"
STYLE="$HOME/.config/wofi/style.css"
COLORS="$HOME/.config/wofi/colors"

WAYBARSTYLE="$HOME/.config/waybar/style.css"
WAYBARCONFIG="$HOME/.config/waybar/config-hypr"
WOFIFILE="$HOME/.config/waybar/config-hypr"

# wofi window config (in %)
WIDTH=12
HEIGHT=50

## Wofi Command
wofi_command="wofi --show dmenu \
			--prompt choose...
			--conf $CONFIG --style $STYLE --color $COLORS \
			--width=$WIDTH% --height=$HEIGHT% \
			--cache-file=/dev/null \
			--hide-scroll --no-actions \
			--matching=fuzzy"

menu() {
  printf "1. All\n"
  printf "2. Color\n"
  printf "3. Color-Icon\n"
  printf "4. Default\n"
  printf "5. Dual\n"
  printf "6. Gnome\n"
  printf "7. Plasma\n"
  printf "8. Simple\n"
  printf "9. Omarchy\n"
  printf "10. i3\n"
}

main() {
  choice=$(menu | ${wofi_command} | cut -d. -f1)
  case $choice in
  1)
    ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  2)
    ln -sf "$HOME/.config/waybar/configs/color.config-hypr" "$WAYBARCONFIG"
    ;;
  3)
    ln -sf "$HOME/.config/waybar/configs/color-icon-config-hypr" "$WAYBARCONFIG"
    ;;
  4)
    ln -sf "$HOME/.config/waybar/configs/config-default" "$WAYBARCONFIG"
    ;;
  5)
    ln -sf "$HOME/.config/waybar/configs/config-dual" "$WAYBARCONFIG"
    ;;
  6)
    ln -sf "$HOME/.config/waybar/configs/config-gnome" "$WAYBARCONFIG"
    ;;
  7)
    ln -sf "$HOME/.config/waybar/configs/config-plasma" "$WAYBARCONFIG"
    ;;
  8)
    ln -sf "$HOME/.config/waybar/configs/config-simple" "$WAYBARCONFIG"
    ;;
  9)
    ln -sf "$HOME/.config/waybar/configs/omarchy.jsonc" "$WAYBARCONFIG"
    ;;
  10)
    ln -sf "$HOME/.config/waybar/configs/i3-config.json" "$WAYBARCONFIG"
    ;;
  11)

    if pgrep -x "waybar" >/dev/null; then
      killall waybar
      exit
    fi
    ;;
  *) ;;
  esac
}

# Check if wofi is already running
if pidof wofi >/dev/null; then
  killall wofi
  exit 0
else
  main
fi

# Restart Waybar and run other scripts if a choice was made
if [[ -n "$choice" ]]; then
  # Restart Waybar
  killall waybar
fi

exec ~/.config/hypr/scripts/WaybarRestart.sh &
