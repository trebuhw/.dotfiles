#!/bin/bash

# Sprawdzenie, czy podano wiadomość commita
if [ -z "$1" ]; then
    echo "Błąd: Podaj wiadomość commita w cudzysłowie, np. mgacp \"moja wiadomość\""
    exit 1
fi

# Pobieranie zmian z repozytorium
echo "Pobieranie zmian z repozytorium..."
mgpull

# Wyświetlanie statusu zmian
echo -e "\nStatus zmian:"
mgs

# Dodawanie wszystkich zmian
echo -e "\nDodawanie wszystkich zmian..."
mga .

# Tworzenie commita
echo -e "\nTworzenie commita z wiadomością: $1"
mgcom "$1"

# Wypychanie zmian
echo -e "\nWypychanie zmian..."
mgpush

# Potwierdzenie zakończenia
echo "Zakończono!"
