#!/bin/bash

# Ścieżka do folderu z notatkami
NOTES_DIR="$HOME/Dropbox/Notes"

# Utworzenie folderu, jeśli nie istnieje
mkdir -p "$NOTES_DIR"

# Wybór notatki lub wpisanie nowej nazwy za pomocą fzf
# --print-query pozwala przechwycić wpisaną nazwę
NOTE=$(ls "$NOTES_DIR" 2>/dev/null | fzf --print-query --prompt="Nazwa notatki: " | tail -1)

# Jeśli podano nazwę notatki
if [ -n "$NOTE" ]; then
    # Otwarcie notatki w nvim w bieżącym terminalu
    nvim "$NOTES_DIR/$NOTE"
else
    echo "Nie podano nazwy notatki!"
    exit 1
fi
