#!/usr/bin/env bash

# Skrypt do aktualizacji kluczy Chaotic-AUR
# Automatycznie pobiera i aktualizuje najnowsze klucze

set -euo pipefail

# Kolory dla outputu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funkcje do logowania
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${CYAN}[AKTUALIZACJA]${NC} $1"
}

# Sprawdzenie czy to Arch Linux
check_arch() {
    if ! command -v pacman &> /dev/null; then
        error "Ten skrypt jest przeznaczony tylko dla Arch Linux!"
    fi
}

# Sprawdzenie czy Chaotic-AUR jest skonfigurowane
check_chaotic_configured() {
    if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        error "Repozytorium Chaotic-AUR nie jest skonfigurowane w /etc/pacman.conf!"
    fi
    
    if ! pacman -Sl chaotic-aur &> /dev/null; then
        warning "Repozytorium Chaotic-AUR nie jest dostępne. Sprawdź konfigurację."
        return 1
    fi
    
    success "Repozytorium Chaotic-AUR jest skonfigurowane"
    return 0
}

# Sprawdzenie aktualnych wersji kluczy
check_current_versions() {
    log "Sprawdzanie aktualnych wersji kluczy..."
    
    if pacman -Q chaotic-keyring &> /dev/null; then
        local keyring_version=$(pacman -Q chaotic-keyring | awk '{print $2}')
        info "Aktualna wersja chaotic-keyring: $keyring_version"
    else
        warning "chaotic-keyring nie jest zainstalowany"
    fi
    
    if pacman -Q chaotic-mirrorlist &> /dev/null; then
        local mirrorlist_version=$(pacman -Q chaotic-mirrorlist | awk '{print $2}')
        info "Aktualna wersja chaotic-mirrorlist: $mirrorlist_version"
    else
        warning "chaotic-mirrorlist nie jest zainstalowany"
    fi
}

# Aktualizacja przez pacman
update_via_pacman() {
    log "Próba aktualizacji kluczy przez pacman..."
    
    # Odświeżenie baz danych
    sudo pacman -Sy
    
    # Próba aktualizacji kluczy
    if sudo pacman -S --noconfirm chaotic-keyring chaotic-mirrorlist; then
        success "Klucze zaktualizowane przez pacman"
        return 0
    else
        warning "Nie udało się zaktualizować przez pacman"
        return 1
    fi
}

# Pobieranie kluczy bezpośrednio z mirrorów
update_via_direct_download() {
    log "Pobieranie kluczy bezpośrednio z mirrorów..."
    
    # Lista aktualnych mirrorów Chaotic-AUR
    local mirrors=(
        "https://builds.garudalinux.org/repos/chaotic-aur/x86_64"
        "https://mirror.cachyos.org/chaotic-aur/x86_64"
        "https://cdn-mirror.chaotic.cx/chaotic-aur/x86_64"
        "https://chaotic.oma.pet/x86_64"
    )
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    local success_mirror=""
    
    for mirror in "${mirrors[@]}"; do
        log "Sprawdzanie mirrora: $mirror"
        
        # Pobierz listę plików z mirrora
        local mirror_content=""
        if mirror_content=$(curl -s --connect-timeout 10 "$mirror/" 2>/dev/null); then
            # Znajdź najnowsze pliki kluczy
            local keyring_file=$(echo "$mirror_content" | grep -o 'chaotic-keyring-[^"]*\.pkg\.tar\.[^"]*' | sort -V | tail -1)
            local mirrorlist_file=$(echo "$mirror_content" | grep -o 'chaotic-mirrorlist-[^"]*\.pkg\.tar\.[^"]*' | sort -V | tail -1)
            
            if [[ -n "$keyring_file" && -n "$mirrorlist_file" ]]; then
                info "Znalezione pliki:"
                info "  - $keyring_file"
                info "  - $mirrorlist_file"
                
                log "Pobieranie plików z $mirror..."
                if wget -q --timeout=30 "$mirror/$keyring_file" && wget -q --timeout=30 "$mirror/$mirrorlist_file"; then
                    success_mirror="$mirror"
                    log "Instalacja pobranych kluczy..."
                    if sudo pacman -U --noconfirm "$keyring_file" "$mirrorlist_file"; then
                        success "Klucze zainstalowane z $mirror"
                        break
                    else
                        warning "Błąd podczas instalacji kluczy z $mirror"
                    fi
                else
                    warning "Nie udało się pobrać plików z $mirror"
                fi
            else
                warning "Nie znaleziono plików kluczy na $mirror"
            fi
        else
            warning "Nie można połączyć się z $mirror"
        fi
    done
    
    # Czyszczenie
    cd /
    rm -rf "$temp_dir"
    
    if [[ -n "$success_mirror" ]]; then
        success "Klucze pobrane i zainstalowane z $success_mirror"
        return 0
    else
        error "Nie udało się pobrać kluczy z żadnego mirrora"
    fi
}

