#!/usr/bin/env bash

# Sprawdza, czy podano argument (ścieżkę)
if [ -z "$1" ]; then
  search_path=$(pwd)
else
  search_path="$1"
  if [ ! -d "$search_path" ]; then
    echo "Błąd: Ścieżka '$search_path' nie istnieje."
    exit 1
  fi
fi

# Sprawdza, czy fzf jest zainstalowany
if ! command -v fzf &> /dev/null; then
    echo "Błąd: fzf nie jest zainstalowany."
    exit 1
fi

# Ustawia komendę podglądu
if command -v bat &> /dev/null; then
    preview_cmd="bat --style=numbers --color=always --line-range :500 {}"
else
    preview_cmd="cat {}"
fi

# Znajduje pliki (podąża za linkami symbolicznymi) i otwiera w nvim
selected_file=$(find -L "$search_path" -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' 2>/dev/null | fzf --preview "$preview_cmd" --preview-window=right:50%:wrap)

if [ -n "$selected_file" ]; then
    nvim "$selected_file"
fi
