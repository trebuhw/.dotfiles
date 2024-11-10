#!/bin/bash

function powermenu {
    options="lock\nlogout\nscreenOff\nrestart\nshutdown"
    selected=$(echo -e $options | dmenu ) # demenu skonfigurowane i zainstalowane z ~/.config/dwm/dmenu/ sudo make clean install
 #   selected=$(echo -e $options | dmenu -p ">>>" -nb '#222222' -nf '#BBBBBB' -sb '#6790EB' -sf '#EEEEEE' -fn 'JetBrainsMono Nerd Font:size=10')
    if [[ $selected = "shutdown" ]]; then
        sytemclt poweroff
    elif [[ $selected = "restart" ]]; then
        systemctl reboot
    elif [[ $selected = "logout" ]]; then
        ~/.config/hypr/scripts/logout
     elif [[ $selected = "lock" ]]; then
        i3lock -c 000000
    elif [[ $selected = "screenOff" ]]; then
        i3lock -c 000000 && ~/.config/hypr/scripts/offscreen-x11
    fi 
}

powermenu
