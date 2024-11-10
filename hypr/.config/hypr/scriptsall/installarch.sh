#!/bin/bash

# Stałe - nazwa użytkownika i token
GITHUB_USERNAME="twoja_nazwa_uzytkownika"
GITHUB_TOKEN="twój_token_personalny"

# Hasło zabezpieczające skrypt (możesz zostawić puste, jeśli nie chcesz podawać hasła ręcznie)
haslo_zabezpieczajace="twoje_haslo"

# Lokalizacja folderu docelowego
folder_docelowy="$HOME/Dokumenty/Github Desktop"

# Sprawdzenie, czy hasło jest ustawione
if [ -n "$haslo_zabezpieczajace" ]; then
    echo -n "Podaj hasło zabezpieczające skrypt: "
    read -s podane_haslo
    echo

    if [ "$podane_haslo" != "$haslo_zabezpieczajace" ]; then
        echo "Błędne hasło. Zakończono."
        exit 1
    fi
fi

# Tworzenie folderu docelowego
mkdir -p "$folder_docelowy"

# Przejście do folderu docelowego
cd "$folder_docelowy" || exit

# --- Pierwsza część skryptu: Klonowanie repozytorium GitHuba ---

# Ścieżka docelowa, gdzie chcesz sklonować repozytorium
sciezka_docelowa="$folder_docelowy/sciezka/do/sklonowania/repozytorium"

# Repozytorium do sklonowania
repozytorium="nazwa_uzytkownika/nazwa_repozytorium"

# Tworzenie pliku konfiguracyjnego git z hasłem lub tokenem
echo "machine github.com login $GITHUB_USERNAME password $GITHUB_TOKEN" > ~/.netrc
chmod 600 ~/.netrc

# Klonowanie repozytorium
git clone "https://github.com/$repozytorium" "$sciezka_docelowa"

# Sprzątanie - usuwanie pliku konfiguracyjnego z hasłem lub tokenem
rm -f ~/.netrc

echo "Zakończono proces klonowania repozytorium."

# --- Druga część skryptu: Przeniesienie do folderu źródłowego i wykonanie operacji ---

# Lokalizacja folderu źródłowego
folder_zrodlowy="$folder_docelowy/sciezka/do/sklonowania/repozytorium"

# Sprawdzenie, czy folder źródłowy istnieje
if [ -d "$folder_zrodlowy" ]; then
    cd "$folder_zrodlowy" || exit

    # Tutaj możesz dodać operacje na folderze źródłowym, na przykład skrypt z wcześniejszych odpowiedzi

    echo "Przeszedłem do folderu źródłowego: $folder_zrodlowy"
else
    echo "Folder źródłowy nie istnieje: $folder_zrodlowy"
fi
