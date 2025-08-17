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
  printf "1. Color\n"
  printf "2. Black\n"
  printf "3. None\n"
  printf "4. B&W\n"
  printf "5. Light\n"
  printf "6. Mauve\n"
  printf "7. RGB\n"
  printf "8. Simple\n"
  printf "9. Dark\n"
  printf "10. Default\n"
  printf "11. Omarchy\n"
  printf "12. i3\n"
}

main() {
  choice=$(menu | ${wofi_command} | cut -d. -f1)
  case $choice in
  1)
    ln -sf "$HOME/.config/waybar/style/color.style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/color.config-hypr" "$WAYBARCONFIG"
    ;;
  2)
    ln -sf "$HOME/.config/waybar/style/black.style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  3)
    ln -sf "$HOME/.config/waybar/style/none.style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  4)
    ln -sf "$HOME/.config/waybar/style/style-b&w.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  5)
    ln -sf "$HOME/.config/waybar/style/style-light.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  6)
    ln -sf "$HOME/.config/waybar/style/style-mauve.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  7)
    ln -sf "$HOME/.config/waybar/style/style-rgb.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  8)
    ln -sf "$HOME/.config/waybar/style/style-simple.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  9)
    ln -sf "$HOME/.config/waybar/style/style-dark.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  10)
    ln -sf "$HOME/.config/waybar/style/style-default.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  11)
    ln -sf "$HOME/.config/waybar/style/omarchy-style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  12)
    ln -sf "$HOME/.config/waybar/style/i3-style.css" "$WAYBARSTYLE" && ln -sf "$HOME/.config/waybar/configs/all-config-hypr" "$WAYBARCONFIG"
    ;;
  13)

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
