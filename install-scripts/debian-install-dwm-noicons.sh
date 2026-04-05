#!/bin/bash
set -e

BRANCH_NAME="main"
REPOS=(
  "dwm https://git.suckless.org/dwm"
  "dmenu https://git.suckless.org/dmenu"
  "st https://git.suckless.org/st"
)

echo "=== Aktualizacja systemu ==="
sudo apt update
sudo apt upgrade -y

echo "=== Instalacja pakietów (bez recommends) ==="
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
  policykit-1-gnome \
  curl unzip

sudo systemctl enable NetworkManager
xdg-user-dirs-update

echo "=== Instalacja JetBrains Nerd Font ==="
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip -o JetBrainsMono.zip
rm JetBrainsMono.zip
fc-cache -fv
cd ~

for repo in "${REPOS[@]}"; do
  NAME=$(echo $repo | awk '{print $1}')
  URL=$(echo $repo | awk '{print $2}')
  [ ! -d "$NAME" ] && git clone "$URL"
  cd "$NAME"
  if ! git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
    git checkout -b $BRANCH_NAME
  else
    git checkout $BRANCH_NAME
  fi
  sudo make clean install
  cd ..
done

mkdir -p ~/.local/bin

# Skrypt statusu z literami
cat <<'EOF' >~/.local/bin/dwm-status.sh
#!/bin/sh
while true; do
TEMP_RAW=$(sensors 2>/dev/null | awk '/Package id 0:/ {print $4}' | tr -d '+°C')
[ -z "$TEMP_RAW" ] && TEMP_RAW=0
TEMP=$(printf "%3s" "$TEMP_RAW")
read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
TOTAL=$((user+nice+system+idle+iowait+irq+softirq+steal))
IDLE=$((idle+iowait))
sleep 1
read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
TOTAL2=$((user+nice+system+idle+iowait+irq+softirq+steal))
IDLE2=$((idle+iowait))
DIFF_TOTAL=$((TOTAL2-TOTAL))
DIFF_IDLE=$((IDLE2-IDLE))
CPU_RAW=$(( (100*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL) ))
CPU=$(printf "%3s" "$CPU_RAW")
MEM_MB=$(free -m | awk '/Mem:/ {print $3}')
if [ "$MEM_MB" -ge 1024 ]; then
RAM_VAL=$(awk "BEGIN {printf \"%.1fG\", $MEM_MB/1024}")
else
RAM_VAL="${MEM_MB}M"
fi
RAM=$(printf "%5s" "$RAM_VAL")
BRIGHT=$(brightnessctl g 2>/dev/null)
MAXBRIGHT=$(brightnessctl m 2>/dev/null)
[ -n "$BRIGHT" ] && BRIGHT="$((100*BRIGHT/MAXBRIGHT))%"
BRIGHT=$(printf "%3s" "$BRIGHT")
VOL=$(amixer get Master | awk -F'[][]' 'END{ print $2 }')
VOL=$(printf "%3s" "$VOL")
BT_NAME=$(bluetoothctl info | awk -F': ' '/Name/ {print $2}' | head -n1)
[ -z "$BT_NAME" ] && BT_NAME="OFF"
BT=$(printf "%-12s" "BT:${BT_NAME}")
IFACE=$(ip route | awk '/default/ {print $5; exit}')
[ -z "$IFACE" ] && NET="offline" || NET="$IFACE"
NET=$(printf "%-10s" "$NET")
BAT=$(acpi -b 2>/dev/null | awk -F', ' '{print $2}')
[ -z "$BAT" ] && BAT="N/A"
BAT=$(printf "%4s" "$BAT")
DATE=$(LC_TIME=pl_PL.UTF-8 date '+%a %d %b | %H:%M')
xsetroot -name " TEMP ${TEMP}°C | CPU ${CPU}% | RAM ${RAM} | BRIGHT ${BRIGHT} | VOL ${VOL} | BT ${BT} | NET ${NET} | BAT ${BAT} | ${DATE} "
sleep 4
done
EOF

chmod +x ~/.local/bin/dwm-status.sh

# .xinitrc
cat <<EOF >~/.xinitrc
#!/bin/sh
MONITOR=\$(xrandr --query | awk '/ connected primary/ {print \$1; exit}')
[ -z "\$MONITOR" ] && MONITOR=\$(xrandr --query | awk '/ connected/ {print \$1; exit}')
xrandr --output "\$MONITOR" --auto
feh --bg-scale ~/wallpaper.jpg 2>/dev/null &
if [ -x /usr/lib/polkit-1-gnome/polkit-gnome-authentication-agent-1 ]; then
  /usr/lib/polkit-1-gnome/polkit-gnome-authentication-agent-1 &
fi
~/.local/bin/dwm-status.sh &
exec dwm
EOF

chmod +x ~/.xinitrc

# Plik dwm.desktop globalnie
echo "=== Tworzenie pliku dwm.desktop globalnie ==="
sudo tee /usr/share/xsessions/dwm.desktop >/dev/null <<EOF
[Desktop Entry]
Name=DWM
Comment=Dynamic Window Manager
Exec=startx ~/.xinitrc
TryExec=dwm
Type=Application
EOF

# Globalne no-recommends
echo "=== Włączanie globalnego no-install-recommends ==="
sudo tee /etc/apt/apt.conf.d/99norecommends >/dev/null <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

echo "=== GOTOWE – wersja z literami ==="
