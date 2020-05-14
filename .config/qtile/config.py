# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.command import lazy
from libqtile import layout, bar, widget
import copy
import os

try:
    from typing import List  # noqa: F401
except ImportError:
    pass

# Use HOST to determine computer-specific options, such as battery/wlan widgets
is_a_laptop = False
if os.getenv("HOST","default") in ["WanderingMonk"]:
    is_a_laptop = True
wlan_int = 'wlp2s0'
if os.getenv("HOST","default") == "some_other_laptop":
    wlan_int = "wlo1"


mod = "mod4"

colors = {
    "black": "000000",
    "darkred": "220000",
    "red": "550000",
    "green": "005500",
    "white": "ffffff",
    "yellow": "555500",
    "darkblue": "000022",
    "blue": "000055",
    "pink": "550055",
    "gray1": "222222",
    "gray2": "333333",
}

keys = [
    # Move windows up or down in current stack
    Key([mod, "control"], "k", lazy.layout.shuffle_down()),
    Key([mod, "control"], "j", lazy.layout.shuffle_up()),

    # Switch window focus to other pane(s) of stack
    Key([mod], "Tab", lazy.layout.next()),

    # Swap panes of split stack
    Key([mod, "shift"], "Tab", lazy.layout.rotate()),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    #Key([mod, "shift"], "Return", lazy.layout.toggle_split()),
    Key([mod], "Return", lazy.spawn("uxterm -e 'tmux -2'")),
    Key([mod], "x", lazy.spawn("chromium")),
    Key([mod], "l", lazy.spawn("light-locker-command -l")),
    Key([], "Print", lazy.spawn("flameshot gui")),

    # Toggle between different layouts as defined below
    Key([mod], "grave", lazy.next_layout()),
    Key([mod], "q", lazy.window.kill()),
    Key([mod, "control"], "f", lazy.window.toggle_fullscreen()),

    Key([mod, "control"], "Tab", lazy.window.toggle_floating()),
    Key([mod, "control"], "Left", lazy.layout.increase_ratio()),
    Key([mod, "control"], "Right", lazy.layout.decrease_ratio()),

    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "space", lazy.spawncmd()),

    # Audio control
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),

    # Brightness control
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -set 0.5")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -set 100")),
]

groups = [Group(i) for i in "asdfuiop"]
groups[0].label = "a "
groups[1].label = "s "
groups[7].label = "p "

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen()),

        # mod1 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
    ])

layouts = [
    layout.Max(),
    layout.Tile(),
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

def build_screen_widgets():
    raw_widgets = [
        widget.GroupBox(background=colors["gray1"]),
        widget.Prompt(background=colors["green"]),
        widget.WindowName(background=colors["darkblue"]),
        widget.CheckUpdates(background=colors["gray1"],colour_have_updates='ff6666',colour_no_updates='444444',execute='notify-send "Updates available" "`checkupdates`" -t 0'),
        widget.Systray(background=colors["gray2"]),
        widget.Clock(background=colors["gray1"],format='%Y-%m-%d %a %H:%M'),
        widget.Volume(background=colors["gray2"]),
        widget.CurrentLayout(background=colors["gray1"]),
    ]
    left_end = 1
    right_start = 3
    prefix_symbols = {
        6: "",
        7: "",
    }

    if is_a_laptop:
        raw_widgets.append(widget.BatteryIcon(padding=0))
        raw_widgets.append(widget.Battery(padding=0,charge_char='^',discharge_char='v',format='{percent:2.0%} {char}'))
        raw_widgets.append(widget.Wlan(interface=wlan_int,format='Wifi: {essid} {quality}/70'))

    widgets = []
    for i, widg in enumerate(raw_widgets):
        if i >= right_start:
            widgets.append(widget.TextBox(
                background=raw_widgets[i-1].background,
                foreground=widg.background,
                fontsize=18,
                text=u"\uE0B2",
                padding=0,
            ))
        if i in prefix_symbols:
            widgets.append(widget.TextBox(background=widg.background,text=prefix_symbols[i]))
        widgets.append(widg)
        if i <= left_end:
            widgets.append(widget.TextBox(
                background=raw_widgets[i+1].background,
                foreground=widg.background,
                fontsize=18,
                text=u"\uE0B0",
                padding=0,
            ))

    return widgets

screens = [
    Screen(top=bar.Bar(build_screen_widgets(),24)),
    Screen(top=bar.Bar(build_screen_widgets(),24)),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button2", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    #Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    {'wmclass': 'confirm'},
    {'wmclass': 'dialog'},
    {'wmclass': 'download'},
    {'wmclass': 'error'},
    {'wmclass': 'file_progress'},
    {'wmclass': 'notification'},
    {'wmclass': 'splash'},
    {'wmclass': 'toolbar'},
    {'wmclass': 'confirmreset'},  # gitk
    {'wmclass': 'makebranch'},  # gitk
    {'wmclass': 'maketag'},  # gitk
    {'wname': 'branchdialog'},  # gitk
    {'wname': 'pinentry'},  # GPG key password entry
    {'wmclass': 'ssh-askpass'},  # ssh-askpass

    # My games/apps
    {'wmclass': 'fungal-pirates.py'},
    {'wname': 'pygame window'},
    # For some reason, Kivy apps start without a name.
    # For now, use the class, which probably isn't unique.
    {'wmclass': 'python'},

    {'wmclass': 'openmw-launcher'}, # Morrowind
    {'wmclass': 'pavucontrol'}, # Audio controls
    {'wmclass': 'steam'}, # All Steam windows
])
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
