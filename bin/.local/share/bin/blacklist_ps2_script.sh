#!/bin/bash

# Skrypt do dodania PS/2 touchpad do blacklisty
# Autor: System maintenance script
# Data: $(date)

set -e  # Zatrzymaj przy błędzie

echo "=== PS/2 Touchpad Blacklist Manager ==="
echo "Sprawdzanie czy PS/2 touchpad powoduje problemy..."
echo

# Sprawdź czy użytkownik jest w grupie sudo/wheel
if ! groups | grep -q '\(wheel\|sudo\)'; then
    echo "Błąd: Potrzebujesz uprawnień sudo do uruchomienia tego skryptu"
    exit 1
fi

# Sprawdź czy są multiple touchpady
echo "Sprawdzanie urządzeń touchpad..."
TOUCHPAD_COUNT=$(libinput list-devices | grep -i touchpad | wc -l)
PS2_TOUCHPAD=$(libinput list-devices | grep -i "PS/2.*TouchPad" || true)
I2C_TOUCHPAD=$(libinput list-devices | grep -i "I2C\|DELL.*Touchpad" || true)

echo "Znalezione touchpady: $TOUCHPAD_COUNT"

if [[ $TOUCHPAD_COUNT -lt 2 ]]; then
    echo "Znaleziono tylko jeden touchpad. PS/2 blacklist prawdopodobnie nie jest potrzebny."
    echo "Czy chcesz kontynuować mimo to? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Skrypt przerwany przez użytkownika"
        exit 0
    fi
fi

if [[ -n "$PS2_TOUCHPAD" && -n "$I2C_TOUCHPAD" ]]; then
    echo "PROBLEM WYKRYTY:"
    echo "Znaleziono PS/2 touchpad: $(echo "$PS2_TOUCHPAD" | head -1)"
    echo "Znaleziono I2C touchpad: $(echo "$I2C_TOUCHPAD" | head -1)"
    echo
    echo "Obecność obu touchpadów może powodować konflikty."
    echo "Zalecane jest dodanie PS/2 touchpad do blacklisty."
    echo
elif [[ -n "$PS2_TOUCHPAD" && -z "$I2C_TOUCHPAD" ]]; then
    echo "Znaleziono tylko PS/2 touchpad. Blacklisting może być niepotrzebny."
    echo "Czy masz problemy z touchpadem (przyciski nie działają)? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Skrypt przerwany - brak problemów z touchpadem"
        exit 0
    fi
fi

# Sprawdź czy blacklist już istnieje
BLACKLIST_FILE="/etc/modprobe.d/blacklist-psmouse.conf"
if [[ -f "$BLACKLIST_FILE" ]]; then
    echo "Blacklist już istnieje w $BLACKLIST_FILE"
    echo "Zawartość:"
    cat "$BLACKLIST_FILE"
    echo
    echo "Czy chcesz przebudować initramfs? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Przebudowywanie initramfs..."
        sudo mkinitcpio -P
        echo "Gotowe! Zrestartuj system aby zastosować zmiany."
    fi
    exit 0
fi

echo "Kontynuowanie z tworzeniem blacklisty..."
echo

echo "Tworzenie pliku blacklisty: $BLACKLIST_FILE"

# Utwórz plik blacklisty
sudo tee "$BLACKLIST_FILE" > /dev/null << EOF
# Blacklist PS/2 touchpad module (psmouse)
# Rozwiązuje problemy z duplikacją touchpadów
# Utworzono: $(date)

blacklist psmouse

# Opcjonalnie można też zablokować synaptics
# blacklist synaptics
EOF

echo "Utworzono plik blacklisty"

# Pokaż zawartość pliku
echo
echo "Zawartość pliku $BLACKLIST_FILE:"
cat "$BLACKLIST_FILE"
echo

# Wykonaj mkinitcpio
echo "Rebuilding initramfs z mkinitcpio..."
sudo mkinitcpio -P

if [[ $? -eq 0 ]]; then
    echo "mkinitcpio wykonane pomyślnie"
else
    echo "Błąd podczas wykonywania mkinitcpio"
    exit 1
fi

echo
echo "Gotowe! Zmiany zostaną zastosowane po restarcie systemu."
echo "Uruchom: sudo reboot"
echo
echo "Co zostało zrobione:"
echo "   • Dodano psmouse do blacklisty w $BLACKLIST_FILE"
echo "   • Przebudowano initramfs"
echo "   • Po restarcie PS/2 touchpad będzie wyłączony"
echo
echo "Aby sprawdzić efekt po restarcie, użyj:"
echo "   libinput list-devices | grep -i touchpad"