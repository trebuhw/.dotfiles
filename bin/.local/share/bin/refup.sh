#!/usr/bin/env bash
# =============================================================================
# refup.sh — uniwersalny skrypt do aktualizacji mirrorlist Arch Linux / CachyOS
# Działa w bash i fish, retry przy błędach połączenia
# =============================================================================

set -euo pipefail

MIRRORLIST="/etc/pacman.d/mirrorlist"
BACKUP="/etc/pacman.d/mirrorlist.bak"
LOG="$HOME/refup.log"
RETRIES=3
CONNECTION_TIMEOUT=10
DOWNLOAD_TIMEOUT=20

echo "==> Tworzenie backupu starego mirrorlist"
if [ -f "$MIRRORLIST" ]; then
    sudo cp "$MIRRORLIST" "$BACKUP"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup zapisany w $BACKUP" | tee -a "$LOG"
fi

echo "==> Pobieranie 30 najnowszych mirrorów HTTPS i wybór 10 najszybszych"

for i in $(seq 1 $RETRIES); do
    echo "Próba $i/$RETRIES..." | tee -a "$LOG"
    if sudo reflector \
        --latest 30 \
        --protocol https \
        --sort rate \
        --number 10 \
        --verbose \
        --connection-timeout $CONNECTION_TIMEOUT \
        --download-timeout $DOWNLOAD_TIMEOUT \
        --save "$MIRRORLIST" 2>&1 | tee -a "$LOG"; then
        echo "Mirrorlist pobrany pomyślnie" | tee -a "$LOG"
        break
    else
        echo "Błąd pobierania mirrorlist (próba $i)" | tee -a "$LOG"
        if [ "$i" -eq "$RETRIES" ]; then
            echo "Nie udało się pobrać mirrorlist po $RETRIES próbach" | tee -a "$LOG"
            exit 1
        else
            echo "Czekam 5 sekund przed kolejną próbą..." | tee -a "$LOG"
            sleep 5
        fi
    fi
done

echo "==> Gotowe ✔"

