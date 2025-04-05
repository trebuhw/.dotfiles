#!/bin/sh

echo "Starting rclone"
rclone --vfs-cache-mode writes mount gdrive: ~/Cloud/GDrive &
rclone --vfs-cache-mode writes mount onedrive: ~/Cloud/OneDrive &

exit 0
