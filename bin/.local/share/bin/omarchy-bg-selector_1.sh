#!/usr/bin/env bash

THEME_NAME="catppuccin"

THEME_BACKGROUNDS_PATH="$HOME/.config/omarchy/current/theme/backgrounds"
USER_BACKGROUNDS_PATH="$HOME/.config/omarchy/backgrounds/$THEME_NAME"

TARGET_LINK="$HOME/.config/omarchy/current/background"

TMP_DIR="/tmp/hyprwat_wallpapers"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# 🔹 Zbierz obrazy z obu lokalizacji jako symlinki
for DIR in "$THEME_BACKGROUNDS_PATH" "$USER_BACKGROUNDS_PATH"; do
    if [[ -d "$DIR" ]]; then
        find "$DIR" -maxdepth 1 -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) \
            -exec ln -s "{}" "$TMP_DIR/" \; 2>/dev/null
    fi
done

# 🔹 Otwórz hyprwat na katalogu tymczasowym
SELECTED=$(hyprwat --wallpaper "$TMP_DIR")

if [[ -n "$SELECTED" && -f "$SELECTED" ]]; then
    # SELECTED jest linkiem → pobierz prawdziwą ścieżkę
    REAL_PATH=$(readlink -f "$SELECTED")

    ln -sfn "$REAL_PATH" "$TARGET_LINK"
    echo "Nowa tapeta: $REAL_PATH"

    # restart swaybg
    pkill -x swaybg
    setsid uwsm-app -- swaybg -i "$REAL_PATH" -m fill >/dev/null 2>&1 &
else
    echo "Nie wybrano pliku."
fi