# Weryfikacja po aktualizacji
verify_update() {
    log "Weryfikacja aktualizacji..."
    
    # Odświeżenie baz danych
    sudo pacman -Sy
    
    # Sprawdzenie czy repozytorium działa
    if pacman -Sl chaotic-aur &> /dev/null; then
        local package_count=$(pacman -Sl chaotic-aur | wc -l)
        success "Repozytorium Chaotic-AUR działa poprawnie"
        info "Dostępnych pakietów: $package_count"
        
        # Wyświetl nowe wersje
        if pacman -Q chaotic-keyring &> /dev/null; then
            local keyring_version=$(pacman -Q chaotic-keyring | awk '{print $2}')
            info "Nowa wersja chaotic-keyring: $keyring_version"
        fi
        
        if pacman -Q chaotic-mirrorlist &> /dev/null; then
            local mirrorlist_version=$(pacman -Q chaotic-mirrorlist | awk '{print $2}')
            info "Nowa wersja chaotic-mirrorlist: $mirrorlist_version"
        fi
        
        return 0
    else
        error "Repozytorium Chaotic-AUR nie działa po aktualizacji!"
    fi
}

# Wymuszenie ponownego importu kluczy GPG
force_key_import() {
    log "Wymuszanie ponownego importu kluczy GPG..."
    
    # Usuń cache kluczy GPG dla pacmana
    sudo rm -f /etc/pacman.d/gnupg/trustdb.gpg
    
    # Zainicjuj ponownie keyring pacmana
    sudo pacman-key --init
    sudo pacman-key --populate
    
    # Zaimportuj klucze Chaotic-AUR
    if [[ -f /usr/share/pacman/keyrings/chaotic.gpg ]]; then
        sudo pacman-key --add /usr/share/pacman/keyrings/chaotic.gpg
        sudo pacman-key --lsign-key 3056513887B78AEB
    fi
    
    success "Klucze GPG zaimportowane ponownie"
}

# Wyświetlenie informacji o stanie kluczy
show_keys_info() {
    echo ""
    echo -e "${CYAN}=== Informacje o kluczach Chaotic-AUR ===${NC}"
    
    if pacman -Q chaotic-keyring &> /dev/null; then
        echo -e "${GREEN}✓${NC} chaotic-keyring: $(pacman -Q chaotic-keyring | awk '{print $2}')"
    else
        echo -e "${RED}✗${NC} chaotic-keyring: nie zainstalowany"
    fi
    
    if pacman -Q chaotic-mirrorlist &> /dev/null; then
        echo -e "${GREEN}✓${NC} chaotic-mirrorlist: $(pacman -Q chaotic-mirrorlist | awk '{print $2}')"
    else
        echo -e "${RED}✗${NC} chaotic-mirrorlist: nie zainstalowany"
    fi
    
    echo ""
    if pacman -Sl chaotic-aur &> /dev/null; then
        local package_count=$(pacman -Sl chaotic-aur | wc -l)
        echo -e "${GREEN}Status repozytorium:${NC} Aktywne ($package_count pakietów)"
    else
        echo -e "${RED}Status repozytorium:${NC} Nieaktywne"
    fi
    echo ""
}

# Główna funkcja
main() {
    echo -e "${CYAN}=== Aktualizator kluczy Chaotic-AUR ===${NC}"
    echo ""
    
    check_arch
    
    if ! check_chaotic_configured; then
        error "Najpierw skonfiguruj repozytorium Chaotic-AUR"
    fi
    
    show_keys_info
    check_current_versions
    
    echo ""
    log "Rozpoczynam aktualizację kluczy..."
    
    # Próba 1: Aktualizacja przez pacman
    if update_via_pacman; then
        verify_update
        show_keys_info
        success "Aktualizacja zakończona pomyślnie!"
        return 0
    fi
    
    # Próba 2: Bezpośrednie pobieranie
    warning "Pacman nie może zaktualizować kluczy. Próbuję bezpośredniego pobierania..."
    if update_via_direct_download; then
        force_key_import
        verify_update
        show_keys_info
        success "Aktualizacja zakończona pomyślnie!"
        return 0
    fi
    
    error "Nie udało się zaktualizować kluczy żadną metodą"
}

# Obsługa parametrów
case "${1:-}" in
    --force-gpg)
        echo -e "${CYAN}=== Wymuszanie ponownego importu kluczy GPG ===${NC}"
        check_arch
        force_key_import
        sudo pacman -Sy
        success "Import kluczy GPG zakończony"
        ;;
    --info)
        echo -e "${CYAN}=== Informacje o kluczach Chaotic-AUR ===${NC}"
        check_arch
        show_keys_info
        ;;
    --help|-h)
        echo "Aktualizator kluczy Chaotic-AUR"
        echo ""
        echo "Użycie:"
        echo "  $0            - Aktualizuj klucze"
        echo "  $0 --info     - Pokaż informacje o kluczach"
        echo "  $0 --force-gpg - Wymuś ponowny import kluczy GPG"
        echo "  $0 --help     - Pokaż tę pomoc"
        ;;
    "")
        main
        ;;
    *)
        error "Nieznany parametr: $1. Użyj --help aby zobaczyć dostępne opcje."
        ;;
esac
