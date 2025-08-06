#!/bin/bash

plik_konfiguracyjny="/etc/sysconfig/yast2"
zmienna_do_zamiany="Y2NCURSES_COLOR_THEME"

echo "Dostępne kolory:"
echo "1. xterm         # xterm: blue-white-red"
echo "2. linux         # linux: blue-white-yellow"
echo "3. rxvt          # rxvt: black-yellow-red"
echo "4. mono          # mono: white-black"
echo "5. inverted      # inverted: black-white"
echo "6. highcontrast  # highcontrast: lightgrey-black"
echo "7. braille       # braille: for visually impaired"
echo "8. Rezygnuj      # Rezygnuj"

read -p "Wybierz numer koloru (lub naciśnij Enter, aby zrezygnować): " wybrany_kolor

case $wybrany_kolor in
    1) nowa_wartosc="xterm";;
    2) nowa_wartosc="linux";;
    3) nowa_wartosc="rxvt";;
    4) nowa_wartosc="mono";;
    5) nowa_wartosc="inverted";;
    6) nowa_wartosc="highcontrast";;
    7) nowa_wartosc="braille";;
    8) echo "Rezygnacja."; exit 0;;
    *) echo "Błędny wybór."; exit 1;;
esac

if grep -q "^$zmienna_do_zamiany" "$plik_konfiguracyjny"; then
    sed -i "s/^$zmienna_do_zamiany=.*/$zmienna_do_zamiany=\"$nowa_wartosc\"/" "$plik_konfiguracyjny"
    echo "Zamieniono wartość $zmienna_do_zamiany na \"$nowa_wartosc\"."
else
    echo "$zmienna_do_zamiany nie zostało znalezione w pliku $plik_konfiguracyjny."
fi

# Spróbuj otworzyć skrypt bezpośrednio w kitty
kitty -e "$0"

exit 0
