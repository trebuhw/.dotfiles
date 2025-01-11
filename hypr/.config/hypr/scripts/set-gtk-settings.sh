#!/bin/sh

# Lokalizacja pliku settings.ini
SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"

# Sprawdzenie, czy plik istnieje
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Plik $SETTINGS_FILE nie istnieje!"
    exit 1
fi

# Pobieranie wartości z pliku settings.ini
GTK_THEME=$(awk -F '=' '/gtk-theme-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
GTK_ICON_THEME=$(awk -F '=' '/gtk-icon-theme-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
GTK_FONT=$(awk -F '=' '/gtk-font-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
GTK_CURSOR_THEME=$(awk -F '=' '/gtk-cursor-theme-name/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')
GTK_CURSOR_SIZE=$(awk -F '=' '/gtk-cursor-theme-size/ {print $2}' "$SETTINGS_FILE" | tr -d ' ')

# Zastosowanie ustawień za pomocą gsettings
sleep 3  # Opóźnienie, aby zapewnić pełne załadowanie środowiska
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$GTK_ICON_THEME"
gsettings set org.gnome.desktop.interface font-name "$GTK_FONT"
gsettings set org.gnome.desktop.interface cursor-theme "$GTK_CURSOR_THEME"
gsettings set org.gnome.desktop.interface cursor-size "$GTK_CURSOR_SIZE"

ln -sf ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

echo "Zastosowano ustawienia GTK:"
echo "Motyw: $GTK_THEME"
echo "Ikony: $GTK_ICON_THEME"
echo "Czcionka: $GTK_FONT"
echo "Kursor: $GTK_CURSOR_THEME"
echo "Rozmiar kursora: $GTK_CURSOR_SIZE"
echo "Utworzono link do ustawień gtk-4.0"




