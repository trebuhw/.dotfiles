#!/usr/bin/env bash

# Interaktywny skrypt do monitorowania temperatury CPU i prędkości wentylatorów

# Funkcja do pobierania i wyświetlania danych
show_sensors_data() {
    # Pobierz dane z sensors
    sensors_output=$(sensors)
    
    # Wyciągnij temperaturę Package id 0
    cpu_temp=$(echo "$sensors_output" | grep "Package id 0:" | awk '{print $4}')
    
    # Wyciągnij prędkości wentylatorów
    fan1_rpm=$(echo "$sensors_output" | grep "fan1:" | awk '{print $2, $3}')
    fan2_rpm=$(echo "$sensors_output" | grep "fan2:" | awk '{print $2, $3}')
    
    # Sprawdź czy dane zostały pobrane
    if [ -z "$cpu_temp" ] || [ -z "$fan1_rpm" ] || [ -z "$fan2_rpm" ]; then
        echo "Błąd: Nie udało się pobrać danych z sensors"
        return 1
    fi
    
    # Wyczyść ekran i wyświetl dane
    clear
    echo "=== MONITOR SYSTEMU ==="
    echo "Czas: $(date '+%H:%M:%S')"
    echo "CPU: $cpu_temp"
    echo "Fan1: $fan1_rpm"
    echo "Fan2: $fan2_rpm"
    echo ""
    echo "Naciśnij Ctrl+C aby zakończyć..."
    
    # Opcjonalnie wyślij też powiadomienie (odkomentuj jeśli chcesz)
    # notify-send "System Monitor" "CPU: $cpu_temp\nFan1: $fan1_rpm\nFan2: $fan2_rpm"
}

# Sprawdź parametry
case "${1:-console}" in
    "console"|"c")
        echo "Uruchamianie monitora w konsoli..."
        echo "Odświeżanie co 2 sekundy. Naciśnij Ctrl+C aby zakończyć."
        echo ""
        
        # Pętla główna
        while true; do
            show_sensors_data
            sleep 2
        done
        ;;
        
    "notify"|"n")
        echo "Uruchamianie monitora z powiadomieniami..."
        echo "Powiadomienia co 5 sekund. Skrypt kończy się po zamknięciu powiadomienia."
        
        while true; do
            # Pobierz dane z sensors
            sensors_output=$(sensors)
            
            # Wyciągnij dane
            cpu_temp=$(echo "$sensors_output" | grep "Package id 0:" | awk '{print $4}')
            fan1_rpm=$(echo "$sensors_output" | grep "fan1:" | awk '{print $2, $3}')
            fan2_rpm=$(echo "$sensors_output" | grep "fan2:" | awk '{print $2, $3}')
            
            # Wyślij powiadomienie i sprawdź czy zostało zamknięte
            if [ -n "$cpu_temp" ] && [ -n "$fan1_rpm" ] && [ -n "$fan2_rpm" ]; then
                # Wyślij powiadomienie z opcją zamknięcia
                notify-send --wait "System Monitor" "CPU: $cpu_temp
Fan1: $fan1_rpm
Fan2: $fan2_rpm
                
Kliknij aby zamknąć monitor"
                
                # Jeśli powiadomienie zostało zamknięte, zakończ skrypt
                if [ $? -eq 0 ]; then
                    echo "Powiadomienie zostało zamknięte. Kończę monitor."
                    break
                fi
            fi
            
            sleep 5
        done
        ;;
        
    "once"|"o")
        echo "Jednorazowe sprawdzenie:"
        show_sensors_data
        ;;
        
    "help"|"h"|*)
        echo "Użycie: $0 [opcja]"
        echo ""
        echo "Opcje:"
        echo "  console, c    - Monitor w konsoli (domyślnie, odświeżanie co 2s)"
        echo "  notify, n     - Powiadomienia systemowe (co 5s)"
        echo "  once, o       - Jednorazowe sprawdzenie"
        echo "  help, h       - Pomoc"
        echo ""
        echo "Przykłady:"
        echo "  $0            - Uruchom w trybie konsoli"
        echo "  $0 console    - Uruchom w trybie konsoli"
        echo "  $0 notify     - Uruchom z powiadomieniami"
        echo "  $0 once       - Sprawdź raz"
        ;;
esac
