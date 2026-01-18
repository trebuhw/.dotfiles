#!/bin/bash

if [[ ! $(pidof rofi) ]]; then
	 cliphist list | rofi -dmenu -p 'Clipboard history ...' | cliphist decode | wl-copy 
else
	pkill rofi
fi
