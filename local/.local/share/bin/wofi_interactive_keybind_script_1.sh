#!/usr/bin/env bash

# === KONFIGURACJA ===
readonly CONFIG="$HOME/.config/wofifull/config"
readonly STYLE="$HOME/.config/wofifull/style.css"
readonly COLORS="$HOME/.config/wofifull/colors"
readonly KEYBIND_FILE="$HOME/.dotfiles/hypr/.config/hypr/hypr_keybinds_formatted.md"

# Sprawdź czy wofi już działa
if pidof wofi >/dev/null; then
    killall wofi
    exit 0
fi

# === FUNKCJE ===
show_error() {
    notify-send "Keybind Viewer Error" "$1" -u critical
    exit 1
}

# Mapa komend - łatwiejsza do utrzymania
declare -A COMMANDS=(
    ["Ghostty (terminal)"]="ghostty"
    ["Foot (terminal)"]="foot"
    ["Alacritty"]="alacritty"
    ["Kitty"]="kitty"
    ["Notatki (fzf)"]="alacritty -e $HOME/.local/bin/fzf-nn.sh"
    ["Wyszukaj notatki"]="alacritty -e $HOME/.local/bin/fzf-search_notes_script.sh"
    ["VSCode"]="code"
    ["Sublime Text"]="subl"
    ["Wyloguj (wlogout)"]="wlogout"
    ["Thunar"]="thunar"
    ["Przeglądarka"]="google-chrome-stable"
    ["Chrome"]="google-chrome-stable"
    ["Kalkulator"]="galculator"
    ["Przywróć tło"]="pkill swaybg; swaybg -i ~/.bg -m fill &"
    ["Azote"]="azote"
    ["Waypaper"]="waypaper"
    ["Aktualizuj system"]="kitty -e paru"
    ["Zrzut ekranu"]="$HOME/.config/hypr/scripts/print.sh"
    ["Przeładuj Hyprland"]="hyprctl reload"
    ["MOC"]="alacritty -e mocp"
    ["Schowek"]="$HOME/.config/hypr/scripts/rofi-cliphist.sh"
    ["Menu WiFi"]="$HOME/.config/hypr/scripts/rofi-wifi-menu.sh"
    ["Menu zasilania"]="$HOME/.config/hypr/scripts/rofi-power-menu.sh"
    ["Style Waybar"]="$HOME/.config/hypr/scripts/waybar-styles-rofi.sh"
    ["Konfiguracja Waybar"]="$HOME/.config/hypr/scripts/waybar-config-wofi.sh"
    ["Rofi (aplikacje)"]="rofi -show drun"
    ["Selektor emoji"]="$HOME/.config/hypr/scripts/emoji-selector.sh"
    ["Rofi (uruchom)"]="rofi -show run"
    ["Pełne menu"]="$HOME/.config/hypr/scripts/wofi-fullmenu.sh"
    ["Usuń odstępy"]="hyprctl --batch 'keyword general:gaps_out 0;keyword general:gaps_in 0'"
    ["Przywróć odstępy"]="hyprctl --batch 'keyword general:gaps_out 5;keyword general:gaps_in 3'"
    ["Reset głośności"]="$HOME/.config/hypr/scripts/reset_vol_bri.sh"
    ["Pokaż/ukryj notatki"]="hyprctl dispatch togglespecialworkspace"
)

execute_command() {
    local choice="$1"
    local executed=false
    
    # Sprawdź każdy klucz w mapie komend
    for key in "${!COMMANDS[@]}"; do
        if [[ "$choice" == *"$key"* ]]; then
            notify-send "Executing" "${COMMANDS[$key]}" -t 2000
            eval "${COMMANDS[$key]}" &
            executed=true
            break
        fi
    done
    
    # Jeśli nie znaleziono komendy
    if [[ "$executed" == false ]]; then
        notify-send "Keybind Viewer" "Nie można wykonać tej akcji automatycznie" -t 3000
    fi
}

# === GŁÓWNA FUNKCJA ===
main() {
    # Sprawdź czy plik istnieje
    [[ ! -f "$KEYBIND_FILE" ]] && show_error "Plik $KEYBIND_FILE nie istnieje!"
    
    # Przygotuj dane do wyszukiwania - stwórz format "wszystkie_kolumny | oryginalny_wiersz"
    local search_data
    search_data=$(while IFS= read -r line; do
        # Usuń formatowanie markdown i stwórz wersję do wyszukiwania
        search_line=$(echo "$line" | sed 's/|/ /g' | sed 's/\*\*//g' | sed 's/`//g' | tr -s ' ')
        echo "$search_line | $line"
    done < "$KEYBIND_FILE")
    
    # Wofi command z lepszym wyszukiwaniem
    local wofi_cmd="wofi --show dmenu \
        --prompt 'Hyprland Keybinds (wyszukuj we wszystkich kolumnach)' \
        --conf $CONFIG --style $STYLE --color $COLORS \
        --width=50% --height=80% \
        --cache-file=/dev/null \
        --hide-scroll --no-actions \
        --matching=fuzzy \
        --insensitive"
    
    # Wyświetl menu i pobierz wybór
    local choice
    choice=$(echo "$search_data" | $wofi_cmd | cut -d'|' -f2-)
    
    # Wykonaj komendę jeśli coś wybrano
    [[ -n "$choice" ]] && execute_command "$choice"
}

# === URUCHOMIENIE ===
main "$@"
