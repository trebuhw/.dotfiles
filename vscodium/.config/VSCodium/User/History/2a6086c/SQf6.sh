#!/bin/bash
# Skrypt do aktualizacji Google Chrome w Void Linux za pomocą xbps-src
# Używa szablonu z ~/void-maytemplate/google-chrome i chroni oryginalny szablon

VOID_PACKAGES_DIR="$HOME/void-packages"
CUSTOM_TEMPLATE_DIR="$HOME/void-mytemplate/google-chrome"
TEMPLATE_FILE="${VOID_PACKAGES_DIR}/srcpkgs/google-chrome/template"
ORIGINAL_TEMPLATE="${VOID_PACKAGES_DIR}/srcpkgs/google-chrome/template.org"

# 1. Sprawdzanie zależności
for pkg in jq wget coreutils sed git; do
    if ! command -v "$pkg" >/dev/null; then
        echo "Instalowanie $pkg..."
        sudo xbps-install -S "$pkg" || {
            echo "Błąd: Nie udało się zainstalować $pkg"
            exit 1
        }
    fi
done

# 2. Sprawdzanie katalogów
if [ ! -d "$VOID_PACKAGES_DIR" ]; then
    echo "Błąd: Katalog $VOID_PACKAGES_DIR nie istnieje!"
    exit 1
fi
if [ ! -d "$CUSTOM_TEMPLATE_DIR" ] || [ ! -f "$CUSTOM_TEMPLATE_DIR/template" ]; then
    echo "Błąd: Katalog $CUSTOM_TEMPLATE_DIR lub plik template nie istnieje!"
    exit 1
fi

cd "$VOID_PACKAGES_DIR" || {
    echo "Błąd: Nie można przejść do $VOID_PACKAGES_DIR"
    exit 1
}

# 3. Zarządzanie szablonami
echo "Przygotowywanie szablonu..."
mkdir -p srcpkgs/google-chrome/files

# Przenieś oryginalny szablon na template.org, jeśli istnieje
if [ -f "$TEMPLATE_FILE" ]; then
    if [ -f "$ORIGINAL_TEMPLATE" ]; then
        echo "Ostrzeżenie: Plik template.org już istnieje. Usuwam stary backup..."
        rm "$ORIGINAL_TEMPLATE"
    fi
    mv "$TEMPLATE_FILE" "$ORIGINAL_TEMPLATE" || {
        echo "Błąd: Nie udało się przenieść oryginalnego szablonu"
        exit 1
    }
    echo "Oryginalny szablon zabezpieczony jako template.org"
else
    echo "Ostrzeżenie: Nie znaleziono oryginalnego szablonu template"
fi

# Skopiuj niestandardowy szablon i pliki
cp "$CUSTOM_TEMPLATE_DIR/template" "$TEMPLATE_FILE" || {
    echo "Błąd: Nie udało się skopiować niestandardowego szablonu"
    exit 1
}
if [ -d "$CUSTOM_TEMPLATE_DIR/files" ]; then
    cp -r "$CUSTOM_TEMPLATE_DIR/files/"* srcpkgs/google-chrome/files/ || {
        echo "Błąd: Nie udało się skopiować plików szablonu"
        exit 1
    }
fi

# 4. Ustawienie XBPS_DISTDIR
export XBPS_DISTDIR=$(pwd)

# 5. Inicjalizacja środowiska xbps-src
echo "Inicjalizowanie środowiska xbps-src..."
./xbps-src binary-bootstrap || {
    echo "Błąd: Nie udało się zainicjalizować środowiska xbps-src"
    exit 1
}

# 6. Włączenie pakietów nonfree
if ! grep -q "XBPS_ALLOW_RESTRICTED=yes" etc/conf; then
    echo "XBPS_ALLOW_RESTRICTED=yes" >> etc/conf
fi

# 7. Aktualizacja repozytorium
echo "Aktualizowanie repozytorium void-packages..."
git pull origin master || {
    echo "Błąd: Nie udało się zaktualizować repozytorium"
    exit 1
}

# 8. Pobieranie numeru wersji
echo "Pobieranie najnowszej wersji Google Chrome..."
CHROME_VERSION=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json | jq -r '.channels.Stable.version')
if [ -z "$CHROME_VERSION" ]; then
    echo "Błąd: Nie udało się pobrać numeru wersji"
    exit 1
fi
CHROME_URL="https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb"

# 9. Pobieranie pliku i generowanie sumy kontrolnej
echo "Pobieranie pliku dla wersji $CHROME_VERSION..."
wget -q "$CHROME_URL" -O "google-chrome-stable_${CHROME_VERSION}-1_amd64.deb" || {
    echo "Błąd: Nie udało się pobrać pliku. Sprawdź wersję lub URL."
    exit 1
}

echo "Generowanie sumy kontrolnej..."
CHECKSUM=$(sha256sum "google-chrome-stable_${CHROME_VERSION}-1_amd64.deb" | cut -d ' ' -f 1)
if [ -z "$CHECKSUM" ]; then
    echo "Błąd: Nie udało się wygenerować sumy kontrolnej"
    exit 1
fi

# 10. Aktualizacja szablonu
echo "Aktualizowanie szablonu dla wersji $CHROME_VERSION..."
sed -i "s/version=.*/version=$CHROME_VERSION/" "$TEMPLATE_FILE"
sed -i 's/checksum=.*/checksum="'"$CHECKSUM"'"/' "$TEMPLATE_FILE"

# 11. Budowanie pakietu
echo "Budowanie pakietu Google Chrome..."
./xbps-src pkg google-chrome || {
    echo "Błąd: Nie udało się zbudować pakietu. Sprawdź logi w hostdir/buildlogs/google-chrome."
    exit 1
}

# 12. Instalacja pakietu
echo "Instalowanie Google Chrome..."
sudo xbps-install --repository=hostdir/binpkgs/nonfree -u google-chrome -y || {
    echo "Błąd: Nie udało się zainstalować pakietu"
    exit 1
}

# 13. Przywracanie szablonów
echo "Przywracanie oryginalnego szablonu..."
# Usuń tylko nasz niestandardowy szablon
if [ -f "$TEMPLATE_FILE" ]; then
    rm "$TEMPLATE_FILE" || {
        echo "Błąd: Nie udało się usunąć niestandardowego szablonu"
        exit 1
    }
fi

# Usuń pliki skopiowane z naszego szablonu (tylko jeśli istnieją)
if [ -d "$CUSTOM_TEMPLATE_DIR/files" ]; then
    echo "Usuwanie plików niestandardowego szablonu..."
    rm -rf srcpkgs/google-chrome/files
fi

# Przywróć oryginalny szablon
if [ -f "$ORIGINAL_TEMPLATE" ]; then
    mv "$ORIGINAL_TEMPLATE" "$TEMPLATE_FILE" || {
        echo "Błąd: Nie udało się przywrócić oryginalnego szablonu"
        exit 1
    }
else
    echo "Ostrzeżenie: Nie znaleziono oryginalnego szablonu do przywrócenia!"
fi

# 14. Czyszczenie
rm -f "google-chrome-stable_${CHROME_VERSION}-1_amd64.deb"
echo "Google Chrome zaktualizowany do wersji $CHROME_VERSION!"