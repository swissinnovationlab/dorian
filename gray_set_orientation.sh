#/bin/bash

export DISPLAY=:0

MAIN_DISPLAY=$(xrandr -q | grep -i " connected" | cut -f1 -d" ")
MAIN_INPUT=$(xinput list | grep "ILITEK" | cut -f 2 -d$'\t' | cut -f 2 -d "=")

COORD_TF_MTX=

function set_tf_mtx () {
    case $1 in
        'inverted')
            COORD_TF_MTX="-1 0 1 0 -1 1 0 0 1"
            ;;
        'right')
            COORD_TF_MTX="0 1 0 -1 0 1 0 0 1"
            ;;
        'left')
            COORD_TF_MTX="0 -1 1 1 0 0 0 0 1"
            ;;
        'normal')
            COORD_TF_MTX="1 0 0 0 1 0 0 0 1"
            ;;
    esac
}

source ~/ui.env
if [ -z $ORIENTATION ]; then
    $ORIENTATION = normal
fi
set_tf_mtx $ORIENTATION

xrandr --output "$MAIN_DISPLAY" --auto --rotate "$ORIENTATION"
xinput set-prop "$MAIN_INPUT" --type=float "Coordinate Transformation Matrix" $COORD_TF_MTX

