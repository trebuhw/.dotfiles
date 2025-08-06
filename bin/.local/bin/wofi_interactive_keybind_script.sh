#!/usr/bin/env bash

# Szybkie sprawdzenie czy wofi już działa
pidof wofi >/dev/null && { killall wofi; exit 0; }

# Konfiguracja
KEYBIND_FILE="$HOME/.dotfiles/hypr/.config/hypr/hypr_keybinds_formatted.md"
WOFI_CMD="wofi --show dmenu --prompt 'Hyprland Keybinds' \
    --conf $HOME/.config/wofifull/config \
    --style $HOME/.config/wofifull/style.css \
    --color $HOME/.config/wofifull/colors \
    --width=40% --height=60% --columns=1 \
    --cache-file=/dev/null --hide-scroll --no-actions --matching=fuzzy"

# Sprawdź istnienie pliku
[[ ! -f "$KEYBIND_FILE" ]] && { 
    echo "Błąd: Plik $KEYBIND_FILE nie istnieje!" | $WOFI_CMD
    exit 1
}

# Pobierz wybór
choice=$(cat "$KEYBIND_FILE" | $WOFI_CMD)
[[ -z "$choice" ]] && exit 0

# Wykonaj komendę na podstawie wyboru (sprawdza czy wybrana linia zawiera wzorzec)
case "$choice" in
    *"Ghostty (terminal)"*) ghostty ;;
    *"Foot (terminal)"*) foot ;;
    *"Alacritty"*) alacritty ;;
    *"Kitty"*) kitty ;;
    *"Notatki (fzf)"*) alacritty -e ~/.local/bin/fzf-nn.sh ;;
    *"Wyszukaj notatki"*) alacritty -e ~/.local/bin/fzf-search_notes_script.sh ;;
    *"VSCode"*) code ;;
    *"Sublime Text"*) subl ;;
    *"Wyloguj (wlogout)"*) wlogout ;;
    *"Thunar"*) thunar ;;
    *"Przeglądarka"*|*"Chrome"*) google-chrome-stable ;;
    *"Kalkulator"*) galculator ;;
    *"Przywróć tło"*) pkill swaybg; swaybg -i ~/.bg -m fill & ;;
    *"Azote"*) azote ;;
    *"Waypaper"*) waypaper ;;
    *"Aktualizuj system"*) kitty -e paru ;;
    *"Zrzut ekranu"*) ~/.config/hypr/scripts/print.sh ;;
    *"Przeładuj Hyprland"*) hyprctl reload ;;
    *"MOC"*) alacritty -e mocp ;;
    *"Schowek"*) ~/.config/hypr/scripts/rofi-cliphist.sh ;;
    *"Menu WiFi"*) ~/.config/hypr/scripts/rofi-wifi-menu.sh ;;
    *"Menu zasilania"*) ~/.config/hypr/scripts/rofi-power-menu.sh ;;
    *"Style Waybar"*) ~/.config/hypr/scripts/waybar-styles-rofi.sh ;;
    *"Konfiguracja Waybar"*) ~/.config/hypr/scripts/waybar-config-wofi.sh ;;
    *"Rofi (aplikacje)"*) rofi -show drun ;;
    *"Selektor emoji"*) ~/.config/hypr/scripts/emoji-selector.sh ;;
    *"Rofi (uruchom)"*) rofi -show run ;;
    *"Pełne menu"*) ~/.config/hypr/scripts/wofi-fullmenu.sh ;;
    *"Usuń odstępy"*) hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0" ;;
    *"Przywróć odstępy"*) hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3" ;;
    *"Reset głośności"*) ~/.config/hypr/scripts/reset_vol_bri.sh ;;
    *"Pokaż/ukryj notatki"*) hyprctl dispatch togglespecialworkspace ;;
    *) notify-send "Keybind Viewer" "Nie można wykonać tej akcji automatycznie" ;;
esac &

# Powiadomienie o wykonaniu
notify-send "Executing" "$(echo "$choice" | cut -d'→' -f2 | xargs)" -t 2000
