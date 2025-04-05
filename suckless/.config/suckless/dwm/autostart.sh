#!/bin/bash

function run {
 if ! pgrep $1 ;
  then
    $@&
  fi
}

run "xrandr --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal"
run nitrogen --restore &
run picom -b  --config ~/.config/suckless/dwm/picom.conf &
run dunst &
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & # OpenSuse authentication
run sxhkd -c ~/.config/suckless/sxhkd/sxhkdrc &
run numlockx on &
run xrdb ~/.Xresources &
run nm-applet &
run parcellite -n & # Ctrl+Alt+s run history clipboard
# run udiskie &
# run blueman-applet &
# run feh --bg-fill $HOME/.bg &
# run ~/.config/suckless/scripts/rclone.sh &
# run /usr/lib/xfce4/notifyd/xfce4-notifyd &


# Display
#run $HOME/.screenlayout/1.sh
#run "xrandr --output Virtual-1 --mode 1920x1080 --pos 0x0 --rotate normal"
#run "xrandr --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal"
#run "xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal"
#run "xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off"
#run xrandr --output eDP-1 --primary --mode 1368x768 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output HDMI-2 --off
#run xrandr --output LVDS1 --mode 1366x768 --output DP3 --mode 1920x1080 --right-of LVDS1
#run xrandr --output DVI-I-0 --right-of HDMI-0 --auto
#run xrandr --output DVI-1 --right-of DVI-0 --auto
#run xrandr --output DVI-D-1 --right-of DVI-I-1 --auto
#run xrandr --output HDMI2 --right-of HDMI1 --auto
#autorandr horizontal

# Sysyem
#run setxkbmap pl &
#run /usr/lib/xfce4/notifyd/xfce4-notifyd & Arch
#run "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1" & # Archlinux authentication

# App
#run "dex $HOME/.config/autostart/arcolinux-welcome-app.desktop"
#feh --bg-fill $HOME/.config/dwm/bg/sea.jpg &
#run "pamac-tray" &
#run "variety" &
#run "xfce4-power-manager" &
#run "blueberry-tray" &
#run "volumeicon" &
#run "nitrogen --restore" &
