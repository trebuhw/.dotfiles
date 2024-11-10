#!/usr/bin/env sh

# Terminate already running bar instances
killall -q waybar

# Wait until the processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

CONFIG="$HOME/.config/waybar/config-hypr"
STYLE="$HOME/.config/waybar/style.css"

if [[ ! $(pidof waybar) ]]; then
	waybar --bar main-bar --log-level error --config ${CONFIG} --style ${STYLE}
fi

# Launch main
#waybar -c ~/.config/hypr/scripts/waybar.sh

