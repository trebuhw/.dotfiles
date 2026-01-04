#!/bin/bash

# Sprawdzenie, czy podano argument (datę)
if [ -z "$1" ]; then
  echo "Proszę podać datę jako argument."
  exit 1
fi

# Przypisanie daty z argumentu
data=$1

# Wyświetlanie tylko wyników zawierających 'installed' i mniejszych niż podana data
awk -v date="$data" '$0 < "["date && /installed/ {print $0}' /var/log/pacman.log | bat
