#!/bin/bash
# Kompletny skrypt instalacji/aktualizacji Google Chrome dla Void Linux
# Obsługuje pierwsze uruchomienie i kolejne aktualizacje

VOID_DIR="$HOME/void-packages"
TEMPLATE_DIR="$HOME/void-mytemplate/google-chrome"
MY_TEMPLATE="$TEMPLATE_DIR/template"

die() { echo "Błąd: $1"; exit 1; }

# Funkcja wyświetlająca pasek postępu
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\rPostęp: ["
    printf "%*s" $completed | tr ' ' '='
    printf "%*s" $remaining | tr ' ' '-'
    printf "] %d%% (%s/%s)" $percentage $current $total
}

echo "=== Skrypt instalacji/aktualizacji Google Chrome dla Void Linux ==="

# Sprawdź i zainstaluj wymagane narzędzia
echo "Sprawdzanie wymaganych narzędzi..."
MISSING_TOOLS=""
command -v jq >/dev/null 2>&1 || MISSING_TOOLS="$MISSING_TOOLS jq"
command -v curl >/dev/null 2>&1 || MISSING_TOOLS="$MISSING_TOOLS curl"
command -v wget >/dev/null 2>&1 || MISSING_TOOLS="$MISSING_TOOLS wget"
command -v git >/dev/null 2>&1 || MISSING_TOOLS="$MISSING_TOOLS git"

if [ -n "$MISSING_TOOLS" ]; then
    echo "Instaluję brakujące narzędzia:$MISSING_TOOLS"
    sudo xbps-install -S $MISSING_TOOLS || die "Nie udało się zainstalować narzędzi"
fi

# Sklonuj void-packages jeśli nie istnieje
if [ ! -d "$VOID_DIR" ]; then
    echo "Klonuję repozytorium void-packages..."
    git clone --progress https://github.com/void-linux/void-packages.git "$VOID_DIR" || die "Nie udało się sklonować void-packages"
else
    echo "Aktualizuję repozytorium void-packages..."
    cd "$VOID_DIR" && git pull origin master
fi

cd "$VOID_DIR" || die "Nie można przejść do $VOID_DIR"

# Utwórz katalog dla szablonu jeśli nie istnieje
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Tworzę katalog dla szablonu..."
    mkdir -p "$TEMPLATE_DIR"
fi

# Sprawdź czy istnieje oryginalny szablon Google Chrome w void-packages
ORIG_TEMPLATE="srcpkgs/google-chrome/template"
if [ ! -f "$ORIG_TEMPLATE" ]; then
    echo "Brak oryginalnego szablonu Google Chrome w void-packages."
    echo "Tworzę podstawowy szablon..."

    # Utwórz katalog jeśli nie istnieje
    mkdir -p "srcpkgs/google-chrome"

    # Pobierz najnowszą wersję do utworzenia szablonu
    echo "Pobieranie informacji o najnowszej wersji Chrome..."
    LATEST_VERSION=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json | jq -r '.channels.Stable.version')

    if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
        # Fallback - spróbuj alternatywnego API
        echo "Próbuję alternatywne źródło wersji..."
        LATEST_VERSION=$(curl -s https://versionhistory.googleapis.com/v1/chrome/platforms/linux/channels/stable/versions | jq -r '.versions[0].version')

        if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
            echo "Nie można automatycznie określić wersji Chrome."
            echo "Podaj wersję ręcznie (np. 128.0.6613.84) lub naciśnij Enter aby anulować:"
            read -r MANUAL_VERSION

            if [ -n "$MANUAL_VERSION" ]; then
                LATEST_VERSION="$MANUAL_VERSION"
                echo "Używam wersji: $LATEST_VERSION"
            else
                die "Anulowano - nie można określić wersji"
            fi
        fi
    fi

    # Pobierz plik .deb do wygenerowania hash
    DEB_FILE="google-chrome-stable_${LATEST_VERSION}-1_amd64.deb"
    echo "Pobieranie Chrome $LATEST_VERSION do wygenerowania hash..."
    echo "Sprawdzanie rozmiaru pliku..."
    
    # Sprawdź rozmiar pliku przed pobraniem
    FILE_SIZE=$(curl -sI "https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/$DEB_FILE" | grep -i content-length | awk '{print $2}' | tr -d '\r')
    if [ -n "$FILE_SIZE" ] && [ "$FILE_SIZE" -gt 0 ]; then
        FILE_SIZE_MB=$((FILE_SIZE / 1024 / 1024))
        echo "Rozmiar pliku: ${FILE_SIZE_MB}MB"
    fi
    
    # Pobierz z prostym paskiem postępu
    timeout 300 wget --progress=bar:force:noscroll "https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/$DEB_FILE"
    
    if [ ! -f "$DEB_FILE" ]; then
        die "Nie udało się pobrać pliku .deb"
    fi
    
    echo "Generowanie sumy kontrolnej..."
    HASH=$(sha256sum "$DEB_FILE" | cut -d' ' -f1)
    echo "SHA256: $HASH"
    rm "$DEB_FILE"

    # Utwórz podstawowy szablon
    cat > "$ORIG_TEMPLATE" << EOF
# Template file for 'google-chrome'
pkgname=google-chrome
version=$LATEST_VERSION
revision=1
archs="x86_64"
create_wrksrc=yes
depends="desktop-file-utils hicolor-icon-theme xdg-utils"
short_desc="Google Chrome web browser"
maintainer="Auto-generated <void@localhost>"
license="custom:chrome"
homepage="https://www.google.com/chrome/"
distfiles="https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/google-chrome-stable_\${version}-1_amd64.deb"
checksum="$HASH"
repository=nonfree
restricted=yes
nostrip=yes

do_extract() {
    ar x \${XBPS_SRCDISTDIR}/\${pkgname}-\${version}/google-chrome-stable_\${version}-1_amd64.deb
    tar xf data.tar.xz
}

do_install() {
    vcopy opt /
    vcopy usr /
    
    # Remove bundled xdg-utils
    rm -rf \${DESTDIR}/opt/google/chrome/xdg-*
    
    # Install icons
    for size in 16 22 24 32 48 64 128 256; do
        if [ -f usr/share/icons/hicolor/\${size}x\${size}/apps/google-chrome.png ]; then
            vinstall usr/share/icons/hicolor/\${size}x\${size}/apps/google-chrome.png 644 \\
                usr/share/icons/hicolor/\${size}x\${size}/apps
        fi
    done
    
    # Install desktop file
    vinstall usr/share/applications/google-chrome.desktop 644 usr/share/applications
    
    # Install man page
    if [ -f usr/share/man/man1/google-chrome.1.gz ]; then
        vinstall usr/share/man/man1/google-chrome.1.gz 644 usr/share/man/man1
    fi
}
EOF
    echo "Utworzono podstawowy szablon dla wersji $LATEST_VERSION"
fi

# Skopiuj oryginalny szablon do naszego katalogu jeśli nie istnieje nasz szablon
if [ ! -f "$MY_TEMPLATE" ]; then
    echo "Tworzę kopię szablonu..."
    cp "$ORIG_TEMPLATE" "$MY_TEMPLATE"
fi

# Pobierz najnowszą wersję Chrome
echo "Sprawdzanie najnowszej wersji Chrome..."
VERSION=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json | jq -r '.channels.Stable.version')

