#!/bin/bash

function powermenu {
    options="Block\nLogout\nScreenOff\nReboot\nPowerOff"
    selected=$(echo -e $options | dmenu -i ) # demenu skonfigurowane i zainstalowane z ~/.config/dwm/dmenu/ sudo make clean install
 #   selected=$(echo -e $options | dmenu -p ">>>" -nb '#222222' -nf '#BBBBBB' -sb '#6790EB' -sf '#EEEEEE' -fn 'JetBrainsMono Nerd Font:size=10')
    if [[ $selected = "PowerOff" ]]; then
        systemctl poweroff
    elif [[ $selected = "Reboot" ]]; then
        systemctl reboot
    elif [[ $selected = "Logout" ]]; then
        ~/.config/suckless/scripts/logout
     elif [[ $selected = "Block" ]]; then
        i3lock -c 000000 && ~/.config/suckless/scripts/offscreen-x11
    elif [[ $selected = "ScreenOff" ]]; then
        ~/.config/suckless/scripts/offscreen-x11
    fi 
}

powermenu
