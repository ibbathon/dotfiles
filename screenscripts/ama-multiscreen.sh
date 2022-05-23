#!/bin/sh

xrandr --output HDMI-1 --mode 1920x1080 --rate 74.97 --right-of eDP-1 --rotate normal
xrandr --output DP-1-2 --mode 1920x1080 --rate 74.97 --right-of HDMI-1 --rotate normal
xrandr --output DP-1-3 --mode 1920x1080 --rate 74.97 --above DP-1-2 --rotate left
