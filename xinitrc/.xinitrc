#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Make sure this is before the 'exec' command or it won't be sourced.
[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

# Loop
#while true; do
#             dwm >/dev/null 2>&1
#done

while type dwm >/dev/null ; do dwm && continue || break ;done

# DWM - run to konole "startx"
# Archlinux
# redshift -O3500; xset r rate 300 50; exec dwm

# Linux
# exec /usr/local/bin/slstatus &
exec dwm
