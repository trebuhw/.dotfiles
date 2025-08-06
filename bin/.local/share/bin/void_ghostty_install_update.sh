#!/usr/bin/env bash

# Kompletny skrypt instalacji/aktualizacji Ghostty dla Void Linux
# Obsługuje pierwsze uruchomienie i kolejne aktualizacje

VOID_DIR="$HOME/void-packages"
TEMPLATE_DIR="$HOME/void-mytemplate/ghostty"
MY_TEMPLATE="$TEMPLATE_DIR/template"

die() { echo "Błąd: $1"; exit 1; }

echo "=== Skrypt instalacji/aktualizacji Ghostty dla Void Linux ==="

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
    git clone https://github.com/void-linux/void-packages.git "$VOID_DIR" || die "Nie udało się sklonować void-packages"
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

# Sprawdź czy istnieje oryginalny szablon Ghostty w void-packages
ORIG_TEMPLATE="srcpkgs/ghostty/template"
if [ ! -f "$ORIG_TEMPLATE" ]; then
    echo "Brak oryginalnego szablonu Ghostty w void-packages."
    echo "Tworzę podstawowy szablon..."
    
    # Utwórz katalog jeśli nie istnieje
    mkdir -p "srcpkgs/ghostty"
    
    # Pobierz najnowszą wersję do utworzenia szablonu
    echo "Pobieranie informacji o najnowszej wersji..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/tags | jq -r '.[0].name' | sed 's/^v//')
    
    if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
        echo "Nie można automatycznie określić wersji. Używam wersji main."
        LATEST_VERSION="main-$(date +%Y%m%d)"
        DOWNLOAD_URL="https://github.com/ghostty-org/ghostty/archive/main.tar.gz"
    else
        DOWNLOAD_URL="https://github.com/ghostty-org/ghostty/archive/v${LATEST_VERSION}.tar.gz"
    fi
    
    # Pobierz archiwum do wygenerowania hash
    TARBALL="ghostty-${LATEST_VERSION}.tar.gz"
    wget -q "$DOWNLOAD_URL" -O "$TARBALL" || die "Nie udało się pobrać archiwum"
    HASH=$(sha256sum "$TARBALL" | cut -d' ' -f1)
    rm "$TARBALL"
    
    # Utwórz podstawowy szablon
    cat > "$ORIG_TEMPLATE" << EOF
# Template file for 'ghostty'
pkgname=ghostty
version=$LATEST_VERSION
revision=1
build_style=zig
configure_args="--release=safe"
hostmakedepends="zig pkg-config"
makedepends="gtk+3-devel libadwaita-devel"
short_desc="Fast, feature-rich, and cross-platform terminal emulator"
maintainer="Auto-generated <void@localhost>"
license="MIT"
homepage="https://github.com/ghostty-org/ghostty"
distfiles="https://github.com/ghostty-org/ghostty/archive/v\${version}.tar.gz"
checksum="$HASH"

post_install() {
    vlicense LICENSE
}
EOF
    echo "Utworzono podstawowy szablon dla wersji $LATEST_VERSION"
fi

# Skopiuj oryginalny szablon do naszego katalogu jeśli nie istnieje nasz szablon
if [ ! -f "$MY_TEMPLATE" ]; then
    echo "Tworzę kopię szablonu..."
    cp "$ORIG_TEMPLATE" "$MY_TEMPLATE"
fi

# Pobierz najnowszą wersję Ghostty z GitHub API
echo "Sprawdzanie najnowszej wersji Ghostty..."
API_RESPONSE=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/releases/latest)
VERSION=$(echo "$API_RESPONSE" | jq -r '.tag_name' | sed 's/^v//')

# Sprawdź czy otrzymaliśmy prawidłową wersję
if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    echo "API GitHub nie zwróciło prawidłowej wersji release'u."
    echo "Sprawdzanie najnowszych tagów..."
    
    # Spróbuj pobrać listę tagów
    VERSION=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/tags | jq -r '.[0].name' | sed 's/^v//')
    
    if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
        echo "Nie udało się automatycznie określić wersji."
        echo "Sprawdź ręcznie: https://github.com/ghostty-org/ghostty/releases"
        echo "Podaj wersję ręcznie (np. 1.1.3) lub naciśnij Enter aby anulować:"
        read -r MANUAL_VERSION
        
        if [ -n "$MANUAL_VERSION" ]; then
            VERSION="$MANUAL_VERSION"
            echo "Używam wersji: $VERSION"
        else
            die "Anulowano - nie można określić wersji"
        fi
    else
        echo "Znaleziono najnowszy tag: $VERSION"
    fi
fi

# Sprawdź czy już mamy tę wersję
CURRENT_VERSION=$(grep "^version=" "$MY_TEMPLATE" 2>/dev/null | cut -d'=' -f2)
if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo "Ghostty $VERSION już jest aktualny!"
    echo "Chcesz przebudować mimo to? (t/N): "
    read -r response
    case "$response" in
        [tT]|[tT][aA][kK]) echo "Przebudowuję...";;
        *) echo "Anulowano."; exit 0;;
    esac
