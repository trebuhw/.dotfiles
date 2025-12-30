#!/usr/bin/env bash

# =============================================================================
# clean.sh — skrypt do bezpiecznego czyszczenia systemu Arch Linux / CachyOS
#
# Co robi skrypt:
# 1. Czyści cache pacmana, pozostawiając 2 ostatnie wersje pakietów
#    (umożliwia downgrade i rollback).
# 2. Usuwa cache nieużywanych pakietów (paccache -ruk0).
# 3. Wykrywa i usuwa osierocone pakiety (pakiety bez zależności).
# 4. Czyści cache AUR (yay) z katalogu ~/.cache/yay.
# 5. Czyści cache użytkownika (~/.cache).
# 6. Usuwa porzucone katalogi pobierania pacmana (download-*),
#    które nie są usuwane przez pacman -Scc ani yay -Scc.
# 7. Czyści logi systemowe journalctl, pozostawiając wpisy z ostatnich 2 tygodni.
# 8. Opróżnia kosz użytkownika oraz kosz systemowy (trash-cli).
#
# Dlaczego NIE używać pacman -Scc / yay -Scc:
# - Usuwają wszystkie pakiety z cache (brak możliwości downgrade).
# - Nie usuwają katalogów (np. download-*).
# - Są zbyt agresywne do codziennego użytku.
#
# Wymagania:
# - Arch Linux / CachyOS
# - pakiety: pacman-contrib (paccache), trash-cli, yay
#
# Uruchamianie:
#   chmod +x clean.sh
#   ./clean.sh
#
# Opcjonalnie:
#   sudo mv clean.sh /usr/local/bin/clean
#   clean
#
# UWAGA:
# - Skrypt używa sudo — upewnij się, że wiesz co robisz.
# - Usuwanie cache jest bezpieczne, ale może zwiększyć czas kolejnych aktualizacji.
# =============================================================================

# =============================================================================
# clean.sh — uniwersalny skrypt czyszczący (bash / fish)
# Arch Linux / CachyOS
# =============================================================================

set -euo pipefail

echo "==> Czyszczenie cache pacmana (zostaw 2 wersje)"
sudo paccache -rk2 || true
sudo paccache -ruk0 || true

echo "==> Usuwanie osieroconych pakietów"
orphans=$(pacman -Qtdq 2>/dev/null || true)
if [ -n "$orphans" ]; then
    sudo pacman -Rns $orphans
else
    echo "Brak osieroconych pakietów"
fi

echo "==> Czyszczenie cache AUR (yay)"
if [ -d "$HOME/.cache/yay" ]; then
    find "$HOME/.cache/yay" -mindepth 1 -exec rm -rf {} +
fi

echo "==> Czyszczenie cache użytkownika"
if [ -d "$HOME/.cache" ]; then
    find "$HOME/.cache" -mindepth 1 -maxdepth 1 \
        ! -path "$HOME/.cache/yay" \
        ! -path "$HOME/.cache/fish" \
        -exec rm -rf {} +
fi

echo "==> Czyszczenie cache fish (bezpiecznie)"
if [ -d "$HOME/.cache/fish" ]; then
    find "$HOME/.cache/fish" -mindepth 1 -exec rm -rf {} +
fi

echo "==> Usuwanie porzuconych katalogów pacmana"
sudo rm -rf /var/cache/pacman/pkg/download-* 2>/dev/null || true

echo "==> Czyszczenie journalctl (2 tygodnie)"
sudo journalctl --vacuum-time=2weeks || true

echo "==> Opróżnianie kosza"
command -v trash-empty >/dev/null 2>&1 && trash-empty -f || true
command -v trash-empty >/dev/null 2>&1 && sudo trash-empty -f || true

echo "==> Gotowe ✔"
