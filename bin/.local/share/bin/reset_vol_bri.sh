#!/usr/bin/bash

# do działania poptrzebne
# sudo pacman -S alsa-utils

amixer sset 'Master' 50% &
brightnessctl set 30%
