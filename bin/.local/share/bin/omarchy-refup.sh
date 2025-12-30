#!/usr/bin/env bash
# =============================================================================
# omarchy-refup.sh — Mirrorlist updater dla Omarchy z dynamicznymi mirrorami Arch
# =============================================================================
# ./omarchy-refup.sh        # używa stable
#./omarchy-refup.sh edge   # używa channel edge

set -euo pipefail

CHANNEL="${1:-stable}"  # domyślnie stable
MIRRORLIST="/etc/pacman.d/mirrorlist"
PACMAN_CONF="/etc/pacman.conf"
BACKUP_DIR="$HOME/omarchy-backup"
LOG="$HOME/refup.log"

RETRIES=3
CONNECTION_TIMEOUT=10
DOWNLOAD_TIMEOUT=20

mkdir -p "$BACKUP_DIR"

echo "==> Tworzenie backupu pacman.conf i mirrorlist"
sudo cp -f "$PACMAN_CONF" "$BACKUP_DIR/pacman.conf.bak"
sudo cp -f "$MIRRORLIST" "$BACKUP_DIR/mirrorlist.bak"

# Ustawienie pacman.conf i mirrorlist Omarchy
if [[ "$CHANNEL" == "edge" ]]; then
    sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist-edge "$MIRRORLIST"
    sudo cp -f ~/.local/share/omarchy/default/pacman/pacman.conf "$PACMAN_CONF"
    sudo sed -i 's|https://pkgs.omarchy.org/.*$arch|https://pkgs.omarchy.org/edge/$arch|' "$PACMAN_CONF"
    echo "Setting channel to edge"
else
    sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist-stable "$MIRRORLIST"
    sudo cp -f ~/.local/share/omarchy/default/pacman/pacman.conf "$PACMAN_CONF"
    sudo sed -i 's|https://pkgs.omarchy.org/.*$arch|https://pkgs.omarchy.org/stable/$arch|' "$PACMAN_CONF"
    echo "Setting channel to stable"
fi

echo "==> Dodawanie najszybszych mirrorów Arch (retry $RETRIES)"
for i in $(seq 1 $RETRIES); do
    echo "Próba $i/$RETRIES..." | tee -a "$LOG"
    if sudo reflector \
        --latest 30 \
        --protocol https \
        --sort rate \
        --number 10 \
        --connection-timeout $CONNECTION_TIMEOUT \
        --download-timeout $DOWNLOAD_TIMEOUT \
        --verbose \
        --save "$MIRRORLIST" 2>&1 | tee -a "$LOG"; then
        echo "Mirrorlist Arch pobrany pomyślnie" | tee -a "$LOG"
        break
    else
        echo "Błąd pobierania mirrorlist Arch (próba $i)" | tee -a "$LOG"
        if [ "$i" -eq "$RETRIES" ]; then
            echo "Nie udało się pobrać mirrorlist po $RETRIES próbach, używana zostaje statyczna lista Omarchy" | tee -a "$LOG"
        else
            sleep 5
        fi
    fi
done

echo
echo "==> Aktualizacja systemu"
sudo pacman -Syyu --noconfirm

echo "==> Gotowe ✔"

