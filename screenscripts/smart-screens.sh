#!/bin/zsh

cnt=`xrandr | grep " connected " | wc -l`
if [ "$cnt" -eq "1" ]; then
  exec /opt/monoscreen.sh
else
  exec /opt/multiscreen.sh
fi
