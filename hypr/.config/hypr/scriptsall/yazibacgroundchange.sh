#!/bin/bash

cp $1 ~/.background && 
feh --bg-fill $1 && 
killall hyprpaper && hyprpaper -c ~/.config/hypr/hyprpaper.conf'

exit 0
