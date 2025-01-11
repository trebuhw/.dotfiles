#!/bin/bash

## Pobranie ustawień z pliku settings.ini
SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Plik $SETTINGS_FILE nie istnieje!"
    exit 1
fi

THEME=$(awk -F '=' '/gtk-theme-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
# ICONS=$(awk -F '=' '/gtk-icon-theme-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
# FONT=$(awk -F '=' '/gtk-font-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
CURSOR=$(awk -F '=' '/gtk-cursor-theme-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
CURSORSIZE=$(awk -F '=' '/gtk-cursor-theme-size/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')

SCHEMA1='gsettings set org.gnome.desktop.'
SCHEMA2='interface'
SCHEMA3='wm.preferences'

apply_themes() {
    sleep 5  # Opóźnienie 5 sekund
    ${SCHEMA1}${SCHEMA2} gtk-theme "$THEME"
#    ${SCHEMA1}${SCHEMA2} icon-theme "$ICONS"
    ${SCHEMA1}${SCHEMA2} cursor-theme "$CURSOR"
    ${SCHEMA1}${SCHEMA2} cursor-size "$CURSORSIZE"
#    ${SCHEMA1}${SCHEMA2} font-name "$FONT"
    ${SCHEMA1}${SCHEMA3} theme "$THEME"
}

sleep 5 && ln -sf ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

apply_themes

