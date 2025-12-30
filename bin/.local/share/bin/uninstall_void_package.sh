#!/usr/bin/env bash

# Sprawdzenie, czy podano nazwę pakietu
if [ -z "$1" ]; then
    echo "Błąd: Podaj nazwę pakietu do odinstalowania."
    echo "Użycie: $0 <nazwa-pakietu>"
    exit 1
fi

PACKAGE="$1"
REPO_DIR="$HOME/void-packages"

# Sprawdzenie, czy pakiet jest zainstalowany
if xbps-query "$PACKAGE" >/dev/null 2>&1; then
    echo "Znaleziono pakiet $PACKAGE, przystępuję do odinstalowania..."
    # Odinstalowanie pakietu
    sudo xbps-remove -y "$PACKAGE"
    if [ $? -eq 0 ]; then
        echo "Pakiet $PACKAGE został odinstalowany."
    else
        echo "Błąd podczas odinstalowywania pakietu $PACKAGE."
        exit 1
    fi
else
    echo "Błąd: Pakiet $PACKAGE nie jest zainstalowany."
    exit 1
fi

# Usuwanie nieużywanych zależności
echo "Sprawdzanie i usuwanie nieużywanych zależności..."
sudo xbps-remove -O -y
if [ $? -eq 0 ]; then
    echo "Nieużywane zależności usunięte."
else
    echo "Brak nieużywanych zależności lub błąd podczas ich usuwania."
fi

# Czyszczenie pamięci podręcznej XBPS
echo "Czyszczenie pamięci podręcznej XBPS..."
sudo xbps-remove -C -y
if [ $? -eq 0 ]; then
    echo "Pamięć podręczna XBPS wyczyszczona."
else
    echo "Błąd podczas czyszczenia pamięci podręcznej XBPS."
fi

# Czyszczenie lokalnych plików budowania w void-packages
if [ -d "$REPO_DIR" ]; then
    echo "Czyszczenie lokalnych plików budowania w $REPO_DIR..."
    cd "$REPO_DIR" || exit 1
    ./xbps-src clean
    if [ $? -eq 0 ]; then
        echo "Lokalne pliki budowania wyczyszczone."
    else
        echo "Błąd podczas czyszczenia lokalnych plików budowania."
    fi
else
    echo "Katalog $REPO_DIR nie istnieje, pomijam czyszczenie lokalnych plików."
fi

echo "Proces odinstalowywania zakończony."
