#!/bin/bash

# Sprawdza, czy podano argument (ścieżkę)
if [ -z "$1" ]; then
  # Jeśli nie podano ścieżki, przeszukuje od bieżącego katalogu
  search_path=$(pwd)
else
  # Jeśli podano ścieżkę, używa jej (sprawdza, czy istnieje)
  search_path="$1"
  if [ ! -d "$search_path" ]; then
    echo "Błąd: Ścieżka '$search_path' nie istnieje lub nie jest katalogiem."
    exit 1
  fi
fi

# Sprawdza, czy fzf jest zainstalowany
if ! command -v fzf &> /dev/null; then
    echo "Błąd: fzf nie jest zainstalowany. Zainstaluj za pomocą: sudo apt install fzf"
    exit 1
fi

# Sprawdza, czy bat jest zainstalowany (opcjonalnie)
if ! command -v bat &> /dev/null; then
    echo "Ostrzeżenie: bat nie jest zainstalowany. Podgląd będzie używał cat."
    preview_cmd="cat {}"
else
    preview_cmd="bat --style=numbers --color=always --line-range :500 {}"
fi

echo "Przeszukiwanie plików w: $search_path"

# Debug: sprawdź ile plików zostanie znalezionych
echo "Debug - testowanie find:"
echo "1. ls -la output:"
ls -la "$search_path"
echo "2. find z -maxdepth 1:"
find "$search_path" -maxdepth 1 -type f
echo "3. find bez -type f:"
find "$search_path" -maxdepth 1
echo "4. użycie ls zamiast find:"
ls -1 "$search_path"/*.* 2>/dev/null | wc -l

# Użyj ls jako fallback
file_list=$(ls -1 "$search_path"/* 2>/dev/null | grep -v "/$")
file_count=$(echo "$file_list" | wc -l)
echo "Znaleziono $file_count plików w: $search_path"

# Jeśli nie ma plików, zakończ
if [ "$file_count" -eq 0 ] || [ -z "$file_list" ]; then
    echo "Brak plików do wyświetlenia w podanej lokalizacji."
    exit 0
fi

# Użyj ls zamiast find jeśli find nie działa
if [ -n "$file_list" ]; then
    selected_file=$(echo "$file_list" | fzf --preview "$preview_cmd" --preview-window=right:50%:wrap --header="Wybierz plik do otwarcia w nvim ($file_count plików)")
else
    # Przeszukuje pliki (w tym ukryte) i otwiera wybrany w nvim - fallback do find
    selected_file=$(find "$search_path" -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' -not -path '*/.cache/*' 2>/dev/null | fzf --preview "$preview_cmd" --preview-window=right:50%:wrap --header="Wybierz plik do otwarcia w nvim ($file_count plików)")
fi

# Sprawdza, czy wybrano plik
if [ -n "$selected_file" ]; then
    echo "Otwieranie pliku: $selected_file"
    nvim "$selected_file"
else
    echo "Nie wybrano żadnego pliku."
fi