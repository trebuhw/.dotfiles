#!/bin/bash

# Sprawdzenie, czy podano argument (datę)
if [ -z "$1" ]; then
  echo "Proszę podać datę jako argument."
  exit 1
fi

# Przypisanie daty z argumentu
date=$1

# Wyświetlanie tylko wyników zawierających 'installed' i pasujących do podanej daty
grep "$date" /var/log/pacman.log | grep 'installed' | bat
