#!/usr/bin/env bash

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
  if ! command -v pacman &>/dev/null; then
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

  # Sprawdzenie czy wget jest zainstalowany
  if ! command -v wget &>/dev/null; then
    packages+=("wget")
  fi

  # Sprawdzenie czy curl jest zainstalowany
  if ! command -v curl &>/dev/null; then
    packages+=("curl")
  fi

  # Sprawdzenie czy gpg jest zainstalowany
  if ! command -v gpg &>/dev/null; then
    packages+=("gnupg")
  fi

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
  if pacman -Sl chaotic-aur &>/dev/null; then
    warning "Repozytorium Chaotic-AUR już jest skonfigurowane i działa!"

    # Sprawdzenie czy klucze są zainstalowane
    if pacman -Q chaotic-keyring &>/dev/null && pacman -Q chaotic-mirrorlist &>/dev/null; then
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
    if curl -s "$base_url/" | grep -o 'chaotic-keyring-[^"]*\.pkg\.tar\.[^"]*' | head -1 >keyring_filename.txt; then
      keyring_file=$(cat keyring_filename.txt)
      log "Znaleziono: $keyring_file"
    fi

    if curl -s "$base_url/" | grep -o 'chaotic-mirrorlist-[^"]*\.pkg\.tar\.[^"]*' | head -1 >mirrorlist_filename.txt; then
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
  sudo tee -a "$pacman_conf" >/dev/null <<'EOF'

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

# Weryfikacja instalacji
verify_installation() {
  log "Weryfikacja instalacji..."

  # Sprawdzenie czy repozytorium jest dostępne
  if pacman -Sl chaotic-aur &>/dev/null; then
    success "Repozytorium Chaotic-AUR jest dostępne!"

    # Wyświetlenie liczby dostępnych pakietów
    local package_count=$(pacman -Sl chaotic-aur | wc -l)
    log "Dostępnych pakietów: $package_count"

    # Przykłady popularnych pakietów
    log "Przykłady dostępnych pakietów:"
    echo "  - google-chrome"
    echo "  - visual-studio-code-bin"
    echo "  - discord"
    echo "  - spotify"
    echo "  - zoom"

  else
    error "Repozytorium Chaotic-AUR nie jest dostępne!"
  fi
}

# Wyświetlenie informacji o użytkowaniu
show_usage_info() {
  echo ""
  echo -e "${GREEN}=== Chaotic-AUR zainstalowane pomyślnie! ===${NC}"
  echo ""
  echo "Teraz możesz instalować pakiety z Chaotic-AUR używając:"
  echo "  pacman -S nazwa_pakietu"
  echo ""
  echo "Aby wyszukać pakiety:"
  echo "  pacman -Ss nazwa_pakietu"
  echo ""
  echo "Aby wyświetlić wszystkie pakiety z Chaotic-AUR:"
  echo "  pacman -Sl chaotic-aur"
  echo ""
  echo "Więcej informacji: https://aur.chaotic.cx/"
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
  verify_installation
  show_usage_info

  success "Instalacja zakończona pomyślnie!"
}

# Obsługa sygnałów
trap 'error "Przerwano przez użytkownika"' INT TERM

# Uruchomienie głównej funkcji
main "$@"
