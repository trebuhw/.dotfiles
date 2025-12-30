#!/bin/bash

# Skrypt do tworzenia grupy WŁASNYCH pakietów (bez systemowych z minimalnej instalacji)
# Użycie: arch_install_app.sh [nazwa_grupy]
#         arch_install_app.sh --gui (dla rofi/GUI)

# Sprawdź czy uruchomiono z GUI (rofi)
GUI_MODE=false
if [ "$1" = "--gui" ]; then
    GUI_MODE=true
    GROUP_NAME="my-packages"
else
    GROUP_NAME="${1:-my-packages}"
fi

# Funkcja powiadomień
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" -i "package-x-generic" "$title" "$message"
    fi
}

# Uniwersalna lokalizacja - sprawdza różne możliwości
if [ -d "$HOME/Dokumenty" ]; then
    OUTPUT_DIR="$HOME/Dokumenty"
elif [ -d "$HOME/Documents" ]; then
    OUTPUT_DIR="$HOME/Documents"
elif [ -d "$HOME/dokumente" ]; then
    OUTPUT_DIR="$HOME/dokumente"
else
    OUTPUT_DIR="$HOME"
    echo "Ostrzeżenie: Nie znaleziono katalogu Dokumenty, używam katalogu domowego"
fi

OUTPUT_FILE="${OUTPUT_DIR}/${GROUP_NAME}.txt"

if [ "$GUI_MODE" = true ]; then
    # Tryb GUI - uruchom w tle z powiadomieniami
    send_notification "Arch Install App" "Rozpoczynam tworzenie listy pakietów..."
    exec > /tmp/arch_install_app.log 2>&1
else
    # Tryb terminal - wyświetl informacje
    echo "=== Tworzenie grupy WŁASNYCH pakietów (bez systemowych) ==="
    echo "Nazwa grupy: $GROUP_NAME"
    echo "Katalog wyjściowy: $OUTPUT_DIR"
    echo "Plik wyjściowy: $OUTPUT_FILE"
    echo
fi

# Lista pakietów systemowych do wykluczenia (typowa minimalna instalacja archinstall)
SYSTEM_PACKAGES="
bash
bzip2
coreutils
cryptsetup
device-mapper
dhcpcd
diffutils
e2fsprogs
file
filesystem
findutils
gawk
gcc-libs
gettext
glibc
grep
grub
gzip
inetutils
iproute2
iputils
less
licenses
linux
linux-firmware
linux-headers
logrotate
lvm2
man-db
man-pages
mdadm
nano
netctl
networkmanager
efibootmgr
os-prober
pacman
pciutils
procps-ng
psmisc
reiserfsprogs
s-nail
sed
shadow
sudo
sysfsutils
systemd
systemd-sysvcompat
tar
texinfo
usbutils
util-linux
vi
which
xfsprogs
base
base-devel
"

create_user_packages_list() {
    # Stwórz katalog jeśli nie istnieje
    mkdir -p "$OUTPUT_DIR"
    
    echo "# Moje własne pakiety (bez systemowych z minimalnej instalacji)" > "$OUTPUT_FILE"
    echo "# Wygenerowano: $(date)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Pobierz wszystkie explicite zainstalowane pakiety
    ALL_EXPLICIT=$(pacman -Qe | awk '{print $1}')
    
    # Odfiltruj pakiety systemowe
    USER_PACKAGES=""
    for pkg in $ALL_EXPLICIT; do
        if ! echo "$SYSTEM_PACKAGES" | grep -qw "$pkg"; then
            USER_PACKAGES="$USER_PACKAGES $pkg"
        fi
    done
    
    # Tablice dla różnych typów pakietów
    NATIVE_PKGS=""
    AUR_PKGS=""
    
    # Posortuj i zapisz + wyświetl w terminalu
    if [ ! -z "$USER_PACKAGES" ]; then
        echo "=== PAKIETY Z OFICJALNYCH REPOZYTORIÓW ===" >> "$OUTPUT_FILE"
        if [ "$GUI_MODE" = false ]; then
            echo
            echo "PAKIETY Z OFICJALNYCH REPOZYTORIÓW:"
        fi
        for pkg in $(echo $USER_PACKAGES | tr ' ' '\n' | sort); do
            # Sprawdź czy to pakiet natywny (oficjalne repo)
            if pacman -Qn "$pkg" &>/dev/null; then
                echo "$pkg" >> "$OUTPUT_FILE"
                if [ "$GUI_MODE" = false ]; then
                    echo "  - $pkg"
                fi
                NATIVE_PKGS="$NATIVE_PKGS $pkg"
            fi
        done
        
        echo "" >> "$OUTPUT_FILE"
        echo "=== PAKIETY Z AUR/ZEWNĘTRZNE ===" >> "$OUTPUT_FILE"
        if [ "$GUI_MODE" = false ]; then
            echo
            echo "PAKIETY Z AUR/ZEWNĘTRZNE:"
        fi
        for pkg in $(echo $USER_PACKAGES | tr ' ' '\n' | sort); do
            # Sprawdź czy to pakiet foreign (AUR)
            if pacman -Qm "$pkg" &>/dev/null; then
                echo "$pkg" >> "$OUTPUT_FILE"
                if [ "$GUI_MODE" = false ]; then
                    echo "  - $pkg"
                fi
                AUR_PKGS="$AUR_PKGS $pkg"
            fi
        done
        
        if [ -z "$NATIVE_PKGS" ] && [ -z "$AUR_PKGS" ]; then
            if [ "$GUI_MODE" = false ]; then
                echo "  (brak pakietów w tej kategorii)"
            fi
        fi
    else
        echo "# Brak dodatkowych pakietów (tylko systemowe)" >> "$OUTPUT_FILE"
        if [ "$GUI_MODE" = false ]; then
            echo "Brak dodatkowych pakietów - masz tylko systemowe pakiety z minimalnej instalacji"
        fi
    fi
}

