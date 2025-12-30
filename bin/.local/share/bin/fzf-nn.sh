#!/usr/bin/env bash

# Ścieżka do folderu z notatkami
NOTES_DIR="$HOME/Dokumenty/Hubert/Notes/"

# Utworzenie folderu, jeśli nie istnieje
mkdir -p "$NOTES_DIR"

# Sprawdza, czy fzf jest zainstalowany
if ! command -v fzf &>/dev/null; then
  echo "Błąd: fzf nie jest zainstalowany."
  exit 1
fi

# Ustawia komendę podglądu
if command -v bat &>/dev/null; then
  preview_cmd="bat --style=numbers --color=always --line-range :500"
else
  preview_cmd="cat"
fi

# Przejście do katalogu z notatkami
cd "$NOTES_DIR" || exit 1

# Wybór notatki lub wpisanie nowej nazwy za pomocą fzf
# --print-query pozwala przechwycić wpisaną nazwę
# sort sortuje alfabetycznie
NOTE=$(find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' 2>/dev/null |
  sed 's|^\./||' |
  sort |
  fzf --print-query \
    --prompt="Nazwa notatki: " \
    --preview "$preview_cmd {}" \
    --preview-window=right:50%:wrap |
  tail -1)

# Jeśli podano nazwę notatki
if [ -n "$NOTE" ]; then
  # Otwarcie notatki w nvim
  nvim "$NOTES_DIR/$NOTE"
else
  echo "Nie podano nazwy notatki!"
  exit 1
fi
