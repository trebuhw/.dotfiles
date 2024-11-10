#!/bin/bash

wallpaper_dir="$HOME/Obrazy/Wallpaper/"
cd "$wallpaper_dir" || exit 1

chosen=$(ls | sort | tofi -c "$HOME/.config/hypr/tofi/config" --prompt-text="  " | awk '{print $1}')

# Exit if none chosen.
[ -z "$chosen" ] && exit 1

fullpath=$(pwd)/$chosen
bg="$HOME/.background"

cp "$fullpath" "$bg" || exit 1

echo "Path to original file :" >  ~/.background.info.txt
echo $(readlink -f "$fullpath") >> ~/.background.info.txt
echo "Path to swaybg file :" >>  ~/.background.info.txt
echo "$bg" >> ~/.background.info.txt

notify-send -i "$bg" "Tapeta została zmieniona"

pkill hyprpaper &

hyprpaper -c $HOME/.config/hypr/hyprpaper.conf

exit 0