# Sprawdź czy otrzymaliśmy prawidłową wersję
if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    echo "API Chrome for Testing nie zwróciło prawidłowej wersji."
    echo "Sprawdzanie alternatywnego źródła..."

    # Spróbuj alternatywne API
    VERSION=$(curl -s https://versionhistory.googleapis.com/v1/chrome/platforms/linux/channels/stable/versions | jq -r '.versions[0].version')

    if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
        echo "Nie udało się automatycznie określić wersji Chrome."
        echo "Sprawdź ręcznie: https://www.google.com/chrome/"
        echo "Podaj wersję ręcznie (np. 128.0.6613.84) lub naciśnij Enter aby anulować:"
        read -r MANUAL_VERSION

        if [ -n "$MANUAL_VERSION" ]; then
            VERSION="$MANUAL_VERSION"
            echo "Używam wersji: $VERSION"
        else
            die "Anulowano - nie można określić wersji"
        fi
    else
        echo "Znaleziono wersję z alternatywnego źródła: $VERSION"
    fi
fi

# Sprawdź czy już mamy tę wersję
CURRENT_VERSION=$(grep "^version=" "$MY_TEMPLATE" 2>/dev/null | cut -d'=' -f2)
if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo "Chrome $VERSION już jest aktualny!"
    echo "Chcesz przebudować mimo to? (t/N): "
    read -r response
    case "$response" in
        [tT]|[tT][aA][kK]) echo "Przebudowuję...";;
        *) echo "Anulowano."; exit 0;;
    esac
else
    echo "Nowa wersja dostępna: $CURRENT_VERSION → $VERSION"
fi

# Pobierz plik i wygeneruj hash
echo ""
echo "Pobieranie Chrome $VERSION..."
DEB_FILE="google-chrome-stable_${VERSION}-1_amd64.deb"
DOWNLOAD_URLS=(
    "https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/$DEB_FILE"
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
)

