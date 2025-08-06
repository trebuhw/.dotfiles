#!/bin/bash

# Archlinux - Konserwacja systemu

# Sprawdź usługi systemd, które nie działają
systemctl --failed

# Sprawdź dzienniki systemowe (tylko krytyczne błędy)
sudo journalctl -p 3 -xb

# Aktualizuj system
sudo pacman -Syu

# Aktualizuj pakiety przez yay
yay

# Usuń pamięć podręczną Pacman (częściowo)
sudo pacman -Sc

# Usuń pamięć podręczną Yay (częściowo)
yay -Sc

# Usuń pamięć podręczną Pacman (całkowicie)
sudo pacman -Scc

# Usuń pamięć podręczną Yay (całkowicie)
yay -Scc

# Usuń niepotrzebne zależności
yay -Yc

# Sprawdź osierocone pakiety
pacman -Qtdq

# Usuń osierocone pakiety
sudo pacman -Rns $(pacman -Qtdq)

# Wyczyść pamięć podręczną w katalogu użytkownika
rm -rf ~/.cache/*

# Wyczyść dzienniki systemowe starsze niż 2 tygodnie
sudo journalctl --vacuum-time=2weeks
