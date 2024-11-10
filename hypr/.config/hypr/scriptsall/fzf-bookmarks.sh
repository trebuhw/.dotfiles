#!/usr/bin/env bash

webbrowser=google-chrome-stable

file="/home/hubert/.config/google-chrome/Default/Bookmarks"

bkmk="$(grep https $file | awk -F ' ' '{print $2}' | sed -e 's/.........//' -e 's/"//' | fzf --prompt="Open : " --border --margin=5% --color=dark --height=100% --reverse --header=" BOOKMARKS " --header-first)"

if [[ $bkmk ]]
then
    $webbrowser $bkmk
else
    exit
fi

