#!/bin/bash

selected=$(echo -e "Paste from clipboard\nClear clipboard history" | dmenu -i -p "Wybierz opcję:")

if [ "$selected" == "Paste from clipboard" ]; then
    selected_word=$(xclip -o -selection clipboard 2>/dev/null)
    if [ -n "$selected_word" ]; then
        echo -n "$selected_word" | xclip -selection clipboard
        xdotool type --clearmodifiers "$selected_word"
    fi
elif [ "$selected" == "Clear clipboard history" ]; then
    echo -n "" | xclip -selection clipboard
fi
