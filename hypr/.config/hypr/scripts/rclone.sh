#!/bin/sh

echo "Starting rclone"
rclone --vfs-cache-mode writes mount gdrive: ~/Cloud/GDrive &
rclone --vfs-cache-mode writes mount onedrive: ~/Cloud/OneDrive &
rclone --vfs-cache-mode writes mount pcloud: ~/Cloud/PCloud &

exit 0
