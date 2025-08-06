#!/bin/sh

# Ścieżki i ustawienia
MOUNT_DIR_GDRIVE="$HOME/Cloud/GDrive"
MOUNT_DIR_ONEDRIVE="$HOME/Cloud/OneDrive"
LOG_FILE="$HOME/.rclone/rclone.log"
RCLONE_CONFIG="$HOME/.config/rclone/rclone.conf"

# Tworzenie katalogów, jeśli nie istnieją
mkdir -p "$MOUNT_DIR_GDRIVE" "$MOUNT_DIR_ONEDRIVE" "$HOME/.rclone"

# Sprawdzanie, czy rclone jest zainstalowany
if ! command -v rclone >/dev/null 2>&1; then
    echo "Błąd: rclone nie jest zainstalowany."
    echo "Void: sudo xbps-install -S rclone"
    echo "Arch: sudo pacman -S rclone"
    echo "openSUSE: sudo zypper install rclone"
    exit 1
fi

# Sprawdzanie wersji rclone
RCLONE_VERSION=$(rclone version | head -n1)
if echo "$RCLONE_VERSION" | grep -E "v1\.[0-5][0-9]\." >/dev/null; then
    echo "Ostrzeżenie: Używasz starej wersji rclone ($RCLONE_VERSION). Zalecana aktualizacja."
fi

# Sprawdzanie, czy konfiguracja rclone istnieje
if [ ! -f "$RCLONE_CONFIG" ]; then
    echo "Błąd: Plik konfiguracyjny rclone ($RCLONE_CONFIG) nie istnieje. Skonfiguruj: rclone config"
    exit 1
fi

echo "Uruchamianie rclone mount dla Google Drive i OneDrive..."

# Parametry wspólne dla rclone
RCLONE_COMMON_OPTS="--vfs-cache-mode full \
                    --vfs-read-chunk-size=64M \
                    --vfs-cache-max-size=1G \
                    --vfs-read-ahead=128M \
                    --buffer-size=64M \
                    --multi-thread-streams=4 \
                    --tpslimit=10 \
                    --fast-list \
                    --log-file=$LOG_FILE \
                    --log-level INFO"

# Parametry specyficzne dla Google Drive
GDRIVE_OPTS="--drive-chunk-size=64M"

# Parametry specyficzne dla OneDrive
ONEDRIVE_OPTS="--onedrive-chunk-size=60M \
               --onedrive-delta"

# Funkcja do montowania
mount_rclone() {
    remote="$1"
    mount_dir="$2"
    extra_opts="$3"
    if mountpoint -q "$mount_dir" 2>/dev/null || findmnt "$mount_dir" >/dev/null 2>&1; then
        echo "Ostrzeżenie: $mount_dir jest już zamontowany. Pomijam."
    else
        rclone mount "$remote" "$mount_dir" $RCLONE_COMMON_OPTS $extra_opts &
        sleep 2
        if mountpoint -q "$mount_dir" 2>/dev/null || findmnt "$mount_dir" >/dev/null 2>&1; then
            echo "$remote zamontowany w $mount_dir"
        else
            echo "Błąd: Nie udało się zamontować $remote. Sprawdź logi: $LOG_FILE"
        fi
    fi
}

# Montowanie dysków
mount_rclone "gdrive:" "$MOUNT_DIR_GDRIVE" "$GDRIVE_OPTS"
mount_rclone "onedrive:" "$MOUNT_DIR_ONEDRIVE" "$ONEDRIVE_OPTS"

exit 0
