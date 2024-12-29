#!/bin/bash

# Sprawdzenie, czy podano tytuł i treść
if [ "$#" -ne 2 ]; then
    echo "Użycie: $0 <tytuł> <treść>"
    exit 1
fi

# Ustawienie zmiennych
TITLE="$1"
MESSAGE="$2"

# Wyświetlenie okna Zenity z motywem Nordic-darker, ustawionym rozmiarem
DISPLAY=:0 GTK_THEME=Nordic-darker zenity --info --text="$MESSAGE" --title="$TITLE" --width=300 --height=150

