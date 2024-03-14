xrandr > /dev/null
xrandr --output HDMI1 --auto
xset -dpms
xset s off
unclutter --timeout 0.01 --hide-on-touch --ignore-buttons 4,5,6,7 --start-hidden --fork
exec i3
