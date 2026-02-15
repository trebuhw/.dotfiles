#!/usr/bin/env bash

set -e

# 🔹 Pobierz aktualny theme
THEME_NAME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null)
[[ -z "$THEME_NAME" ]] && echo "Nie znaleziono aktualnego theme!" && exit 1

# 🔹 Ścieżki
THEME_BACKGROUNDS_PATH="$HOME/.config/omarchy/current/theme/backgrounds"
USER_BACKGROUNDS_PATH="$HOME/.config/omarchy/backgrounds/$THEME_NAME"
CURRENT_BACKGROUND_LINK="$HOME/.config/omarchy/current/background"

# 🔹 Katalog tymczasowy dla hyprwat
TMP_DIR="/tmp/hyprwat_wallpapers"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# 🔹 Zbierz wszystkie pliki z obu lokalizacji
for DIR in "$THEME_BACKGROUNDS_PATH" "$USER_BACKGROUNDS_PATH"; do
    [[ -d "$DIR" ]] || continue
    for f in "$DIR"/*.{jpg,jpeg,png,webp,gif}; do
        [[ -f "$f" ]] || continue
        ln -s "$f" "$TMP_DIR/" 2>/dev/null
    done
done

# 🔹 Sprawdź czy katalog tymczasowy nie jest pusty
if [[ -z "$(ls -A "$TMP_DIR")" ]]; then
    echo "Brak tapet w aktualnym theme ($THEME_NAME)."
    exit 1
fi

# 🔹 Uruchom hyprwat
SELECTED=$(hyprwat --wallpaper "$TMP_DIR")

if [[ -n "$SELECTED" && -f "$SELECTED" ]]; then
    REAL_PATH=$(readlink -f "$SELECTED")

    ln -sfn "$REAL_PATH" "$CURRENT_BACKGROUND_LINK"
    echo "Nowa tapeta: $REAL_PATH"

    # restart swaybg
    pkill -x swaybg
    setsid uwsm-app -- swaybg -i "$REAL_PATH" -m fill >/dev/null 2>&1 &
else
    echo "Nie wybrano pliku."
fi

