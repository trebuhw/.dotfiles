#!/bin/bash

cd ~/.config/hypr/scripts/
chosen=$( ls | sort | tofi -c ~/.config/hypr/tofi/config --prompt-text="  "  | awk '{print $1}' )
scripts=$chosen

# Exit if none chosen.                                                                         
[ -z "$chosen" ] && exit

fullpath=$(pwd)/$scripts;

kitty -e vim $fullpath ;