DOWNLOAD_SUCCESS=0
for i in "${!DOWNLOAD_URLS[@]}"; do
    URL="${DOWNLOAD_URLS[$i]}"
    echo "Próba $((i+1))/${#DOWNLOAD_URLS[@]}: $(basename "$URL")"
    
    # Sprawdź rozmiar pliku przed pobraniem
    FILE_SIZE=$(curl -sI "$URL" | grep -i content-length | awk '{print $2}' | tr -d '\r')
    if [ -n "$FILE_SIZE" ] && [ "$FILE_SIZE" -gt 0 ]; then
        FILE_SIZE_MB=$((FILE_SIZE / 1024 / 1024))
        echo "Rozmiar pliku: ${FILE_SIZE_MB}MB"
    fi
    
    # Pobierz z paskiem postępu i limitem czasu
    echo "Pobieranie w toku..."
    
    # Użyj wget z prostym paskiem postępu w tle
    if timeout 300 wget --progress=bar:force:noscroll --timeout=60 --tries=2 "$URL" -O "$DEB_FILE"; then
        echo "Pobrano pomyślnie z: $(basename "$URL")"
        DOWNLOAD_SUCCESS=1
        break
    else
        echo "Nie udało się z: $(basename "$URL")"
        rm -f "$DEB_FILE"
    fi
done

if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
    rm -f "$DEB_FILE"
    die "Nie udało się pobrać pliku Chrome .deb z żadnego źródła"
fi

# Sprawdź czy plik został pobrany i ma odpowiedni rozmiar
if [ ! -f "$DEB_FILE" ]; then
    die "Plik nie został pobrany"
fi

ACTUAL_SIZE=$(stat -c%s "$DEB_FILE" 2>/dev/null || echo "0")
if [ "$ACTUAL_SIZE" -lt 50000000 ]; then  # Mniej niż 50MB to prawdopodobnie błąd
    echo "Ostrzeżenie: Pobrany plik wydaje się być za mały ($(($ACTUAL_SIZE / 1024 / 1024))MB)"
    echo "Czy chcesz kontynuować? (t/N): "
    read -r response
    case "$response" in
        [tT]|[tT][aA][kK]) ;;
        *) rm -f "$DEB_FILE"; die "Anulowano przez użytkownika";;
    esac
fi

echo "Generowanie sumy kontrolnej SHA256..."
HASH=$(sha256sum "$DEB_FILE" | cut -d' ' -f1)
echo "SHA256: $HASH"
rm "$DEB_FILE"

# Aktualizuj mój szablon
echo "Aktualizuję szablon do wersji $VERSION..."
sed -i "s/version=.*/version=$VERSION/" "$MY_TEMPLATE"
sed -i "s/checksum=.*/checksum=\"$HASH\"/" "$MY_TEMPLATE"

# Podmiana szablonów
[ -f "$ORIG_TEMPLATE" ] && mv "$ORIG_TEMPLATE" "$ORIG_TEMPLATE.backup"
cp "$MY_TEMPLATE" "$ORIG_TEMPLATE"

# Buduj i instaluj
echo ""
echo "Budowanie Chrome..."
export XBPS_DISTDIR=$(pwd)

# Upewnij się, że binary-bootstrap jest wykonany
if [ ! -d "hostdir" ]; then
    echo "Inicjalizuję środowisko budowania..."
    ./xbps-src binary-bootstrap || die "Nie udało się zainicjalizować środowiska"
fi

# Sprawdź czy konfiguracja pozwala na restricted packages
if ! grep -q "XBPS_ALLOW_RESTRICTED=yes" etc/conf 2>/dev/null; then
    echo "Włączam obsługę pakietów restricted..."
    echo "XBPS_ALLOW_RESTRICTED=yes" >> etc/conf
fi

# Wyczyść poprzednie buildy
echo "Czyszczenie poprzednich buildów..."
./xbps-src clean google-chrome 2>/dev/null

echo "Kompilowanie Chrome (to może potrwać kilka minut)..."
if ./xbps-src pkg google-chrome; then
    echo "Budowanie zakończone pomyślnie!"
else
    die "Budowanie nie powiodło się"
fi

echo "Instalowanie Chrome..."
if sudo xbps-install --repository=hostdir/binpkgs/nonfree -u google-chrome -y; then
    echo "Instalacja zakończona pomyślnie!"
else
    die "Instalacja nie powiodła się"
fi

# Przywróć oryginalny szablon
rm "$ORIG_TEMPLATE"
[ -f "$ORIG_TEMPLATE.backup" ] && mv "$ORIG_TEMPLATE.backup" "$ORIG_TEMPLATE"

echo ""
echo "=================================="
echo "Chrome zaktualizowany do wersji $VERSION!"
echo "Możesz teraz uruchomić przeglądarkę: google-chrome"
echo "Szablon zapisany w: $MY_TEMPLATE"
echo "=================================="

# Sprawdź czy chrome rzeczywiście działa
if command -v google-chrome >/dev/null 2>&1; then
    echo "Weryfikacja instalacji..."
    INSTALLED_VERSION=$(google-chrome --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$INSTALLED_VERSION" ]; then
        echo "Chrome $INSTALLED_VERSION zainstalowany i gotowy do użycia!"
    else
        echo "Chrome zainstalowany (sprawdź wersję: google-chrome --version)"
    fi
else
    echo "Chrome może wymagać ponownego zalogowania lub aktualizacji PATH"
fi