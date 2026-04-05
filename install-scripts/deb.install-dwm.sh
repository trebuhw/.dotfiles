#!/bin/bash
# =============================================================================
# Instalator środowiska DWM (suckless)
# Klonuje repozytoria do ~/.config/suckless
# =============================================================================
set -euo pipefail

SUCKLESS_DIR="$HOME/.config/suckless"
BRANCH_NAME="main"

REPOS=(
  "dwm   https://git.suckless.org/dwm"
  "dmenu https://git.suckless.org/dmenu"
  "st    https://git.suckless.org/st"
)

# -----------------------------------------------------------------------------
info()    { echo -e "\e[34m[INFO]\e[0m  $*"; }
ok()      { echo -e "\e[32m[OK]\e[0m    $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m  $*"; }
die()     { echo -e "\e[31m[ERR]\e[0m   $*" >&2; exit 1; }
# -----------------------------------------------------------------------------

# ── 1. Aktualizacja systemu ──────────────────────────────────────────────────
info "Aktualizacja systemu..."
sudo apt update
sudo apt upgrade -y

# ── 2. Instalacja pakietów ───────────────────────────────────────────────────
info "Instalacja pakietów (bez recommends)..."
sudo apt install -y --no-install-recommends \
  build-essential git stow \
  libx11-dev libxft-dev libxinerama-dev \
  libxrandr-dev libxrender-dev libxext-dev libxfixes-dev \
  pkg-config \
  xorg xinit x11-xserver-utils \
  fonts-dejavu-core fonts-noto-core \
  network-manager \
  lm-sensors brightnessctl alsa-utils iw acpi \
  feh \
  bluez blueman xclip \
  xdg-utils xdg-user-dirs \
  polkit-gnome \
  curl unzip

sudo systemctl enable NetworkManager
xdg-user-dirs-update
ok "Pakiety zainstalowane."

# ── 3. Globalne no-install-recommends ───────────────────────────────────────
info "Włączanie globalnego no-install-recommends..."
sudo tee /etc/apt/apt.conf.d/99norecommends > /dev/null <<'APT'
APT::Install-Recommends "0";
APT::Install-Suggests "0";
APT

# ── 4. Locale pl_PL ─────────────────────────────────────────────────────────
info "Generowanie locale pl_PL.UTF-8..."
if ! locale -a 2>/dev/null | grep -q "pl_PL.utf8"; then
  sudo locale-gen pl_PL.UTF-8
  sudo update-locale
  ok "Locale pl_PL.UTF-8 wygenerowane."
else
  ok "Locale pl_PL.UTF-8 już istnieje."
fi

# ── 5. JetBrains Nerd Font ───────────────────────────────────────────────────
info "Instalacja JetBrains Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if ! fc-list | grep -qi "JetBrainsMono"; then
  curl -fLo "$FONT_DIR/JetBrainsMono.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
  unzip -n "$FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR"
  rm "$FONT_DIR/JetBrainsMono.zip"
  fc-cache -fv
  ok "JetBrains Nerd Font zainstalowany."
else
  ok "JetBrains Nerd Font już istnieje – pomijam."
fi

# ── 6. Katalog suckless ──────────────────────────────────────────────────────
info "Tworzenie katalogu $SUCKLESS_DIR..."
mkdir -p "$SUCKLESS_DIR"

# ── 7. Klonowanie i kompilacja suckless ──────────────────────────────────────
info "Klonowanie i kompilacja suckless (dwm, dmenu, st)..."
for repo in "${REPOS[@]}"; do
  NAME=$(awk '{print $1}' <<< "$repo")
  URL=$(awk '{print $2}'  <<< "$repo")
  TARGET="$SUCKLESS_DIR/$NAME"

  if [ ! -d "$TARGET" ]; then
    info "Klonowanie $NAME z $URL..."
    git clone "$URL" "$TARGET"
  else
    info "$NAME już istnieje – pomijam klonowanie."
  fi

  (
    cd "$TARGET"

    # Upewnij się, że gałąź main istnieje
    if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
      git checkout -b "$BRANCH_NAME"
    else
      git checkout "$BRANCH_NAME"
    fi

    # Pobierz ewentualne aktualizacje
    git pull --ff-only origin HEAD 2>/dev/null || true

    make
    sudo make install
    make clean
    ok "$NAME skompilowany i zainstalowany."
  )
