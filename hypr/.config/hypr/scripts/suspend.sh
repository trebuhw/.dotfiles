#!/bin/bash

# Funkcja do sprawdzania, czy aktywne okno jest w trybie pełnoekranowym
is_fullscreen() {
    fullscreen=$(hyprctl activewindow | grep "fullscreen: yes")
    if [[ -n "$fullscreen" ]]; then
        return 0  # Pełny ekran
    else
        return 1  # Nie pełny ekran
    fi
}

# Funkcja do sprawdzania, czy przeglądarka internetowa jest aktywna i czy odtwarzane jest wideo
is_browser_playing_video() {
    # Pobranie nazwy klasy aktywnego okna za pomocą hyprctl
    # Flaga -i powoduje ignorowanie wielkości liter dla nazw przeglądarek
    browser_window=$(hyprctl activewindow | grep -i -E "class: (Firefox|Chromium|Google-chrome|Brave|Vivaldi)")
    
    # Dodatkowa kontrola, aby sprawdzić, czy w tytule okna są typowe frazy związane z odtwarzaniem wideo
    # Flaga -i powoduje ignorowanie wielkości liter dla nazw serwisów streamingowych
    video_window=$(hyprctl activewindow | grep -i -E "title:.*(YouTube|Netflix|Player|Vimeo|Prime|Max|Skay|Fullscreen)")

    if [[ -n "$browser_window" && -n "$video_window" ]]; then
        return 0  # Oglądanie wideo w przeglądarce
    else
        return 1  # Nie oglądasz wideo w przeglądarce
    fi
}

# Funkcja uruchamiająca procesy związane z bezczynnością
start_idle_process() {
    # Uruchomienie swayidle, aby blokować ekran po 10 minutach bezczynności
    swayidle -w \
        timeout 600 'swaylock -f -c 313244' \
        before-sleep 'swaylock -f -c 313244' &
    swayidle_pid=$!

    # Wyłączenie ekranu po kolejnych 10 minutach (1200 sekund)
    sleep 600 && hyprctl dispatch dpms off

    # Zawieszenie systemu po kolejnych 10 minutach (1800 sekund)
    sleep 600 && systemctl suspend
}

# Funkcja zatrzymująca proces swayidle
stop_idle_process() {
    if [[ -n "$swayidle_pid" ]]; then
        kill $swayidle_pid 2>/dev/null
    fi
}

while true; do
    # Sprawdzenie, czy aktywne okno nie jest w trybie pełnoekranowym i nie odtwarza wideo w przeglądarce
    if ! is_fullscreen && ! is_browser_playing_video; then
        # Uruchom procesy związane z bezczynnością
        start_idle_process

        # Nasłuchiwanie aktywności użytkownika: wyjście z pętli przy jakiejkolwiek akcji
        swaymsg -t subscribe '["input"]' | while read -r _; do
            # Jeśli wykryto aktywność użytkownika, przerwij aktualne zadania
            stop_idle_process
            break
        done
    fi

    # Odczekaj określony czas przed kolejnym sprawdzeniem
    sleep 10
done

exit 0