else
    echo "Nowa wersja dostępna: $CURRENT_VERSION → $VERSION"
fi

# Pobierz źródła i wygeneruj hash
echo "Pobieranie Ghostty $VERSION..."
TARBALL="ghostty-${VERSION}.tar.gz"

# Spróbuj różne formaty URL
DOWNLOAD_URLS=(
    "https://github.com/ghostty-org/ghostty/archive/v${VERSION}.tar.gz"
    "https://github.com/ghostty-org/ghostty/archive/${VERSION}.tar.gz"
    "https://github.com/ghostty-org/ghostty/archive/refs/tags/v${VERSION}.tar.gz"
    "https://github.com/ghostty-org/ghostty/archive/refs/tags/${VERSION}.tar.gz"
)

DOWNLOAD_SUCCESS=0
for URL in "${DOWNLOAD_URLS[@]}"; do
    echo "Próbuję: $URL"
    if wget -q --timeout=30 "$URL" -O "$TARBALL"; then
        echo "Pobrano pomyślnie z: $URL"
        DOWNLOAD_SUCCESS=1
        break
    else
        echo "Nie udało się z: $URL"
    fi
done

if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
    rm -f "$TARBALL"
    echo ""
    echo "Nie udało się pobrać archiwum automatycznie."
    echo "Sprawdź dostępne wersje na: https://github.com/ghostty-org/ghostty/releases"
    echo "Lub spróbuj pobrać kod źródłowy głównej gałęzi:"
    echo "Czy chcesz spróbować pobrać z głównej gałęzi (main)? (t/N):"
    read -r response
    case "$response" in
        [tT]|[tT][aA][kK])
            echo "Pobieranie z głównej gałęzi..."
            wget --progress=bar:force "https://github.com/ghostty-org/ghostty/archive/main.tar.gz" -O "$TARBALL" || die "Nie udało się pobrać z głównej gałęzi"
            VERSION="main-$(date +%Y%m%d)"
            echo "Używam wersji: $VERSION"
            ;;
        *)
            die "Nie udało się pobrać archiwum"
            ;;
    esac
fi

HASH=$(sha256sum "$TARBALL" | cut -d' ' -f1)
rm "$TARBALL"

# Aktualizuj mój szablon
echo "Aktualizuję szablon do wersji $VERSION..."
sed -i "s/version=.*/version=$VERSION/" "$MY_TEMPLATE"
sed -i "s/checksum=.*/checksum=\"$HASH\"/" "$MY_TEMPLATE"

# Podmiana szablonów
[ -f "$ORIG_TEMPLATE" ] && mv "$ORIG_TEMPLATE" "$ORIG_TEMPLATE.backup"
cp "$MY_TEMPLATE" "$ORIG_TEMPLATE"

# Sprawdź czy system ma wymagane zależności
echo "Sprawdzanie zależności systemowych..."
MISSING_DEPS=""
command -v zig >/dev/null 2>&1 || MISSING_DEPS="$MISSING_DEPS zig"
pkg-config --exists gtk+-3.0 2>/dev/null || MISSING_DEPS="$MISSING_DEPS gtk+3-devel"
pkg-config --exists libadwaita-1 2>/dev/null || MISSING_DEPS="$MISSING_DEPS libadwaita-devel"

if [ -n "$MISSING_DEPS" ]; then
    echo "Instaluję brakujące zależności:$MISSING_DEPS"
    sudo xbps-install -S $MISSING_DEPS || die "Nie udało się zainstalować zależności"
fi

# Buduj i instaluj
echo "Budowanie Ghostty..."
export XBPS_DISTDIR=$(pwd)

# Upewnij się, że binary-bootstrap jest wykonany
if [ ! -d "hostdir" ]; then
    echo "Inicjalizuję środowisko budowania..."
    ./xbps-src binary-bootstrap || die "Nie udało się zainicjalizować środowiska"
fi

# Wyczyść poprzednie buildy
./xbps-src clean ghostty 2>/dev/null

echo "Kompilowanie Ghostty (może to potrwać kilka minut)..."
./xbps-src pkg ghostty || die "Budowanie nie powiodło się"

echo "Instalowanie Ghostty..."
sudo xbps-install --repository=hostdir/binpkgs -u ghostty -y || die "Instalacja nie powiodła się"

# Przywróć oryginalny szablon
rm "$ORIG_TEMPLATE"
[ -f "$ORIG_TEMPLATE.backup" ] && mv "$ORIG_TEMPLATE.backup" "$ORIG_TEMPLATE"

echo ""
echo "=================================="
echo "Ghostty zaktualizowany do wersji $VERSION!"
echo "Możesz teraz uruchomić terminal: ghostty"
echo "Szablon zapisany w: $MY_TEMPLATE"
echo "=================================="

# Sprawdź czy ghostty rzeczywiście działa
if command -v ghostty >/dev/null 2>&1; then
    echo "Instalacja zakończona pomyślnie!"
    ghostty --version 2>/dev/null || echo "Ghostty zainstalowany (sprawdź wersję: ghostty --version)"
else
    echo "Ghostty może wymagać ponownego zalogowania lub aktualizacji PATH"
fi
