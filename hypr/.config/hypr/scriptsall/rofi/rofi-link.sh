#!/usr/bin/env bash
#
EDITOR="nvim"
TERMINAL="kitty"

ROFIEDITOR="$TERMINAL -e $EDITOR"

# An array of options to choose.
# You can edit this list to add/remove config files.
declare -a options=(
"backup.sh - $HOME/.config/scripts/backup/rsync-backup.sh"
"bash.conf - $HOME/.bashrc"
"dunst.conf - $HOME/.config/dunst/dunstrc"
"fish.alias - $HOME/.config/fish/alias.fish"
"fish.conf - $HOME/.config/fish/config.fish"
"fzf-config - $HOME/.config/scripts/fzf-config.sh"
"fzf-import-rofi - $HOME/.config/scripts/fzf-import-rofi.sh"
"fzf-run-app - $HOME/.config/scripts/fzf-run-app.sh"
"fzf-run-scripts - $HOME/.config/scripts/fzf-run-scripts.sh"
"fzf-scripts - $HOME/.config/scripts/fzf-scripts.sh"
"i30.info - $HOME/Dokumenty/i30_info.txt"
"nsxiv-key-handler - $HOME/.config/nsxiv/exec/key-handler"
"nsxiv-man - $HOME/Dokumenty/keyshortcuts/nsxiv-man.txt"
"nvim.conf - $HOME/.config/nvim/init.vim"
"nvim.skr - $HOME/Dokumenty/keyshortcuts/nvim.txt"
"operatory-bash - $HOME/Dokumenty/keyshortcuts/operatory-bash.txt"
"ranger.conf - $HOME/.config/ranger/rc.conf"
"ranger.skr - $HOME/Dokumenty/keyshortcuts/ranger.txt"
"regular-expressions- $HOME/Dokumenty/keyshortcuts/regular-expressions.txt"
"rofi-background-change.sh - $HOME/.config/scripts/rofi/rofi-background-change.sh"
"rofi-emoji-selector.sh - $HOME/.config/scripts/rofi/rofi-emoji-selector.sh"
"rofi-link.sh - $HOME/.config/scripts/rofi/rofi-link.sh"
"rofi-power-menu.sh - $HOME/.config/scripts/rofi/rofi-power-menu.sh"
"rofi-wifi-menu.sh - $HOME/.config/scripts/rofi/rofi-wifi-menu.sh"
"sway.conf - $HOME/.config/sway/config"
"sway.skr - $HOME/Dokumenty/keyshortcuts/sway.txt"
"swaybg-auto-change-background - $HOME/.config/scripts/swaybg-auto-change-background.sh"
"swaybg-change-background - $HOME/.config/scripts/swaybg-change-background.sh"
"waybar-bg-black - $HOME/.config/scripts/waybar-bg-black.sh"
"waybar-bg-transparent - $HOME/.config/scripts/waybar-bg-transparent.sh"
"waybar.conf - $HOME/.config/waybar/config"
"waybar.css - $HOME/.config/waybar/style.css"
"zathurarc - $HOME/.config/zathura/zathurarc"
"zathura.skr - $HOME/Dokumenty/keyshortcuts/zathura.txt"
"quit"
)

# Piping the above array into dmenu.
# We use "printf '%s\n'" to format the array one item to a line.
choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i  20 -p 'Edit config:')

# What to do when/if we choose 'quit'.
if [[ "$choice" == "quit" ]]; then
    echo "Program terminated." && exit 1

# What to do when/if we choose a file to edit.
elif [ "$choice" ]; then
	cfg=$(printf '%s\n' "${choice}" | awk '{print $NF}')
	$ROFIEDITOR "$cfg"

# What to do if we just escape without choosing anything.
else
    echo "Program terminated." && exit 1
fi
