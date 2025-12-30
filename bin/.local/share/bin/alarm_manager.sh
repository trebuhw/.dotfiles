#!/bin/bash

# Plik do przechowywania alarmów
ALARM_FILE="$HOME/.config/alarmy.txt"
TEMP_FILE="/tmp/alarm_temp"

# Utworzenie pliku jeśli nie istnieje
[ ! -f "$ALARM_FILE" ] && touch "$ALARM_FILE"

# Funkcja wyświetlania menu z listą alarmów
show_menu_with_alarms() {
    clear  # Czyszczenie ekranu przed wyświetleniem menu
    echo "=== ZARZĄDZANIE ALARMAMI ==="
    
    # Najpierw pokaż istniejące alarmy
    if [ -s "$ALARM_FILE" ]; then
        current_time=$(date +%s)
        counter=1
        active_alarms=()
        expired_alarms=()
        
        # Zbierz wszystkie alarmy z statusem, sortując je według daty i godziny
        while IFS='|' read -r datetime message; do
            if [ -n "$datetime" ]; then
                alarm_timestamp=$(date -d "$datetime" +%s 2>/dev/null)
                if [ $? -eq 0 ]; then
                    if [ $alarm_timestamp -gt $current_time ]; then
                        active_alarms+=("$counter. $datetime - $message [AKTYWNY]|$datetime|$message")
                    else
                        expired_alarms+=("$counter. $datetime - $message [PRZETERMINOWANY]|$datetime|$message")
                    fi
                    counter=$((counter + 1))
                fi
            fi
        done < <(sort -t'|' -k1 "$ALARM_FILE")
        
        # Wyświetl alarmy jeśli istnieją
        if [ ${#active_alarms[@]} -gt 0 ] || [ ${#expired_alarms[@]} -gt 0 ]; then
            echo ""
            if [ ${#active_alarms[@]} -gt 0 ]; then
                echo "📅 AKTYWNE ALARMY:"
                for alarm in "${active_alarms[@]}"; do
                    display_text=$(echo "$alarm" | cut -d'|' -f1)
                    echo -e "  \033[32m$display_text\033[0m"  # zielony
                done
            fi
            
            if [ ${#expired_alarms[@]} -gt 0 ]; then
                echo "⏰ PRZETERMINOWANE ALARMY:"
                for alarm in "${expired_alarms[@]}"; do
                    display_text=$(echo "$alarm" | cut -d'|' -f1)
                    echo -e "  \033[31m$display_text\033[0m"  # czerwony
                done
            fi
            
            echo ""
            echo "Podsumowanie: ${#active_alarms[@]} aktywnych, ${#expired_alarms[@]} przeterminowanych"
        else
            echo ""
            echo "Brak zapisanych alarmów."
        fi
    else
        echo ""
        echo "Brak zapisanych alarmów."
    fi
    
    echo ""
    echo "=== OPCJE ==="
    echo "1. Dodaj nowy alarm"
    echo "2. Odśwież listę alarmów"
    echo "3. Edytuj alarm"
    echo "4. Usuń alarm"
    echo "5. Wyjście"
    echo -n "Wybierz opcję: "
}

# Funkcja dodawania alarmu
add_alarm() {
    clear  # Czyszczenie ekranu przed dodawaniem alarmu
    echo "=== DODAWANIE ALARMU ==="
    
    # Pobieranie daty
    while true; do
        echo -n "Czy alarm ma być ustawiony na dziś? (Enter dla tak, wpisz datę YYYY-MM-DD dla innej daty): "
        read date_input
        
        if [ -z "$date_input" ]; then
            alarm_date=$(date +%Y-%m-%d)
            break
        elif date -d "$date_input" >/dev/null 2>&1; then
            alarm_date="$date_input"
            break
        else
            echo "Nieprawidłowy format daty! Użyj YYYY-MM-DD"
        fi
    done
    
    # Pobieranie godziny
    while true; do
        echo -n "Podaj godzinę (HH:MM): "
        read time_input
        
        if [[ $time_input =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
            alarm_time="$time_input"
            break
        else
            echo "Nieprawidłowy format godziny! Użyj HH:MM"
        fi
    done
    
    # Pobieranie treści powiadomienia
    echo -n "Podaj treść powiadomienia: "
    read alarm_message
    
    if [ -z "$alarm_message" ]; then
        alarm_message="Alarm!"
    fi
    
    # Tworzenie pełnej daty i czasu
    full_datetime="$alarm_date $alarm_time"
    
    # Sprawdzenie czy data nie jest w przeszłości
    if [ $(date -d "$full_datetime" +%s) -le $(date +%s) ]; then
        echo "Uwaga: Podana data/godzina jest w przeszłości!"
        echo -n "Czy chcesz kontynuować? (t/n): "
        read confirm
        if [ "$confirm" != "t" ] && [ "$confirm" != "T" ]; then
            echo "Anulowano."
            return
        fi
    fi
    
    # Dodanie do pliku alarmów
    echo "$full_datetime|$alarm_message" >> "$ALARM_FILE"
    
    # Ustawienie alarmu w systemie z kompletnym środowiskiem
    USER_ID=$(id -u)
    HOME_DIR="$HOME"
    cat << EOF | at "$alarm_time" "$alarm_date" 2>/dev/null
#!/bin/bash
# Ustawienie środowiska dla powiadomień
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR="/run/user/$USER_ID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"
export PATH="/usr/local/bin:/usr/bin:/bin"
export HOME="$HOME_DIR"
export PULSE_SERVER="unix:/run/user/$USER_ID/pulse/native"

# Sprawdź aktywne sesje Wayland
for session in /run/user/$USER_ID/wayland-*; do
    if [ -e "\$session" ]; then
        export WAYLAND_DISPLAY=\$(basename "\$session")
        break
    fi
done

# Wyślij powiadomienie różnymi metodami
MESSAGE="$alarm_message"

# Odtwórz dźwięk alarmu w tle z możliwością zatrzymania
# Tworzymy skrypt do zatrzymania dźwięku
SOUND_SCRIPT="/tmp/alarm_sound_\$\$.sh"
cat > "\$SOUND_SCRIPT" << 'SOUND_EOF'
#!/bin/bash
SOUND_PID=\$\$
echo \$SOUND_PID > /tmp/alarm_sound.pid

# Pętla odtwarzania dźwięku co 3 sekundy
while [ -f /tmp/alarm_sound.pid ] && [ "\$(cat /tmp/alarm_sound.pid 2>/dev/null)" = "\$SOUND_PID" ]; do
    if command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga ]; then
        /usr/bin/paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null
    elif command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
        /usr/bin/paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null
    elif command -v aplay >/dev/null 2>&1 && [ -f /usr/share/sounds/alsa/Rear_Right.wav ]; then
        /usr/bin/aplay /usr/share/sounds/alsa/Rear_Right.wav 2>/dev/null
    elif command -v speaker-test >/dev/null 2>&1; then
        /usr/bin/speaker-test -t sine -f 800 -l 1 -s 1 2>/dev/null
    fi
    sleep 3
done
SOUND_EOF

chmod +x "\$SOUND_SCRIPT"
"\$SOUND_SCRIPT" &
SOUND_BG_PID=\$!

# Skrypt do zatrzymania dźwięku przy kliknięciu
STOP_SCRIPT="/tmp/stop_alarm_sound.sh"
cat > "\$STOP_SCRIPT" << 'STOP_EOF'
#!/bin/bash
# Zatrzymaj dźwięk
rm -f /tmp/alarm_sound.pid
pkill -f "alarm_sound_.*\.sh" 2>/dev/null
# Zamknij powiadomienia
if command -v dunstctl >/dev/null 2>&1; then
    /usr/bin/dunstctl close-all 2>/dev/null
elif command -v notify-send >/dev/null 2>&1; then
    /usr/bin/notify-send -u low -t 1 "Alarm" "Zatrzymano" 2>/dev/null
fi
STOP_EOF

chmod +x "\$STOP_SCRIPT"

# Metoda 1: notify-send (z akcją zatrzymania)
if command -v notify-send >/dev/null 2>&1; then
    /usr/bin/notify-send -u normal -t 0 -a "Alarm" --action="stop=Zatrzymaj" "🔔 ALARM!" "\$MESSAGE" 2>/dev/null
fi

# Metoda 2: dunstify (z akcją zatrzymania)
if command -v dunstify >/dev/null 2>&1; then
    /usr/bin/dunstify -u normal -t 0 -a "Alarm" -A "stop,Zatrzymaj" "🔔 ALARM!" "\$MESSAGE" 2>/dev/null
fi

# Czekaj na akcję użytkownika lub timeout
sleep 2
if [ -f /tmp/alarm_sound.pid ]; then
    # Monitoruj czy powiadomienie zostało zamknięte
    for i in {1..300}; do  # 5 minut maksymalnie
        if ! pgrep -f "dunst\|notification" > /dev/null 2>&1; then
            rm -f /tmp/alarm_sound.pid 2>/dev/null
            break
        fi
        sleep 1
    done
    # Wyczyść po 5 minutach tak czy siak
    rm -f /tmp/alarm_sound.pid 2>/dev/null
fi

# Sprzątanie
rm -f "\$SOUND_SCRIPT" "\$STOP_SCRIPT" 2>/dev/null

# Log dla debugowania
echo "\$(date): Alarm '\$MESSAGE' został wysłany z dźwiękiem" >> "$HOME_DIR/.local/share/alarm_debug.log"
EOF
    
    if [ $? -eq 0 ]; then
        echo "Alarm został dodany na $full_datetime"
        echo "Treść: $alarm_message"
    else
        echo "Błąd podczas dodawania alarmu do systemu"
        echo "Sprawdź czy masz zainstalowany pakiet 'at'"
    fi
}

# Funkcja wyświetlania alarmów
list_alarms() {
    clear  # Czyszczenie ekranu przed wyświetleniem listy
    echo "=== LISTA ALARMÓW ==="
    
    if [ ! -s "$ALARM_FILE" ]; then
        echo "Brak zapisanych alarmów."
        return
    fi
    
    current_time=$(date +%s)
    counter=1
    active_alarms=()
    expired_alarms=()
    
    # Zbierz wszystkie alarmy z statusem, sortując je według daty i godziny
    while IFS='|' read -r datetime message; do
        if [ -n "$datetime" ]; then
            alarm_timestamp=$(date -d "$datetime" +%s 2>/dev/null)
            if [ $? -eq 0 ]; then
                if [ $alarm_timestamp -gt $current_time ]; then
                    active_alarms+=("$counter. $datetime - $message [AKTYWNY]|$datetime|$message")
                else
                    expired_alarms+=("$counter. $datetime - $message [PRZETERMINOWANY]|$datetime|$message")
                fi
                counter=$((counter + 1))
            fi
        fi
    done < <(sort -t'|' -k1 "$ALARM_FILE")
    
    # Wyświetl wszystkie alarmy
    if [ ${#active_alarms[@]} -gt 0 ]; then
        echo -e "\n📅 AKTYWNE ALARMY:"
        for alarm in "${active_alarms[@]}"; do
            display_text=$(echo "$alarm" | cut -d'|' -f1)
            echo -e "  \033[32m$display_text\033[0m"  # zielony
        done
    fi
    
    if [ ${#expired_alarms[@]} -gt 0 ]; then
        echo -e "\n⏰ PRZETERMINOWANE ALARMY:"
        for alarm in "${expired_alarms[@]}"; do
            display_text=$(echo "$alarm" | cut -d'|' -f1)
            echo -e "  \033[31m$display_text\033[0m"  # czerwony
        done
    fi
    
    total_count=${#active_alarms[@]}
    expired_count=${#expired_alarms[@]}
    
    if [ $total_count -eq 0 ] && [ $expired_count -eq 0 ]; then
        echo "Brak alarmów."
        return
    fi
    
    echo -e "\nPodsumowanie: $total_count aktywnych, $expired_count przeterminowanych"
    
    if [ $expired_count -gt 0 ]; then
        echo ""
        echo "Opcje:"
        echo "1. Usuń wszystkie przeterminowane"
        echo "2. Usuń konkretny alarm (podaj numer)"
        echo "3. Powrót do menu głównego"
        echo -n "Wybierz opcję (1-3): "
        read cleanup_choice
        
        case $cleanup_choice in
            1)
                cleanup_expired_alarms
                ;;
            2)
                echo -n "Podaj numer alarmu do usunięcia: "
                read alarm_num
                remove_specific_alarm "$alarm_num" "${active_alarms[@]}" "${expired_alarms[@]}"
                ;;
            3)
                return
                ;;
            *)
                echo "Nieprawidłowa opcja."
                ;;
        esac
    else
        echo ""
        echo -n "Czy chcesz usunąć konkretny alarm? (podaj numer lub Enter aby powrócić): "
        read alarm_num
        if [ -n "$alarm_num" ]; then
            remove_specific_alarm "$alarm_num" "${active_alarms[@]}" "${expired_alarms[@]}"
        fi
    fi
}

# Funkcja usuwania przeterminowanych alarmów
cleanup_expired_alarms() {
    current_time=$(date +%s)
    > "$TEMP_FILE"
    
    while IFS='|' read -r datetime message; do
        if [ -n "$datetime" ]; then
            alarm_timestamp=$(date -d "$datetime" +%s 2>/dev/null)
            if [ $? -eq 0 ] && [ $alarm_timestamp -gt $current_time ]; then
                echo "$datetime|$message" >> "$TEMP_FILE"
            fi
        fi
    done < "$ALARM_FILE"
    
    mv "$TEMP_FILE" "$ALARM_FILE"
    echo "Przeterminowane alarmy zostały usunięte."
}

# Funkcja edycji alarmu
edit_alarm() {
    clear  # Czyszczenie ekranu przed edycją alarmu
    echo "=== EDYCJA ALARMU ==="
    
    if [ ! -s "$ALARM_FILE" ]; then
        echo "Brak alarmów do edycji."
        return
    fi
    
    current_time=$(date +%s)
    counter=1
    declare -a all_alarms=()
    declare -a alarm_lines=()
    
    # Zbierz wszystkie alarmy (aktywne i przeterminowane), sortując je według daty i godziny
    while IFS='|' read -r datetime message; do
        if [ -n "$datetime" ]; then
            alarm_timestamp=$(date -d "$datetime" +%s 2>/dev/null)
            if [ $? -eq 0 ]; then
                if [ $alarm_timestamp -gt $current_time ]; then
                    all_alarms+=("$counter. $datetime - $message [AKTYWNY]|$datetime|$message")
                else
                    all_alarms+=("$counter. $datetime - $message [PRZETERMINOWANY]|$datetime|$message")
                fi
                alarm_lines+=("$datetime|$message")
                counter=$((counter + 1))
            fi
        fi
    done < <(sort -t'|' -k1 "$ALARM_FILE")
    
    if [ ${#all_alarms[@]} -eq 0 ]; then
        echo "Brak alarmów do edycji."
        return
    fi
    
    # Wyświetl wszystkie alarmy
    echo "Dostępne alarmy:"
    for alarm in "${all_alarms[@]}"; do
        display_text=$(echo "$alarm" | cut -d'|' -f1)
        if [[ $display_text == *"[AKTYWNY]"* ]]; then
            echo -e "  \033[32m$display_text\033[0m"  # zielony
        else
            echo -e "  \033[31m$display_text\033[0m"  # czerwony
        fi
    done
    
    echo -n "Który alarm chcesz edytować? (numer lub 0 aby anulować): "
    read choice
    
    if [ "$choice" -eq 0 ] 2>/dev/null; then
        echo "Anulowano."
        return
    fi
    
    if [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le ${#all_alarms[@]} ]; then
        # Pobierz dane wybranego alarmu
        selected_line="${all_alarms[$((choice-1))]}"
        old_datetime=$(echo "$selected_line" | cut -d'|' -f2)
        old_message=$(echo "$selected_line" | cut -d'|' -f3)
        old_date=$(echo "$old_datetime" | cut -d' ' -f1)
        old_time=$(echo "$old_datetime" | cut -d' ' -f2)
        
        echo ""
        echo "Edytujesz alarm:"
        echo "Aktualna data: $old_date"
        echo "Aktualna godzina: $old_time"
        echo "Aktualna treść: $old_message"
        echo ""
        
        # Edycja daty
        echo -n "Nowa data (Enter dla '$old_date', wpisz datę YYYY-MM-DD dla innej daty): "
        read new_date_input
        
        if [ -z "$new_date_input" ]; then
            new_date="$old_date"
        elif [ "$new_date_input" = "dziś" ] || [ "$new_date_input" = "dzis" ] || [ "$new_date_input" = "DZIŚ" ] || [ "$new_date_input" = "DZIS" ]; then
            new_date=$(date +%Y-%m-%d)
        elif date -d "$new_date_input" >/dev/null 2>&1; then
            new_date="$new_date_input"
        else
            echo "Nieprawidłowy format daty! Zachowuję starą datę: $old_date"
            new_date="$old_date"
        fi
        
        # Edycja godziny
        while true; do
            echo -n "Nowa godzina (HH:MM lub Enter aby zachować '$old_time'): "
            read new_time_input
            
            if [ -z "$new_time_input" ]; then
                new_time="$old_time"
                break
            elif [[ $new_time_input =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
                new_time="$new_time_input"
                break
            else
                echo "Nieprawidłowy format godziny! Użyj HH:MM"
            fi
        done
        
        # Edycja treści
        echo -n "Nowa treść (Enter aby zachować '$old_message'): "
        read new_message_input
        
        if [ -z "$new_message_input" ]; then
            new_message="$old_message"
        else
            new_message="$new_message_input"
        fi
        
        # Stwórz nową pełną datę i czas
        new_full_datetime="$new_date $new_time"
        
        # Sprawdzenie czy data nie jest w przeszłości (jeśli się zmieniła)
        if [ "$new_full_datetime" != "$old_datetime" ]; then
            if [ $(date -d "$new_full_datetime" +%s) -le $(date +%s) ]; then
                echo "Uwaga: Nowa data/godzina jest w przeszłości!"
                echo -n "Czy chcesz kontynuować? (t/n): "
                read confirm
                if [ "$confirm" != "t" ] && [ "$confirm" != "T" ]; then
                    echo "Anulowano."
                    return
                fi
            fi
        fi
        
        # Usuń stary alarm z systemowego planera (próba)
        atq | while read job_id job_time job_date; do
            if [ -n "$job_id" ]; then
                atrm "$job_id" 2>/dev/null
            fi
        done
        
        # Zaktualizuj w pliku
        > "$TEMP_FILE"
        counter=1
        while IFS='|' read -r datetime message; do
            if [ -n "$datetime" ] && [ $counter -eq $choice ]; then
                echo "$new_full_datetime|$new_message" >> "$TEMP_FILE"
            else
                echo "$datetime|$message" >> "$TEMP_FILE"
            fi
            counter=$((counter + 1))
        done < <(sort -t'|' -k1 "$ALARM_FILE")
        mv "$TEMP_FILE" "$ALARM_FILE"
        
        # Dodaj nowy alarm do systemu (jeśli data/czas się zmieniły)
        if [ "$new_full_datetime" != "$old_datetime" ]; then
            USER_ID=$(id -u)
            HOME_DIR="$HOME"
            cat << EOF | at "$new_time" "$new_date" 2>/dev/null
#!/bin/bash
# Ustawienie środowiska dla powiadomień
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR="/run/user/$USER_ID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"
export PATH="/usr/local/bin:/usr/bin:/bin"
export HOME="$HOME_DIR"
export PULSE_SERVER="unix:/run/user/$USER_ID/pulse/native"

# Sprawdź aktywne sesje Wayland
for session in /run/user/$USER_ID/wayland-*; do
    if [ -e "\$session" ]; then
        export WAYLAND_DISPLAY=\$(basename "\$session")
        break
    fi
done

# Wyślij powiadomienie różnymi metodami
MESSAGE="$new_message"

# Odtwórz dźwięk alarmu w tle z możliwością zatrzymania
# Tworzymy skrypt do zatrzymania dźwięku
SOUND_SCRIPT="/tmp/alarm_sound_\$\$.sh"
cat > "\$SOUND_SCRIPT" << 'SOUND_EOF'
#!/bin/bash
SOUND_PID=\$\$
echo \$SOUND_PID > /tmp/alarm_sound.pid

# Pętla odtwarzania dźwięku co 3 sekundy
while [ -f /tmp/alarm_sound.pid ] && [ "\$(cat /tmp/alarm_sound.pid 2>/dev/null)" = "\$SOUND_PID" ]; do
    if command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga ]; then
        /usr/bin/paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null
    elif command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
        /usr/bin/paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null
    elif command -v aplay >/dev/null 2>&1 && [ -f /usr/share/sounds/alsa/Rear_Right.wav ]; then
        /usr/bin/aplay /usr/share/sounds/alsa/Rear_Right.wav 2>/dev/null
    elif command -v speaker-test >/dev/null 2>&1; then
        /usr/bin/speaker-test -t sine -f 800 -l 1 -s 1 2>/dev/null
    fi
    sleep 3
done
SOUND_EOF

chmod +x "\$SOUND_SCRIPT"
"\$SOUND_SCRIPT" &
SOUND_BG_PID=\$!

# Skrypt do zatrzymania dźwięku przy kliknięciu
STOP_SCRIPT="/tmp/stop_alarm_sound.sh"
cat > "\$STOP_SCRIPT" << 'STOP_EOF'
#!/bin/bash
# Zatrzymaj dźwięk
rm -f /tmp/alarm_sound.pid
pkill -f "alarm_sound_.*\.sh" 2>/dev/null
# Zamknij powiadomienia
if command -v dunstctl >/dev/null 2>&1; then
    /usr/bin/dunstctl close-all 2>/dev/null
elif command -v notify-send >/dev/null 2>&1; then
    /usr/bin/notify-send -u low -t 1 "Alarm" "Zatrzymano" 2>/dev/null
fi
STOP_EOF

chmod +x "\$STOP_SCRIPT"

# Metoda 1: notify-send (z akcją zatrzymania)
if command -v notify-send >/dev/null 2>&1; then
    /usr/bin/notify-send -u normal -t 0 -a "Alarm" --action="stop=Zatrzymaj" "🔔 ALARM!" "\$MESSAGE" 2>/dev/null
fi

# Metoda 2: dunstify (z akcją zatrzymania)
if command -v dunstify >/dev/null 2>&1; then
    /usr/bin/dunstify -u normal -t 0 -a "Alarm" -A "stop,Zatrzymaj" "🔔 ALARM!" "\$MESSAGE" 2>/dev/null
fi

# Czekaj na akcję użytkownika lub timeout
sleep 2
if [ -f /tmp/alarm_sound.pid ]; then
    # Monitoruj czy powiadomienie zostało zamknięte
    for i in {1..300}; do  # 5 minut maksymalnie
        if ! pgrep -f "dunst\|notification" > /dev/null 2>&1; then
            rm -f /tmp/alarm_sound.pid 2>/dev/null
            break
        fi
        sleep 1
    done
    # Wyczyść po 5 minutach tak czy siak
    rm -f /tmp/alarm_sound.pid 2>/dev/null
fi

# Sprzątanie
rm -f "\$SOUND_SCRIPT" "\$STOP_SCRIPT" 2>/dev/null

# Log dla debugowania
echo "\$(date): Alarm '\$MESSAGE' został wysłany z dźwiękiem" >> "$HOME_DIR/.local/share/alarm_debug.log"
EOF
        fi
        
        echo ""
        echo "Alarm został zaktualizowany:"
        echo "Data: $new_date"
        echo "Godzina: $new_time" 
        echo "Treść: $new_message"
        
    else
        echo "Nieprawidłowy wybór."
    fi
}

# Funkcja usuwania konkretnego alarmu
remove_specific_alarm() {
    local alarm_number="$1"
    shift
    local all_alarms=("$@")
    
    if ! [[ "$alarm_number" =~ ^[0-9]+$ ]] || [ "$alarm_number" -lt 1 ]; then
        echo "Nieprawidłowy numer alarmu."
        return
    fi
    
    # Sprawdź czy numer istnieje
    if [ "$alarm_number" -gt ${#all_alarms[@]} ]; then
        echo "Alarm o numerze $alarm_number nie istnieje."
        return
    fi
    
    # Pokaż który alarm zostanie usunięty
    local alarm_to_remove=$(echo "${all_alarms[$((alarm_number-1))]}" | cut -d'|' -f1)
    echo "Usuwam alarm: $alarm_to_remove"
    
    # Usuń alarm z pliku
    > "$TEMP_FILE"
    counter=1
    while IFS='|' read -r datetime message; do
        if [ -n "$datetime" ] && [ $counter -ne "$alarm_number" ]; then
            echo "$datetime|$message" >> "$TEMP_FILE"
        fi
        counter=$((counter + 1))
    done < <(sort -t'|' -k1 "$ALARM_FILE")
    mv "$TEMP_FILE" "$ALARM_FILE"
    
    echo "Alarm został usunięty."
}

# Funkcja usuwania alarmu (zmodyfikowana)
remove_alarm() {
    clear  # Czyszczenie ekranu przed usuwaniem alarmu
    echo "=== USUWANIE ALARMU ==="
    
    if [ ! -s "$ALARM_FILE" ]; then
        echo "Brak alarmów do usunięcia."
        return
    fi
    
    # Wyświetl aktualną listę
    list_alarms
}

# Sprawdzenie czy pakiet 'at' jest zainstalowany
check_dependencies() {
    local missing_packages=()
    local need_atd_enable=false
    
    # Sprawdź pakiet 'at'
    if ! command -v at &> /dev/null; then
        missing_packages+=("at")
    fi
    
    # Sprawdź czy usługa atd jest uruchomiona
    if command -v at &> /dev/null && ! systemctl is-active --quiet atd; then
        need_atd_enable=true
    fi
    
    # Sprawdź pakiet 'sound-theme-freedesktop'
    if ! pacman -Qi sound-theme-freedesktop &> /dev/null; then
        missing_packages+=("sound-theme-freedesktop")
    fi
    
    # Jeśli brakuje pakietów lub usługi
    if [ ${#missing_packages[@]} -gt 0 ] || [ "$need_atd_enable" = true ]; then
        if [ ${#missing_packages[@]} -gt 0 ]; then
            echo "Brakujące pakiety: ${missing_packages[*]}"
            echo -n "Czy chcesz je zainstalować automatycznie? (t/n): "
            read install_choice
            
            if [ "$install_choice" = "t" ] || [ "$install_choice" = "T" ]; then
                sudo pacman -S --noconfirm "${missing_packages[@]}" >/dev/null 2>&1 || {
                    echo "Błąd podczas instalacji pakietów!"
                    echo "Zainstaluj je ręcznie:"
                    for pkg in "${missing_packages[@]}"; do
                        echo "  sudo pacman -S $pkg"
                    done
                    if [ "$need_atd_enable" = true ]; then
                        echo "  sudo systemctl enable --now atd"
                    fi
                    exit 1
                }
            else
                echo "Nie można kontynuować bez wymaganych pakietów!"
                echo "Zainstaluj je ręcznie:"
                for pkg in "${missing_packages[@]}"; do
                    echo "  sudo pacman -S $pkg"
                done
                if [ "$need_atd_enable" = true ]; then
                    echo "  sudo systemctl enable --now atd"
                fi
                exit 1
            fi
        fi
        
        if [ "$need_atd_enable" = true ]; then
            echo -n "Czy chcesz włączyć usługę atd automatycznie? (t/n): "
            read enable_choice
            
            if [ "$enable_choice" = "t" ] || [ "$enable_choice" = "T" ]; then
                sudo systemctl enable --now atd >/dev/null 2>&1 || {
                    echo "Błąd podczas włączania usługi atd!"
                    echo "Włącz ją ręcznie: sudo systemctl enable --now atd"
                    exit 1
                }
            else
                echo "Nie można kontynuować bez uruchomionej usługi atd!"
                echo "Włącz ją ręcznie: sudo systemctl enable --now atd"
                exit 1
            fi
        fi
    fi
}

# Główna pętla programu
main() {
    check_dependencies
    
    if [ $# -eq 0 ]; then
        # Tryb interaktywny
        while true; do
            show_menu_with_alarms
            read choice
            
            case $choice in
                1)
                    add_alarm
                    ;;
                2)
                    # Opcja odświeżenia - pokaże menu ponownie z wyczyszczonym ekranem
                    continue
                    ;;
                3)
                    edit_alarm
                    ;;
                4)
                    remove_alarm
                    ;;
                5)
                    clear  # Czyszczenie ekranu przed wyjściem
                    echo "Do widzenia!"
                    exit 0
                    ;;
                *)
                    echo "Nieprawidłowa opcja!"
                    ;;
            esac
        done
    else
        # Tryb szybkiego dodawania (jeśli podano argumenty)
        clear  # Czyszczenie ekranu przed szybkim dodawaniem
        echo "Szybkie dodawanie alarmu..."
        add_alarm
    fi
}

main "$@"