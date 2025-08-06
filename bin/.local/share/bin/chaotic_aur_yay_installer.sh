#!/bin/bash

# Skrypt instalacyjny Chaotic-AUR dla Arch Linux
# Automatycznie pobiera aktualne klucze i konfiguruje repozytorium

set -euo pipefail

# Kolory dla outputu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funkcja do logowania
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

# Sprawdzenie czy skrypt jest uruchamiany jako root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Ten skrypt nie powinien być uruchamiany jako root!"
    fi
}

# Sprawdzenie czy to Arch Linux
check_arch() {
    if ! command -v pacman &> /dev/null; then
        error "Ten skrypt jest przeznaczony tylko dla Arch Linux!"
    fi
    
    if [[ ! -f /etc/arch-release ]]; then
        error "Nie wykryto Arch Linux!"
    fi
}

# Aktualizacja systemu
update_system() {
    log "Aktualizacja systemu..."
    sudo pacman -Sy --noconfirm
    success "System zaktualizowany"
}

# Instalacja wymaganych narzędzi
install_requirements() {
    log "Sprawdzanie wymaganych narzędzi..."
    
    local packages=()
    
    # Sprawdzenie i dodanie brakujących pakietów
    command -v wget &> /dev/null || packages+=("wget")
    command -v curl &> /dev/null || packages+=("curl")
    command -v gpg &> /dev/null || packages+=("gnupg")
    
    if [[ ${#packages[@]} -gt 0 ]]; then
        log "Instalacja wymaganych pakietów: ${packages[*]}"
        sudo pacman -S --noconfirm "${packages[@]}"
        success "Wymagane pakiety zainstalowane"
    else
        success "Wszystkie wymagane narzędzia są już zainstalowane"
    fi
}

# Sprawdzenie czy Chaotic-AUR już istnieje
check_existing_installation() {
    if pacman -Sl chaotic-aur &> /dev/null; then
        warning "Repozytorium Chaotic-AUR już jest skonfigurowane i działa!"
        
        # Sprawdzenie czy klucze są zainstalowane
        if pacman -Q chaotic-keyring &> /dev/null && pacman -Q chaotic-mirrorlist &> /dev/null; then
            success "Klucze są już zainstalowane"
            log "Sprawdzanie aktualizacji kluczy..."
            sudo pacman -S --noconfirm chaotic-keyring chaotic-mirrorlist
            success "Klucze zaktualizowane"
            return 0
        fi
    fi
    return 1
}

# Pobieranie i instalacja kluczy Chaotic-AUR
install_chaotic_keys() {
    log "Pobieranie kluczy Chaotic-AUR..."
    
    # Najpierw spróbuj zainstalować przez pacman (jeśli już dostępne)
    if sudo pacman -S --noconfirm chaotic-keyring chaotic-mirrorlist 2>/dev/null; then
        success "Klucze zainstalowane przez pacman"
        return 0
    fi
    
    # Jeśli nie, pobierz ze strony
    log "Pobieranie kluczy bezpośrednio ze strony..."
    
    # Aktualne URL-e (sprawdzenie aktualnych linków)
    local base_urls=(
        "https://cdn-mirror.chaotic.cx/chaotic-aur"
        "https://mirror.cachyos.org/chaotic-aur/x86_64"
        "https://builds.garudalinux.org/repos/chaotic-aur/x86_64"
    )
    
    local keyring_file=""
    local mirrorlist_file=""
    
    # Utworzenie tymczasowego katalogu
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Próba pobrania z różnych mirrorów
    for base_url in "${base_urls[@]}"; do
        log "Próba pobrania z: $base_url"
        
        # Pobierz listę plików
        if curl -s "$base_url/" | grep -o 'chaotic-keyring-[^"]*\.pkg\.tar\.[^"]*' | head -1 > keyring_filename.txt; then
            keyring_file=$(cat keyring_filename.txt)
            log "Znaleziono: $keyring_file"
        fi
        
        if curl -s "$base_url/" | grep -o 'chaotic-mirrorlist-[^"]*\.pkg\.tar\.[^"]*' | head -1 > mirrorlist_filename.txt; then
            mirrorlist_file=$(cat mirrorlist_filename.txt)
            log "Znaleziono: $mirrorlist_file"
        fi
        
        if [[ -n "$keyring_file" && -n "$mirrorlist_file" ]]; then
            log "Pobieranie $keyring_file..."
            if wget -q "$base_url/$keyring_file" && wget -q "$base_url/$mirrorlist_file"; then
                success "Pobrano pliki z $base_url"
                break
            else
                warning "Nie udało się pobrać z $base_url"
                keyring_file=""
                mirrorlist_file=""
            fi
        fi
    done
    
    if [[ -z "$keyring_file" || -z "$mirrorlist_file" ]]; then
        error "Nie udało się pobrać kluczy z żadnego mirrora. Spróbuj ręcznej instalacji."
    fi
    
    log "Instalacja kluczy..."
    sudo pacman -U --noconfirm "$keyring_file" "$mirrorlist_file"
    
    # Czyszczenie
    cd /
    rm -rf "$temp_dir"
    
    success "Klucze Chaotic-AUR zainstalowane"
}

# Konfiguracja repozytorium w pacman.conf
configure_repository() {
    log "Konfiguracja repozytorium Chaotic-AUR..."
    
    local pacman_conf="/etc/pacman.conf"
    local backup_conf="/etc/pacman.conf.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Backup pacman.conf
    sudo cp "$pacman_conf" "$backup_conf"
    log "Utworzono backup: $backup_conf"
    
    # Sprawdzenie czy repozytorium już istnieje
    if grep -q "\[chaotic-aur\]" "$pacman_conf"; then
        warning "Repozytorium Chaotic-AUR już istnieje w pacman.conf"
        return 0
    fi
    
    # Dodanie repozytorium na końcu pliku
    log "Dodawanie repozytorium do pacman.conf..."
    sudo tee -a "$pacman_conf" > /dev/null << 'EOF'

# Chaotic-AUR Repository
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
    
    success "Repozytorium Chaotic-AUR dodane do pacman.conf"
}

# Aktualizacja bazy danych pakietów
update_databases() {
    log "Aktualizacja bazy danych pakietów..."
    sudo pacman -Sy
    success "Baza danych pakietów zaktualizowana"
}

# Sprawdzenie czy YAY jest zainstalowany i jego wersji
check_yay_status() {
    if command -v yay &> /dev/null; then
        local yay_version=$(yay --version | head -1 | awk '{print $2}')
        return 0
    else
        return 1
    fi
}

# Instalacja YAY z najnowszą wersją
install_yay() {
    log "Sprawdzanie YAY..."
    
    local current_yay_version=""
    if check_yay_status; then
        current_yay_version=$(yay --version | head -1 | awk '{print $2}')
        log "Aktualna wersja YAY: $current_yay_version"
    else
        log "YAY nie jest zainstalowany"
    fi
    
    # Sprawdź najnowszą wersję na GitHub
    log "Sprawdzanie najnowszej wersji YAY na GitHub..."
    local latest_version=""
    if command -v curl &> /dev/null; then
        latest_version=$(curl -s https://api.github.com/repos/Jguer/yay/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    fi
    
    if [[ -z "$latest_version" ]]; then
        warning "Nie udało się sprawdzić najnowszej wersji YAY z GitHub"
        if ! check_yay_status; then
            log "Instaluję YAY z repozytorium..."
            if sudo pacman -S --noconfirm yay; then
                success "YAY zainstalowany z repozytorium"
                return 0
            else
                warning "Nie udało się zainstalować YAY z repozytorium"
            fi
        else
            success "YAY już jest zainstalowany"
            return 0
        fi
    else
        log "Najnowsza wersja YAY: $latest_version"
        
        # Porównaj wersje
        if [[ -n "$current_yay_version" ]] && [[ "$current_yay_version" == "$latest_version" ]]; then
            success "YAY jest już w najnowszej wersji ($current_yay_version)"
            return 0
        fi
    fi
    
    # Instalacja/aktualizacja YAY
    log "Instalacja/aktualizacja YAY do wersji $latest_version..."
    
    # Sprawdź czy jest dostępny w Chaotic-AUR
    if pacman -Ss chaotic-aur/yay &> /dev/null; then
        log "Instalacja YAY z Chaotic-AUR..."
        if sudo pacman -S --noconfirm chaotic-aur/yay; then
            success "YAY zainstalowany/zaktualizowany z Chaotic-AUR"
            return 0
        fi
    fi
    
    # Instalacja z oficjalnych repozytoriów
    if sudo pacman -S --noconfirm yay; then
        success "YAY zainstalowany z oficjalnych repozytoriów"
        return 0
    fi
    
    # Ostatnia opcja - kompilacja ze źródeł
    warning "Próba kompilacji YAY ze źródeł..."
    install_yay_from_source "$latest_version"
}

# Kompilacja YAY ze źródeł
install_yay_from_source() {
    local version="$1"
    
    # Sprawdź wymagane narzędzia
    local required_tools=("git" "base-devel" "go")
    local missing_tools=()
    
    command -v git &> /dev/null || missing_tools+=("git")
    command -v go &> /dev/null || missing_tools+=("go")
    pacman -Q base-devel &> /dev/null || missing_tools+=("base-devel")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log "Instalacja wymaganych narzędzi: ${missing_tools[*]}"
        sudo pacman -S --noconfirm "${missing_tools[@]}"
    fi
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    log "Klonowanie repozytorium YAY..."
    if git clone https://github.com/Jguer/yay.git; then
        cd yay
        
        if [[ -n "$version" ]]; then
            log "Przełączanie na wersję $version..."
            git checkout "v$version" 2>/dev/null || log "Używam najnowszej wersji z main"
        fi
        
        log "Kompilacja YAY..."
        if make build; then
            log "Instalacja YAY..."
            sudo make install
            success "YAY skompilowany i zainstalowany ze źródeł"
        else
            error "Nie udało się skompilować YAY"
        fi
    else
        error "Nie udało się sklonować repozytorium YAY"
    fi
    
    # Czyszczenie
    cd /
    rm -rf "$temp_dir"
}

# Wyświetlenie informacji o użytkowaniu
show_usage_info() {
    echo ""
    echo -e "${GREEN}=== Chaotic-AUR i YAY zainstalowane pomyślnie! ===${NC}"
    echo ""
    echo "Teraz możesz instalować pakiety z:"
    echo ""
    echo "Chaotic-AUR (przez pacman):"
    echo "  pacman -S nazwa_pakietu"
    echo ""
    echo "AUR (przez YAY):"
    echo "  yay -S nazwa_pakietu"
    echo ""
    echo "Wyszukiwanie pakietów:"
    echo "  pacman -Ss nazwa_pakietu  # w Chaotic-AUR"
    echo "  yay -Ss nazwa_pakietu     # w AUR + repozytoriach"
    echo ""
    echo "Wyświetlanie pakietów:"
    echo "  pacman -Sl chaotic-aur    # wszystkie z Chaotic-AUR"
    echo "  yay -Qm                   # zainstalowane z AUR"
    echo ""
    echo "Aktualizacja systemu:"
    echo "  yay                       # aktualizuje wszystko (pacman + AUR)"
    echo "  sudo pacman -Syu          # tylko oficjalne repozytoria"
    echo ""
    echo "Więcej informacji:"
    echo "  Chaotic-AUR: https://aur.chaotic.cx/"
    echo "  YAY: https://github.com/Jguer/yay"
    echo ""
}

# Główna funkcja
main() {
    echo -e "${BLUE}=== Instalator Chaotic-AUR dla Arch Linux ===${NC}"
    echo ""
    
    check_root
    check_arch
    update_system
    install_requirements
    
    # Sprawdź czy już istnieje
    if check_existing_installation; then
        log "Pomijam konfigurację - repozytorium już działa"
        verify_installation
        show_usage_info
        return 0
    fi
    
    install_chaotic_keys
    configure_repository
    update_databases
    install_yay  # Dodana instalacja YAY
    verify_installation
    show_usage_info
    
    success "Instalacja zakończona pomyślnie!"
}

# Obsługa sygnałów
trap 'error "Przerwano przez użytkownika"' INT TERM

# Uruchomienie głównej funkcji
main "$@"