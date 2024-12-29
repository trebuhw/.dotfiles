#!/bin/bash

# Sprawdzenie, czy podano tytuł i treść
if [ "$#" -ne 2 ]; then
    echo "Użycie: $0 <tytuł> <treść>"
    exit 1
fi

# Ustawienie zmiennych
TITLE="$1"
MESSAGE="$2"

# Wyświetlenie powiadomienia z długim czasem trwania
DISPLAY=:0 notify-send -t 999999999 "$TITLE" "$MESSAGE"

