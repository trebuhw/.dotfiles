#!/usr/bin/env bash

# ==========================================================
#  SKRYPT PRZYWRACANIA BACKUPU
#
#  UWAGA:
#  - Skrypt DZIAŁA TYLKO, jeśli znajduje się w katalogu "Backup"
#  - Uruchamiany ręcznie (pendrive / VM / katalog lokalny)
#  - Wymaga jawnego potwierdzenia (wpisz: TAK)
#  - Przywraca pliki do katalogu domowego użytkownika
# ==========================================================

set -e

# =========================
# ŚCIEŻKA SKRYPTU
# =========================

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
SCRIPT_BASENAME="$(basename "$SCRIPT_DIR")"

if [[ "$SCRIPT_BASENAME" != "Backup" ]]; then
    echo "❌ BŁĄD LOKALIZACJI"
    echo "Skrypt musi znajdować się w katalogu: Backup"
    echo "Aktualna lokalizacja: $SCRIPT_DIR"
    exit 1
fi

# =========================
# POTWIERDZENIE
# =========================

if [[ ! -t 0 ]]; then
    echo "❌ Brak interaktywnego terminala – przerwano"
    exit 1
fi

echo
echo "⚠ UWAGA ⚠"
echo "Ten skrypt PRZYWRÓCI pliki do Twojego katalogu domowego."
echo "Może to NADPISAĆ istniejące pliki."
echo
echo "Skrypt działa tylko, jeśli jest uruchomiony z katalogu: Backup"
echo
read -rp "Czy na pewno chcesz przywrócić pliki? Wpisz TAK aby kontynuować, NIE aby przerwać: " CONFIRM

if [[ "$CONFIRM" != "TAK" ]]; then
    echo "❌ Anulowano"
    exit 0
fi

echo ">>> Potwierdzono – rozpoczynam restore"
echo

# =========================
# ŚCIEŻKI BACKUPU
# =========================

REMOTE_BACKUP="$SCRIPT_DIR"
LOCAL_BACKUP="$HOME/Backup"

RESTORE_OPTS="-av"
LOG_FILE="$LOCAL_BACKUP/restore_errors.log"

# =========================
# MAPOWANIE (ODWROTNOŚĆ BACKUP.SH)
# =========================

RESTORES=(
  "$LOCAL_BACKUP/Chromium/.config $HOME/.config/chromium"
  "$LOCAL_BACKUP/Chromium/.cache  $HOME/.cache/chromium"
  "$LOCAL_BACKUP/Szablony         $HOME/Szablony"
  "$LOCAL_BACKUP/Dokumenty       $HOME/Dokumenty"
  "$LOCAL_BACKUP/Obrazy           $HOME/Obrazy"
  "$LOCAL_BACKUP/.git-credentials $HOME/.git-credentials"
  "$LOCAL_BACKUP/.gitconfig       $HOME/.gitconfig"
  "$LOCAL_BACKUP/.ssh             $HOME/.ssh"
)

# =========================
# KROK 1: KOPIA BACKUP → ~/Backup
# =========================

echo ">>> Kopiuję backup → $LOCAL_BACKUP"

mkdir -p "$LOCAL_BACKUP"
rsync -av \
  --exclude "backup-restore.sh" \
  "$REMOTE_BACKUP/" "$LOCAL_BACKUP/"

# =========================
# KROK 2: PRZYWRACANIE
# =========================

echo
echo ">>> Przywracam dane do \$HOME"
echo

for entry in "${RESTORES[@]}"; do
    SRC="${entry%% *}"
    DEST="${entry##* }"

    if [[ ! -e "$SRC" ]]; then
        echo "⚠ Pomijam – brak: $SRC"
        continue
    fi

    echo "➜ Restore:"
    echo "  Źródło : $SRC"
    echo "  Cel    : $DEST"

    if [[ -d "$SRC" ]]; then
        mkdir -p "$DEST"
        rsync $RESTORE_OPTS "$SRC/" "$DEST/" 2>> "$LOG_FILE"
    else
        mkdir -p "$(dirname "$DEST")"
        rsync $RESTORE_OPTS "$SRC" "$DEST" 2>> "$LOG_FILE"
    fi

    echo "  ✔ Zakończono"
done

# =========================
# UPRAWNIENIA SSH
# =========================

if [[ -d "$HOME/.ssh" ]]; then
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/"* 2>/dev/null || true
    echo "✔ Uprawnienia ~/.ssh ustawione"
fi

# =========================
# KONIEC
# =========================

echo
echo ">>> Restore zakończony"
echo ">>> Log błędów: $LOG_FILE"

bat "$LOG_FILE" 2>/dev/null || cat "$LOG_FILE"

