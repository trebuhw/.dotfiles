#!/bin/sh

echo "Starting rclone"
#rclone --vfs-cache-mode writes mount gdrive: ~/Cloud/GDrive &
#rclone --vfs-cache-mode writes mount onedrive: ~/Cloud/OneDrive &
rclone --vfs-cache-mode writes mount pcloud: ~/Cloud/PCloud &
# rclone --vfs-cache-mode writes mount proton: ~/Cloud/ProtonDrive &

exit 0
