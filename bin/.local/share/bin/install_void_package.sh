#!/usr/bin/env bash

# Sprawdzenie, czy podano nazwę pakietu
if [ -z "$1" ]; then
    echo "Błąd: Podaj nazwę pakietu do wyszukania."
    echo "Użycie: $0 <nazwa-pakietu>"
    exit 1
fi

SEARCH_TERM="$1"
REPO_DIR="$HOME/void-packages"
SRCPKGS_DIR="$REPO_DIR/srcpkgs"

# Sprawdzenie, czy katalog void-packages istnieje
if [ ! -d "$SRCPKGS_DIR" ]; then
    echo "Błąd: Katalog $SRCPKGS_DIR nie istnieje. Upewnij się, że repozytorium void-packages jest sklonowane i skonfigurowane."
    exit 1
fi

# Wyszukiwanie pasujących pakietów
echo "Wyszukiwanie pakietów pasujących do '$SEARCH_TERM'..."
mapfile -t MATCHING_PACKAGES < <(ls "$SRCPKGS_DIR" | grep -i "$SEARCH_TERM")

# Sprawdzenie, czy znaleziono pasujące pakiety
if [ ${#MATCHING_PACKAGES[@]} -eq 0 ]; then
    echo "Brak pakietów pasujących do '$SEARCH_TERM' w repozytorium void-packages."
    exit 1
elif [ ${#MATCHING_PACKAGES[@]} -eq 1 ]; then
    # Jeśli znaleziono dokładnie jeden pakiet, wybierz go automatycznie
    SELECTED_PACKAGE="${MATCHING_PACKAGES[0]}"
    echo "Znaleziono jeden pasujący pakiet: $SELECTED_PACKAGE"
else
    # Wyświetlenie listy pasujących pakietów do wyboru
    echo "Znaleziono następujące pasujące pakiety:"
    for i in "${!MATCHING_PACKAGES[@]}"; do
        echo "$((i+1)). ${MATCHING_PACKAGES[i]}"
    done

    # Pobieranie wyboru użytkownika
    while true; do
        read -p "Wybierz numer pakietu do instalacji (1-${#MATCHING_PACKAGES[@]}): " CHOICE
        if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le ${#MATCHING_PACKAGES[@]} ]; then
            SELECTED_PACKAGE="${MATCHING_PACKAGES[$((CHOICE-1))]}"
            echo "Wybrano pakiet: $SELECTED_PACKAGE"
            break
        else
            echo "Błąd: Podaj poprawny numer (1-${#MATCHING_PACKAGES[@]})."
        fi
    done
fi

# Przejście do katalogu void-packages
cd "$REPO_DIR" || {
    echo "Błąd: Nie można przejść do katalogu $REPO_DIR."
    exit 1
}

# Budowanie pakietu
echo "Budowanie pakietu $SELECTED_PACKAGE..."
./xbps-src pkg "$SELECTED_PACKAGE"
if [ $? -eq 0 ]; then
    echo "Pakiet $SELECTED_PACKAGE został zbudowany pomyślnie."
else
    echo "Błąd podczas budowania pakietu $SELECTED_PACKAGE. Sprawdź logi w $REPO_DIR/hostdir/binpkgs."
    exit 1
fi

# Instalacja pakietu
echo "Instalowanie pakietu $SELECTED_PACKAGE..."
sudo xbps-install "$SELECTED_PACKAGE"
if [ $? -eq 0 ]; then
    echo "Pakiet $SELECTED_PACKAGE został zainstalowany pomyślnie."
else
    echo "Błąd podczas instalowania pakietu $SELECTED_PACKAGE."
    exit 1
fi

# Czyszczenie po instalacji
echo "Czyszczenie plików tymczasowych i pamięci podręcznej..."

# Czyszczenie lokalnych plików budowania w void-packages
echo "Czyszczenie lokalnych plików budowania w $REPO_DIR..."
./xbps-src clean
if [ $? -eq 0 ]; then
    echo "Lokalne pliki budowania wyczyszczone."
else
    echo "Błąd podczas czyszczenia lokalnych plików budowania."
fi

# Czyszczenie pamięci podręcznej XBPS
echo "Czyszczenie pamięci podręcznej XBPS..."
sudo xbps-remove -C -y
if [ $? -eq 0 ]; then
    echo "Pamięć podręczna XBPS wyczyszczona."
else
    echo "Błąd podczas czyszczenia pamięci podręcznej XBPS."
fi

echo "Proces instalacji i czyszczenia zakończony."
