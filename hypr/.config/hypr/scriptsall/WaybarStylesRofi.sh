#!/bin/bash

# Files
CONFIG="$HOME/.config/hypr/wofi/WofiBig/config"
CONFIG="$HOME/.config/hypr/wofi/config"
STYLE="$HOME/.config/hypr/wofi/style.css"
COLORS="$HOME/.config/hypr/wofi/colors"

WAYBARFILE="$HOME/.config/hypr/waybar/style.css"
WOFIFILE="$HOME/.config/hypr/wofi/config"

# wofi window config (in %)
WIDTH=12
HEIGHT=35

## Wofi Command
wofi_command="wofi --show dmenu \
			--prompt choose...
			--conf $CONFIG --style $STYLE --color $COLORS \
			--width=$WIDTH% --height=$HEIGHT% \
			--cache-file=/dev/null \
			--hide-scroll --no-actions \
			--matching=fuzzy"


menu(){
printf "1. b&w\n" 
printf "2. dark\n" 
printf "3. default\n"
printf "4. default_alter\n"
printf "5. light\n"
printf "6. mauve\n"
printf "7. rgb\n"
printf "8. simple"
}

main() {
    choice=$(menu | ${wofi_command} | cut -d. -f1)
    case $choice in
        1)
            ln -sf "$HOME/.config/hypr/waybar/style/style-b&w.css" "$WAYBARFILE"
            ;;
        2)
            ln -sf "$HOME/.config/hypr/waybar/style/style-dark.css" "$WAYBARFILE"
            ;;
        3)
            ln -sf "$HOME/.config/hypr/waybar/style/style-default.css" "$WAYBARFILE"
            ;;
        4)
            ln -sf "$HOME/.config/hypr/waybar/style/style-default_alter.css" "$WAYBARFILE"
            ;;
        5)
            ln -sf "$HOME/.config/hypr/waybar/style/style-light.css" "$WAYBARFILE"
            ;;
	    6)
            ln -sf "$HOME/.config/hypr/waybar/style/style-mauve.css" "$WAYBARFILE"
            ;;
        7)    
             ln -sf "$HOME/.config/hypr/waybar/style/style-rgb.css" "$WAYBARFILE"
            ;;
        8)
             ln -sf "$HOME/.config/hypr/waybar/style/style-simple.css" "$WAYBARFILE"
             ;;
        9)     
           
             if pgrep -x "waybar" >/dev/null; then
                killall waybar
                exit
            fi
            ;;        
        *)
            ;;
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

exec ~/.config/hypr/scripts/statusbar &
                
