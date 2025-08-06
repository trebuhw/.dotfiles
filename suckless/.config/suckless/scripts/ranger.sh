#!/bin/bash

# Funkcja do uzyskiwania wartości WM_CLASS dla danego terminala
get_terminal_wm_class() {
    xprop -id "$(xprop -root -f _NET_ACTIVE_WINDOW 0x " \$0\\n" _NET_ACTIVE_WINDOW | awk "{print \$2}")" WM_CLASS | grep -oP '(?<=\=\ ").*?(?=", ")'
}

# Pobierz wartość WM_CLASS
wm_class=$(get_terminal_wm_class)

case $wm_class in
    kitty)
        ranger -r ~/.config/ranger
        ;;
    st)
        ranger -r ~/.config/ranger/ranger-st
        ;;
    *)
        ranger -r ~/.config/ranger
        ;;
esac
