#!/bin/bash

# Lista lokalizacji, z których pobierane są programy
search_paths=("/usr/bin" "$HOME/.local/bin")

# Znajdź wszystkie pliki wykonywalne w podanych lokalizacjach
selected_program=$(find ${search_paths[*]} -maxdepth 1 -type f -executable | fzf)

if [ -n "$selected_program" ]; then
    $selected_program
else
    echo "Nie wybrano żadnego programu."
fi