# Funkcja do wyświetlenia statystyk
show_statistics() {
    if [ "$GUI_MODE" = false ]; then
        echo
        echo "STATYSTYKI:"
    fi
    
    TOTAL_EXPLICIT=$(pacman -Qe | wc -l)
    NATIVE_COUNT=$(echo "$NATIVE_PKGS" | wc -w)
    AUR_COUNT=$(echo "$AUR_PKGS" | wc -w)
    TOTAL_USER=$((NATIVE_COUNT + AUR_COUNT))
    
    if [ "$GUI_MODE" = false ]; then
        echo "  Wszystkie explicite pakiety: $TOTAL_EXPLICIT"
        echo "  Twoje pakiety (oficjalne): $NATIVE_COUNT"
        echo "  Twoje pakiety (AUR): $AUR_COUNT"
        echo "  Twoje pakiety (razem): $TOTAL_USER"
        echo "  Pakiety systemowe (odfiltrowane): $((TOTAL_EXPLICIT - TOTAL_USER))"
        echo
        echo "Plik zapisany jako: $OUTPUT_FILE"
    fi
}

# Funkcja do tworzenia skryptu instalacyjnego
create_install_script() {
    INSTALL_SCRIPT="${OUTPUT_DIR}/install_${GROUP_NAME}.sh"
    echo "#!/bin/bash" > "$INSTALL_SCRIPT"
    echo "# Skrypt do instalacji moich pakietów" >> "$INSTALL_SCRIPT"
    echo "# Wygenerowany: $(date)" >> "$INSTALL_SCRIPT"
    echo "" >> "$INSTALL_SCRIPT"
    
    if [ ! -z "$NATIVE_PKGS" ]; then
        echo "echo 'Instalowanie pakietów z oficjalnych repozytoriów...'" >> "$INSTALL_SCRIPT"
        echo "sudo pacman -S --needed$(echo "$NATIVE_PKGS" | tr ' ' '\n' | sort | tr '\n' ' ')" >> "$INSTALL_SCRIPT"
        echo "" >> "$INSTALL_SCRIPT"
    fi
    
    if [ ! -z "$AUR_PKGS" ]; then
        echo "echo 'Pakiety z AUR (zainstaluj ręcznie lub użyj AUR helpera):'" >> "$INSTALL_SCRIPT"
        for pkg in $(echo "$AUR_PKGS" | tr ' ' '\n' | sort); do
            echo "echo '  - $pkg'" >> "$INSTALL_SCRIPT"
        done
        echo "# yay -S$(echo "$AUR_PKGS" | tr ' ' '\n' | sort | tr '\n' ' ')" >> "$INSTALL_SCRIPT"
    fi
    
    chmod +x "$INSTALL_SCRIPT"
    if [ "$GUI_MODE" = false ]; then
        echo "Skrypt instalacyjny: $INSTALL_SCRIPT"
    fi
}

# Główna funkcja
main() {
    create_user_packages_list
    show_statistics
    create_install_script
    
    if [ "$GUI_MODE" = true ]; then
        # Powiadomienie o zakończeniu dla GUI
        NATIVE_COUNT=$(echo "$NATIVE_PKGS" | wc -w)
        AUR_COUNT=$(echo "$AUR_PKGS" | wc -w)
        TOTAL_USER=$((NATIVE_COUNT + AUR_COUNT))
        
        send_notification "Arch Install App - Zakończono" \
            "Znaleziono $TOTAL_USER własnych pakietów ($NATIVE_COUNT oficjalne, $AUR_COUNT AUR)\nZapisano w: $OUTPUT_FILE"
    else
        # Powiadomienie dla terminala
        send_notification "Arch Install App" "Lista pakietów została utworzona w katalogu Dokumenty"
        
        echo
        echo "GOTOWE!"
        echo "Lista twoich pakietów: $OUTPUT_FILE"
        echo "Skrypt do instalacji: ${OUTPUT_DIR}/install_${GROUP_NAME}.sh"
    fi
}

main