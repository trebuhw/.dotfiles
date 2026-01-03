#!/usr/bin/env bash

# ==========================================================
#  SKRYPT BACKUPU – PROSTA WERSJA Z WYKLUCZENIAMI
# ==========================================================
#
# Jak używać:
# 1. Nadaj prawa do uruchomienia:
#    chmod +x backup.sh
# 2. Uruchom skrypt:
#    ./backup.sh
#
# Dodawanie nowych plików lub katalogów do backupu:
# - Po prostu dopisz linię do SOURCES w formacie:
#   "ścieżka_źródłowa ścieżka_docelowa"
#
# Wykluczenia dla każdego źródła:
# - Dodaj odpowiadającą pozycję w tablicy EXCLUDES
# - Każdy katalog do wykluczenia dodaj z '/' na końcu
# - Każdy plik wpisz normalnie
#
# Przykład:
#   SOURCES: "$HOME/Dokumenty $HOME/Backup/Dokumenty"
#   EXCLUDES: "tmp/ sekret.txt"
#   → katalog tmp i plik sekret.txt NIE zostaną skopiowane
#
# Opcje rsync:
#   Możesz dodać --dry-run do testu bez kopiowania
# ==========================================================

# =========================
# KONFIGURACJA
# =========================

RSYNC_OPTS="-av --delete"

# Lista źródeł i miejsc docelowych
SOURCES=(
  "$HOME/.config/chromium $HOME/Backup/Chromium/.config"
  "$HOME/.cache/chromium $HOME/Backup/Chromium/.cache"
  "$HOME/Szablony $HOME/Backup/Szablony"
  "$HOME/Dokumenty $HOME/Backup/Dokumenty"
  "$HOME/Obrazy $HOME/Backup/Obrazy"
  "$HOME/.git-credentials $HOME/Backup/.git-credentials"
  "$HOME/.gitconfig $HOME/Backup/.gitconfig"
  "$HOME/.ssh $HOME/Backup/.ssh"
)

# Wykluczenia dla każdego źródła (w tej samej kolejności co SOURCES)
EXCLUDES=(
  ""                  # .config/chromium - brak wykluczeń
  ""                  # .cache/chromium - brak wykluczeń
  ""                  # Szablony - brak wykluczeń
  "tmp/ sekret.txt"   # Dokumenty - wykluczamy katalog tmp i plik sekret.txt
  ""                  # Obrazy - brak wykluczeń
  ""                  # .git-credentials - brak wykluczeń
  ""                  # .gitconfig - brak wykluczeń
  ""                  # .ssh - brak wykluczeń
)

# =========================
# BACKUP
# =========================

echo ">>> Start backupu"

for i in "${!SOURCES[@]}"; do
    entry="${SOURCES[$i]}"
    SRC="${entry%% *}"
    TARGET="${entry##* }"

    # Sprawdź, czy źródło istnieje
    if [[ ! -e "$SRC" ]]; then
        echo "⚠ Pomijam – źródło nie istnieje: $SRC"
        continue
    fi

    echo "Backup:"
    echo "  Źródło : $SRC"
    echo "  Cel    : $TARGET"

    # Przygotuj katalog docelowy
    if [[ -d "$SRC" ]]; then
        mkdir -p "$TARGET"
    else
        mkdir -p "$(dirname "$TARGET")"
    fi

    # Tworzymy dynamiczne wykluczenia dla rsync
    RSYNC_EXCLUDES=""
    for excl in ${EXCLUDES[$i]}; do
        RSYNC_EXCLUDES+=" --exclude '$excl'"
    done

    # Wykonanie backupu
    if [[ -d "$SRC" ]]; then
        eval rsync $RSYNC_OPTS $RSYNC_EXCLUDES "$SRC/" "$TARGET/"
    else
        eval rsync $RSYNC_OPTS $RSYNC_EXCLUDES "$SRC" "$TARGET"
    fi

    echo "  ✔ Zakończono"
done

echo ">>> Backup zakończony"

