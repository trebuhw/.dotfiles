#!/usr/bin/env bash

# Skrypt do wyświetlania temperatury CPU i prędkości wentylatorów w powiadomieniach mako

# Pobierz dane z sensors
sensors_output=$(sensors)

# Wyciągnij temperaturę Package id 0
cpu_temp=$(echo "$sensors_output" | grep "Package id 0:" | awk '{print $4}')

# Wyciągnij prędkości wentylatorów
fan1_rpm=$(echo "$sensors_output" | grep "fan1:" | awk '{print $2, $3}')
fan2_rpm=$(echo "$sensors_output" | grep "fan2:" | awk '{print $2, $3}')

# Sprawdź czy dane zostały pobrane
if [ -z "$cpu_temp" ] || [ -z "$fan1_rpm" ] || [ -z "$fan2_rpm" ]; then
    notify-send "Błąd" "Nie udało się pobrać danych z sensors"
    exit 1
fi

# Wyślij powiadomienie z danymi w osobnych wersach
notify-send "System Monitor" "CPU: $cpu_temp
Fan1: $fan1_rpm
Fan2: $fan2_rpm"
