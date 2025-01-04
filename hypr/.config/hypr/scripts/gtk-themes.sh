#!/bin/bash

# Dostępne opcje jeśli coś nie działa ustawić start w hyprland
#
# Ustawia każdorazowo poprawny cursor w aplikacjach gtk4. Ustawine opóźnienie bo skrypt ładował się wcześniej niż uruchomił się hyprland
sleep 5 && gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'

# Pozostałe opcje
# gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font'
# gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standart-Blue-Dark'
# gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dracula-dark'