done

# ── 8. Skrypt statusu DWM ────────────────────────────────────────────────────
info "Tworzenie skryptu statusu ~/.local/bin/dwm-status.sh..."
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/dwm-status.sh" <<'STATUS'
#!/bin/sh
# Status bar dla DWM
while true; do

  # Temperatura CPU
  TEMP_RAW=$(sensors 2>/dev/null | awk '/Package id 0:/ {print $4}' | tr -d '+°C')
  [ -z "$TEMP_RAW" ] && TEMP_RAW="N/A"
  TEMP=$(printf "%4s" "$TEMP_RAW")

  # CPU usage (2 próbki, 1s odstęp)
  read -r _cpu user1 nice1 sys1 idle1 iow1 irq1 sirq1 steal1 _rest < /proc/stat
  sleep 1
  read -r _cpu user2 nice2 sys2 idle2 iow2 irq2 sirq2 steal2 _rest < /proc/stat
  TOTAL1=$((user1+nice1+sys1+idle1+iow1+irq1+sirq1+steal1))
  TOTAL2=$((user2+nice2+sys2+idle2+iow2+irq2+sirq2+steal2))
  IDLE1=$((idle1+iow1))
  IDLE2=$((idle2+iow2))
  DIFF_TOTAL=$((TOTAL2-TOTAL1))
  DIFF_IDLE=$((IDLE2-IDLE1))
  if [ "$DIFF_TOTAL" -gt 0 ]; then
    CPU_RAW=$(( 100*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL ))
  else
    CPU_RAW=0
  fi
  CPU=$(printf "%3s" "$CPU_RAW")

  # RAM
  MEM_MB=$(free -m | awk '/Mem:/ {print $3}')
  if [ "$MEM_MB" -ge 1024 ]; then
    RAM_VAL=$(awk "BEGIN {printf \"%.1fG\", $MEM_MB/1024}")
  else
    RAM_VAL="${MEM_MB}M"
  fi
  RAM=$(printf "%5s" "$RAM_VAL")

  # Jasność
  BRIGHT_CUR=$(brightnessctl g 2>/dev/null)
  BRIGHT_MAX=$(brightnessctl m 2>/dev/null)
  if [ -n "$BRIGHT_CUR" ] && [ -n "$BRIGHT_MAX" ] && [ "$BRIGHT_MAX" -gt 0 ]; then
    BRIGHT="$((100*BRIGHT_CUR/BRIGHT_MAX))%"
  else
    BRIGHT="N/A"
  fi
  BRIGHT=$(printf "%4s" "$BRIGHT")

  # Głośność
  VOL=$(amixer get Master 2>/dev/null | awk -F'[][]' 'END{print $2}')
  [ -z "$VOL" ] && VOL="N/A"
  VOL=$(printf "%4s" "$VOL")

  # Bluetooth – timeout żeby nie blokował
  BT_NAME=$(timeout 2 bluetoothctl info 2>/dev/null | awk -F': ' '/Name/{print $2; exit}')
  [ -z "$BT_NAME" ] && BT_NAME="OFF"
  BT=$(printf "%-12s" "BT:${BT_NAME}")

  # Sieć
  IFACE=$(ip route 2>/dev/null | awk '/default/{print $5; exit}')
  [ -z "$IFACE" ] && IFACE="offline"
  NET=$(printf "%-10s" "$IFACE")

  # Bateria
  BAT=$(acpi -b 2>/dev/null | awk -F', ' '{print $2}')
  [ -z "$BAT" ] && BAT="N/A"
  BAT=$(printf "%4s" "$BAT")

  # Data/czas po polsku
  DATE=$(LC_TIME=pl_PL.UTF-8 date '+%a %d %b | %H:%M')

  xsetroot -name " TEMP ${TEMP}°C | CPU ${CPU}% | RAM ${RAM} | BRT ${BRIGHT} | VOL ${VOL} | ${BT}| NET ${NET}| BAT ${BAT} | ${DATE} "

  sleep 4
