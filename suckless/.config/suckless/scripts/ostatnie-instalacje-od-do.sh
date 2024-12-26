#!/bin/bash

# Sprawdzenie, czy podano dwa argumenty (daty)
if [ $# -ne 2 ]; then
  echo "Proszę podać dwie daty jako argumenty: początkową i końcową."
  exit 1
fi

# Przypisanie dat z argumentów
start_date=$1
end_date=$2

# Wyświetlanie tylko wyników zawierających 'installed' i mieszczących się pomiędzy podanymi datami
awk -v start="$start_date" -v end="$end_date" \
  '$0 >= "["start && $0 <= "["end && /installed/ {print $0}' /var/log/pacman.log | bat
