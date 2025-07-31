#!/bin/bash

# Files
CONFIG="$HOME/.config/wofi/config"
STYLE="$HOME/.config/wofi/style.css"
COLORS="$HOME/.config/wofi/colors"

# wofi window config (in %)
WIDTH=30
HEIGHT=80

# Plik z keybinds
KEYBIND_FILE="/home/hubert/.dotfiles/hypr/.config/hypr/hypr_keybinds_formatted.md"

## Wofi Command
wofi_command="wofi --show dmenu \
			--prompt 'Hyprland Keybinds' \
			--conf $CONFIG --style $STYLE --color $COLORS \
			--width=$WIDTH% --height=$HEIGHT% \
			--cache-file=/dev/null \
			--hide-scroll --no-actions \
			--matching=fuzzy"

# Funkcja do mapowania wybranej opcji na komendę
execute_command() {
    local choice="$1"
    
    case "$choice" in
        *"Ghostty (terminal)"*)
            ghostty ;;
        *"Foot (terminal)"*)
            foot ;;
        *"Alacritty"*)
            alacritty ;;
        *"Kitty"*)
            kitty ;;
        *"Notatki (fzf)"*)
            alacritty -e $HOME/.local/bin/fzf-nn.sh ;;
        *"Wyszukaj notatki"*)
            alacritty -e $HOME/.local/bin/fzf-search_notes_script.sh ;;
        *"VSCode"*)
            code ;;
        *"Sublime Text"*)
            subl ;;
        *"Wyloguj (wlogout)"*)
            wlogout ;;
        *"Thunar"*)
            thunar ;;
        *"Przeglądarka"*|*"Chrome"*)
            google-chrome-stable ;;
        *"Kalkulator"*)
            galculator ;;
        *"Przywróć tło"*)
            pkill swaybg; swaybg -i ~/.bg -m fill & ;;
        *"Azote"*)
            azote ;;
        *"Waypaper"*)
            waypaper ;;
        *"Aktualizuj system"*)
            kitty -e paru ;;
        *"Zrzut ekranu"*)
            $HOME/.config/hypr/scripts/print.sh ;;
        *"Przeładuj Hyprland"*)
            hyprctl reload ;;
        *"MOC"*)
            alacritty -e mocp ;;
        *"Schowek"*)
            $HOME/.config/hypr/scripts/rofi-cliphist.sh ;;
        *"Menu WiFi"*)
            $HOME/.config/hypr/scripts/rofi-wifi-menu.sh ;;
        *"Menu zasilania"*)
            $HOME/.config/hypr/scripts/rofi-power-menu.sh ;;
        *"Style Waybar"*)
            $HOME/.config/hypr/scripts/waybar-styles-rofi.sh ;;
        *"Konfiguracja Waybar"*)
            $HOME/.config/hypr/scripts/waybar-config-wofi.sh ;;
        *"Rofi (aplikacje)"*)
            rofi -show drun ;;
        *"Selektor emoji"*)
            ~/.config/hypr/scripts/emoji-selector.sh ;;
        *"Rofi (uruchom)"*)
            rofi -show run ;;
        *"Pełne menu"*)
            ~/.config/hypr/scripts/wofi-fullmenu.sh ;;
        *"Usuń odstępy"*)
            hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0" ;;
        *"Przywróć odstępy"*)
            hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3" ;;
        *"Reset głośności"*)
            ~/.config/hypr/scripts/reset_vol_bri.sh ;;
        *"Pokaż/ukryj notatki"*)
            hyprctl dispatch togglespecialworkspace ;;
        *)
            # Jeśli nie znaleziono komendy, pokaż powiadomienie
            notify-send "Keybind Viewer" "Nie można wykonać tej akcji automatycznie" ;;
    esac
}

main() {
    # Sprawdź czy plik istnieje
    if [[ ! -f "$KEYBIND_FILE" ]]; then
        echo "Błąd: Plik $KEYBIND_FILE nie istnieje!" | ${wofi_command}
        exit 1
    fi
    
    # Wyświetl zawartość pliku z sortowaniem i pobierz wybór
    # choice=$(cat "$KEYBIND_FILE" | sort | ${wofi_command})
    choice=$(cat "$KEYBIND_FILE" | ${wofi_command})
    
    # Jeśli coś wybrano, wykonaj komendę
    if [[ -n "$choice" ]]; then
        # Pokaż powiadomienie o wykonaniu
        notify-send "Executing" "$(echo "$choice" | cut -d'→' -f2 | xargs)" -t 2000
        
        # Wykonaj komendę
        execute_command "$choice" &
    fi
}

# Check if wofi is already running
if pidof wofi >/dev/null; then
    killall wofi
    exit 0
else
    main
fi
