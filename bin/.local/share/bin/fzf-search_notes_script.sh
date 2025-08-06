#!/bin/bash

# Ścieżka do folderu z notatkami
NOTES_DIR="$HOME/pCloudDrive/Notes"

# Sprawdza, czy katalog z notatkami istnieje
if [ ! -d "$NOTES_DIR" ]; then
    echo "Błąd: Katalog z notatkami nie istnieje: $NOTES_DIR"
    exit 1
fi

# Sprawdza, czy fzf jest zainstalowany
if ! command -v fzf &> /dev/null; then
    echo "Błąd: fzf nie jest zainstalowany."
    exit 1
fi

# Ustawia komendę podglądu
if command -v bat &> /dev/null; then
    preview_cmd="bat --style=numbers --color=always --line-range :500"
else
    preview_cmd="cat"
fi

# Przejście do katalogu z notatkami
cd "$NOTES_DIR" || exit 1

# Sprawdza, czy są jakieś pliki do wyboru
if [ -z "$(find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' 2>/dev/null)" ]; then
    echo "Brak notatek do edycji w katalogu: $NOTES_DIR"
    exit 1
fi

# Wybór istniejącej notatki za pomocą fzf
NOTE=$(find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' 2>/dev/null | \
    sed 's|^\./||' | \
    sort | \
    fzf --prompt="Wybierz notatkę do edycji: " \
        --preview "$preview_cmd {}" \
        --preview-window=right:50%:wrap)

# Jeśli wybrano notatkę
if [ -n "$NOTE" ]; then
    # Otwarcie notatki w nvim
    nvim "$NOTES_DIR/$NOTE"
else
    echo "Nie wybrano żadnej notatki!"
    exit 1
fi