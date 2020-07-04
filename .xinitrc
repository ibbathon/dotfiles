source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh
/usr/lib/notification-daemon-1.0/notification-daemon &

# Set colors and settings for terminals
xrdb -merge ~/.Xresources

# tray apps
udiskie --tray &
(sleep 2; nextcloud) &

# disable screensaver
xset dpms 0 0 0
xset s off

# screenshots
flameshot &

# enable keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

# enable audio
(sleep 2; pulseaudio) &

# disable touchpad screen
xrandr --output HDMI1 --off

# change caps lock to compose key (c`e to type accented e)
setxkbmap -option compose:caps

# Bluetooth support
blueman-applet &

feh --bg-max ~/wallpaper/default

qtile
