#!/bin/bash

cd ~/cachyos

# Wykonanie skryptów
echo "Uruchamianie skryptów..."
sh 1.dotfiles.sh
sh 2.app.sh
# sh 3.cp-file.sh
# sh 4.mount-arch-cp-file.sh
sh 5.ln-root.sh
# sh 6.virt.sh
# sh 7.print.sh
sh 8.set-theme.sh
sh 9.set-config.sh

echo "Skrypty zostały uruchomione."
