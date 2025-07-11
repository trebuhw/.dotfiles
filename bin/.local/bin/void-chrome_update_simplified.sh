#!/bin/bash
# Prosty skrypt aktualizacji Google Chrome dla Void Linux

VOID_DIR="$HOME/void-packages"
MY_TEMPLATE="$HOME/void-mytemplate/google-chrome/template"

die() { echo "Błąd: $1"; exit 1; }

# Sprawdzenia
[ -d "$VOID_DIR" ] || die "Brak katalogu $VOID_DIR"
[ -f "$MY_TEMPLATE" ] || die "Brak szablonu $MY_TEMPLATE"

cd "$VOID_DIR" || die "Nie można przejść do $VOID_DIR"

# Pobierz najnowszą wersję Chrome
echo "Sprawdzanie najnowszej wersji Chrome..."
VERSION=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json | jq -r '.channels.Stable.version')
[ -z "$VERSION" ] && die "Nie udało się pobrać wersji"

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
echo "Pobieranie Chrome $VERSION..."
DEB_FILE="google-chrome-stable_${VERSION}-1_amd64.deb"
wget --progress=bar:force  "https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/$DEB_FILE" || die "Nie udało się pobrać pliku"

HASH=$(sha256sum "$DEB_FILE" | cut -d' ' -f1)
rm "$DEB_FILE"

# Aktualizuj mój szablon
echo "Aktualizuję szablon do wersji $VERSION..."
sed -i "s/version=.*/version=$VERSION/" "$MY_TEMPLATE"
sed -i "s/checksum=.*/checksum=\"$HASH\"/" "$MY_TEMPLATE"

# Podmiana szablonów
ORIG_TEMPLATE="srcpkgs/google-chrome/template"
[ -f "$ORIG_TEMPLATE" ] && mv "$ORIG_TEMPLATE" "$ORIG_TEMPLATE.backup"
cp "$MY_TEMPLATE" "$ORIG_TEMPLATE"

# Buduj i instaluj
echo "Budowanie Chrome..."
export XBPS_DISTDIR=$(pwd)
./xbps-src binary-bootstrap >/dev/null 2>&1
grep -q "XBPS_ALLOW_RESTRICTED=yes" etc/conf || echo "XBPS_ALLOW_RESTRICTED=yes" >> etc/conf
./xbps-src pkg google-chrome || die "Budowanie nie powiodło się"

echo "Instalowanie Chrome..."
sudo xbps-install --repository=hostdir/binpkgs/nonfree -u google-chrome -y || die "Instalacja nie powiodła się"

# Przywróć oryginalny szablon
rm "$ORIG_TEMPLATE"
[ -f "$ORIG_TEMPLATE.backup" ] && mv "$ORIG_TEMPLATE.backup" "$ORIG_TEMPLATE"

echo "Chrome zaktualizowany do wersji $VERSION!"
