#!/usr/bin/env bash

# Sprawdź zmienne środowiskowe Wayland
if [[ -z "$WAYLAND_DISPLAY" ]] && [[ -z "$DISPLAY" ]]; then
    echo "Błąd: Brak dostępu do display server"
    exit 1
fi

# Files - sprawdź czy pliki konfiguracyjne istnieją
CONFIG="$HOME/.config/wofi/config"
STYLE="$HOME/.config/wofi/style.css"
COLORS="$HOME/.config/wofi/colors"

# wofi window config (in %)
WIDTH=38
HEIGHT=80

# Plik z keybinds
KEYBIND_FILE="/home/hubert/.dotfiles/hypr/.config/hypr/keybind.md"

## Wofi Command - bez plików konfiguracyjnych jeśli nie istnieją
if [[ -f "$CONFIG" && -f "$STYLE" && -f "$COLORS" ]]; then
    wofi_command="wofi --show dmenu \
                --prompt 'Keybinds' \
                --conf $CONFIG --style $STYLE --color $COLORS \
                --width=$WIDTH% --height=$HEIGHT% \
                --cache-file=/dev/null \
                --hide-scroll --no-actions \
                --matching=fuzzy"
else
    wofi_command="wofi --show dmenu \
                --prompt 'Keybinds' \
                --width=$WIDTH% --height=$HEIGHT% \
                --cache-file=/dev/null \
                --hide-scroll --no-actions \
                --matching=fuzzy"
fi

main() {
    # Sprawdź czy plik istnieje
    if [[ ! -f "$KEYBIND_FILE" ]]; then
        echo "Błąd: Plik $KEYBIND_FILE nie istnieje!" | ${wofi_command}
        exit 1
    fi
    
    # Wyświetl zawartość pliku z sortowaniem alfabetycznym
    cat "$KEYBIND_FILE" | ${wofi_command}
}

# Check if wofi is already running
if pidof wofi >/dev/null; then
    killall wofi
    exit 0
else
    main
fi
