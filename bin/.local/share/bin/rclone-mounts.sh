#!/bin/sh

### CONFIG #####################################################

BASE="$HOME/Cloud"
CACHE="$HOME/.cache/rclone"

# maksymalny czas czekania na sieć (sekundy)
MAX_WAIT=30

# wspólne flagi rclone (wydajność + cache)
RCLONE_FLAGS="
--cache-dir $CACHE
--vfs-cache-mode full
--vfs-cache-max-size 20G
--vfs-cache-max-age 48h
--dir-cache-time 24h
--attr-timeout 1h
--vfs-read-chunk-size 32M
--vfs-read-chunk-size-limit 1G
--transfers 8
--checkers 16
--buffer-size 64M
--poll-interval 1m
--daemon
"

################################################################

echo "Waiting for network..."

WAIT=0
until ping -c1 1.1.1.1 >/dev/null 2>&1; do
  sleep 1
  WAIT=$((WAIT + 1))
  [ "$WAIT" -ge "$MAX_WAIT" ] && break
done

mkdir -p "$CACHE"

echo "Checking existing rclone mounts..."

unmount_if_mounted() {
  MOUNTPOINT="$1"

  if mountpoint -q "$MOUNTPOINT" 2>/dev/null; then
    echo "Unmounting $MOUNTPOINT"

    if command -v fusermount3 >/dev/null 2>&1; then
      fusermount3 -u "$MOUNTPOINT"
    else
      fusermount -u "$MOUNTPOINT"
    fi
  fi
}

kill_existing_rclone() {
  pkill -f "rclone mount" 2>/dev/null
}

# ---------- STOP OLD MOUNTS ----------
kill_existing_rclone

# ---------- Google Drive ----------
#mkdir -p "$BASE/GDrive"
#unmount_if_mounted "$BASE/GDrive"
#rclone mount gdrive: "$BASE/GDrive" $RCLONE_FLAGS &

# ---------- OneDrive ----------
#mkdir -p "$BASE/OneDrive"
#unmount_if_mounted "$BASE/OneDrive"
#rclone mount onedrive: "$BASE/OneDrive" $RCLONE_FLAGS &

# ---------- pCloud ----------
mkdir -p "$BASE/PCloud"
unmount_if_mounted "$BASE/PCloud"
rclone mount pcloud: "$BASE/PCloud" $RCLONE_FLAGS &

# ---------- Proton Drive ----------
#mkdir -p "$BASE/ProtonDrive"
#unmount_if_mounted "$BASE/ProtonDrive"
#rclone mount proton: "$BASE/ProtonDrive" $RCLONE_FLAGS &

exit 0

