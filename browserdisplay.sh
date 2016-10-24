#!/bin/bash
# browserdisplay.sh
# Leon Steenkamp - 2016-08-30
# Needs xte for simulated key presses.

PAGE="http://127.0.0.1/some/page"
DISPLAY=":0"

echo Starting epiphany
date
#epiphany --display=$DISPLAY $PAGE &> /dev/null &
chromium-browser --display=$DISPLAY $PAGE &> /dev/null &

#Give the browser time to start up before going on
sleep 10s

echo Going fullscreen
echo key F11 | xte -x$DISPLAY

while true; do
        sleep 10m
        echo Refreshing
        date
        echo key F5 | xte -x$DISPLAY
done

#kill $(ps aux | grep epiphany | awk '{print $2}')
#kill $(ps aux | grep chromium-browser | awk '{print $2}')
