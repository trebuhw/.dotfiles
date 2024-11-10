#!/usr/bin/env bash


file="/home/hubert/.config/microsoft-edge/Default/Bookmarks"

bkmk="$(grep https $file | awk -F ' ' '{print $2}' | sed -e 's/.........//' -e 's/"//' | fzf --prompt="  Open : " --border --margin=5% --color=dark --height=100% --reverse --header="BOOKMARKS " --header-first)"

if [[ $bkmk ]]
then
    microsoft-edge-stable $bkmk
else
    exit
fi