done
STATUS

chmod +x "$HOME/.local/bin/dwm-status.sh"
ok "Skrypt statusu utworzony."

# ── 9. .xinitrc ─────────────────────────────────────────────────────────────
info "Tworzenie ~/.xinitrc..."
XINITRC="$HOME/.xinitrc"

# Lokalizacja agenta polkit (różni się w zależności od dystrybucji)
if   [ -x /usr/libexec/polkit-gnome-authentication-agent-1 ]; then
  POLKIT_BIN="/usr/libexec/polkit-gnome-authentication-agent-1"
elif [ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
  POLKIT_BIN="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
else
  POLKIT_BIN=""
  warn "Nie znaleziono agenta polkit – zostanie pominięty w .xinitrc."
fi

cat > "$XINITRC" <<XINITRC_EOF
#!/bin/sh

# Wykryj główny monitor
MONITOR=\$(xrandr --query | awk '/ connected primary/{print \$1; exit}')
[ -z "\$MONITOR" ] && MONITOR=\$(xrandr --query | awk '/ connected/{print \$1; exit}')
[ -n "\$MONITOR" ] && xrandr --output "\$MONITOR" --auto

# Tapeta
feh --bg-scale "\$HOME/wallpaper.jpg" 2>/dev/null &

# Agent polkit
XINITRC_EOF

if [ -n "$POLKIT_BIN" ]; then
  echo "${POLKIT_BIN} &" >> "$XINITRC"
fi

cat >> "$XINITRC" <<'XINITRC_TAIL'

# Dodaj ~/.local/bin do PATH (na wypadek gdyby nie było)
export PATH="$HOME/.local/bin:$PATH"

# Pasek statusu
dwm-status.sh &

# Uruchom DWM
exec dwm
XINITRC_TAIL

chmod +x "$XINITRC"
ok ".xinitrc utworzony: $XINITRC"

# ── 10. dwm.desktop ──────────────────────────────────────────────────────────
info "Tworzenie /usr/share/xsessions/dwm.desktop..."
sudo mkdir -p /usr/share/xsessions
sudo tee /usr/share/xsessions/dwm.desktop > /dev/null <<'DESKTOP'
[Desktop Entry]
Name=DWM
Comment=Dynamic Window Manager
Exec=dwm
TryExec=dwm
Type=Application
DesktopNames=DWM
DESKTOP
ok "dwm.desktop utworzony w /usr/share/xsessions/"

# ── Weryfikacja ───────────────────────────────────────────────────────────────
echo ""
info "=== Weryfikacja instalacji ==="

check_file() {
  if [ -f "$1" ]; then
    ok "Plik istnieje:    $1"
  else
    warn "BRAK pliku:       $1"
  fi
}

check_exec() {
  if command -v "$1" &>/dev/null; then
    ok "Dostępny w PATH:  $1 → $(command -v "$1")"
  else
    warn "NIE znaleziono w PATH: $1"
  fi
}

check_file "$HOME/.xinitrc"
check_file "$HOME/.local/bin/dwm-status.sh"
check_file "/usr/share/xsessions/dwm.desktop"
check_file "$SUCKLESS_DIR/dwm/config.def.h"
check_file "$SUCKLESS_DIR/dmenu/config.def.h"
check_file "$SUCKLESS_DIR/st/config.def.h"
check_exec dwm
check_exec dmenu
check_exec st

echo ""
ok "=== INSTALACJA ZAKOŃCZONA ==="
echo ""
echo "  Repozytoria suckless → $SUCKLESS_DIR"
echo "  Startx:               startx  (lub zaloguj się przez DM i wybierz DWM)"
echo "  Tapeta:               ~/wallpaper.jpg  (dodaj własny plik)"
echo ""
