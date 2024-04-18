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

import datetime  # noqa: F401
import platform
import re
import subprocess

from libqtile import bar, hook, layout, widget
from libqtile.command import lazy
from libqtile.config import Drag, Group, Key, Match, Screen
from libqtile.log_utils import logger  # noqa: F401

try:
    from typing import List  # noqa: F401
except ImportError:
    pass

# Use HOST to determine computer-specific options, such as battery/wlan widgets
use_battery_widget = False
use_wlan_widget = False
use_large_fonts = False
wlan_int = "wlp2s0"
is_creative_machine = False
if platform.node() in ["WanderingMonk", "AmaNoUzume"]:
    is_creative_machine = True
if platform.node() in ["AmaNoUzume"]:
    wlan_int = "wlan0"
    use_wlan_widget = True
    use_battery_widget = True
if platform.node() in ["Bastet"]:
    wlan_int = "wlan0"
    use_wlan_widget = True
    use_large_fonts = True
if platform.node() in ["BelowTheArch"]:
    wlan_int = "wlan0"
    use_wlan_widget = True
if platform.node() == "some_other_laptop":
    wlan_int = "wlo1"
    use_wlan_widget = True

widget_size = 12
sys_icon_size = 20
arrow_size = 18
bar_size = 24
if use_large_fonts:
    widget_font = 20
    sys_icon_size = 30
    arrow_size = 30
    bar_size = 40


countdown_date = datetime.datetime(2021, 4, 29, 14, 30, 0)
countdown_text = "until immunity"

mod = "mod4"

raw_colors = {
    "black": "000000",
    "darkred": "220000",
    "red": "550000",
    "lightred": "ff6666",
    "green": "005500",
    "white": "ffffff",
    "yellow": "555500",
    "darkblue": "000022",
    "blue": "000055",
    "pink": "550055",
    "gray2": "222222",
    "gray3": "333333",
}

colors = {
    "bar-alt1": raw_colors["gray3"],
    "bar-alt2": raw_colors["gray2"],
    "bar-important": raw_colors["green"],
    "bar-center": raw_colors["darkblue"],
    "bar-updates": raw_colors["lightred"],
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
    # Key([mod, "shift"], "Return", lazy.layout.toggle_split()),
    Key([mod], "Return", lazy.spawn("uxterm -e 'tmux -2'")),
    Key([mod], "x", lazy.spawn("firefox")),
    # Key([mod], "l", lazy.spawn("light-locker-command -l")),
    Key([], "Print", lazy.spawn("flameshot gui")),
    # Change/modify layouts
    Key([mod], "grave", lazy.next_layout()),
    Key([mod, "control"], "Left", lazy.layout.grow_left()),
    Key([mod, "control"], "Right", lazy.layout.grow_right()),
    Key([mod, "control"], "Up", lazy.layout.grow_up()),
    Key([mod, "control"], "Down", lazy.layout.grow_down()),
    # Modify current window
    Key([mod], "q", lazy.window.kill()),
    Key([mod, "control"], "f", lazy.window.toggle_fullscreen()),
    Key([mod, "control"], "Tab", lazy.window.toggle_floating()),
    Key([mod, "control"], "g", lazy.window.toggle_maximize()),
    # Qtile system commands
    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "space", lazy.spawncmd()),
    # Audio control
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    ),
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
    ),
    # Media control
    # Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    # Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
    # Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    # Brightness control
    Key([], "XF86MonBrightnessDown", lazy.spawn("sudo xbacklight -set 1")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("sudo xbacklight -set 100")),
    # Quick-pause for games
    Key([mod, "control"], "m", lazy.spawn("/home/ibb/bin/toggle-game-pause")),
]

groups = [
    Group("a", label="a "),  # Internet
    Group("s", label="s "),  # Slack
    Group("d", label="d "),  # Terminal
    Group("f", label="f "),  # Games
    Group("g", label="g "),  # Internet
    Group("h", label="h "),  # Misc
    Group("j", label="j ", matches=[Match(wm_class="zoom")]),  # Zoom
    Group("k", label="k "),  # Misc
    Group("l", label="l "),  # Misc
]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key([mod], i.name, lazy.group[i.name].toscreen()),
            # mod1 + shift + letter of group =
            #  switch to & move focused window to group
            Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
        ]
    )

layouts = [
    layout.Max(border_width=0),
    layout.Bsp(border_width=0),
    layout.Floating(border_width=2),
]

widget_defaults = dict(
    font="sans",
    fontsize=widget_size,
    padding=3,
)
extension_defaults = widget_defaults.copy()


class CustomVolume(widget.PulseVolume):
    def _update_drawer(self):
        """The main Volume doesn't include a way to show both emoji and text,
        for some insane reason."""
        text = ""

        if self.volume <= 0:
            text = "\U0001f507"
        elif self.volume <= 30:
            text = "\U0001f508"
        elif self.volume < 80:
            text = "\U0001f509"
        elif self.volume >= 80:
            text = "\U0001f50a"

        if self.volume == -1:
            text += " M"
        else:
            text += " {}%".format(self.volume)

        self.text = text


widget_settings = dict(
    groupbox=dict(klass=widget.GroupBox),
    prompt=dict(klass=widget.Prompt, settings=dict(background=colors["bar-important"])),
    windowname=dict(
        klass=widget.TaskList,
        settings=dict(
            background=colors["bar-center"],
            mouse_callbacks={"Button2": lazy.window.kill()},
        ),
    ),
    countdown=dict(
        klass=widget.Countdown,
        settings=dict(
            background=colors["bar-center"],
            date=countdown_date,
            update_interval=60,
            format="{D}d {H}h {M}m " + countdown_text,
        ),
    ),
    updates=dict(
        klass=widget.CheckUpdates,
        settings=dict(
            background=colors["bar-important"],
            colour_have_updates=colors["bar-updates"],
        ),
    ),
    systray=dict(klass=widget.Systray, settings=dict(icon_size=sys_icon_size)),
    clock=dict(klass=widget.Clock, settings=dict(format="%Y-%m-%d %a %H:%M")),
    volume=dict(
        klass=CustomVolume,
        settings=dict(
            emoji=True,
            mouse_callbacks={"Button1": lazy.spawn("pavucontrol")},
        ),
    ),
    battery=dict(
        klass=widget.Battery,
        settings=dict(
            charge_char="^",
            discharge_char="v",
            hide_threshold=0.999,
            format=" {char} {percent:2.0%} {hour:d}:{min:02d}",
            update_interval=5,
        ),
    ),
    wifi=dict(
        klass=widget.Wlan,
        settings=dict(interface=wlan_int, format="Wifi: {essid} {quality}/70"),
    ),
    layout=dict(klass=widget.CurrentLayout),
)

screen_1_widgets = [
    [
        "layout",
        "groupbox",
        "prompt",
    ],
    [
        "windowname",
        # "countdown",
    ],
    [
        "updates",
        "systray",
        "clock",
        "volume",
    ],
]
if use_wlan_widget:
    screen_1_widgets[2].append("wifi")
if use_battery_widget:
    screen_1_widgets[2].append("battery")
screen_2_widgets = [list(screen_1_widgets[i]) for i in range(3)]
screen_2_widgets[2].remove("systray")
screen_3_widgets = [list(screen_2_widgets[i]) for i in range(3)]
screen_4_widgets = [list(screen_3_widgets[i]) for i in range(3)]


def build_arrow(widgets, char, foreground, background):
    widgets.append(
        widget.TextBox(
            background=background,
            foreground=foreground,
            fontsize=arrow_size,
            text=char,
            padding=0,
        )
    )


def build_screen_widgets(widget_keys):
    all_widget_keys = [k for g in widget_keys for k in g]
    widget_colors = []
    for i, key in enumerate(all_widget_keys):
        ws = widget_settings[key]
        if "settings" in ws and "background" in ws["settings"]:
            widget_colors.append(ws["settings"]["background"])
        elif i % 2:
            widget_colors.append(colors["bar-alt2"])
        else:
            widget_colors.append(colors["bar-alt1"])

    widgets = []
    for i, key in enumerate(all_widget_keys):
        ws = widget_settings[key]
        settings = dict(background=colors[f"bar-{'alt2' if i % 2 else 'alt1'}"])
        if "settings" in ws:
            settings.update(ws["settings"])
        bg = settings["background"]

        if key in widget_keys[2]:
            fg = raw_colors["black"]
            if i > 0:
                fg = widget_colors[i - 1]
            build_arrow(widgets, "\uE0B2", bg, fg)

        widgets.append(ws["klass"](**settings))

        if key in widget_keys[0]:
            fg = raw_colors["black"]
            if i < len(widget_colors) - 1:
                fg = widget_colors[i + 1]
            build_arrow(widgets, "\uE0B0", bg, fg)

    return widgets


screens = [
    Screen(top=bar.Bar(build_screen_widgets(screen_1_widgets), bar_size)),
    Screen(top=bar.Bar(build_screen_widgets(screen_2_widgets), bar_size)),
    Screen(top=bar.Bar(build_screen_widgets(screen_3_widgets), bar_size)),
    Screen(top=bar.Bar(build_screen_widgets(screen_4_widgets), bar_size)),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod],
        "Button3",
        lazy.window.set_size_floating(),
        start=lazy.window.get_size(),
    ),
    # Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        Match(wm_class="confirm"),
        Match(wm_class="dialog"),
        Match(wm_class="download"),
        Match(wm_class="error"),
        Match(wm_class="file_progress"),
        Match(wm_class="notification"),
        Match(wm_class="splash"),
        Match(wm_class="toolbar"),
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        # My games/apps
        Match(wm_class="fungal-pirates.py"),
        Match(title="pygame window"),
        # For some reason, Kivy apps start without a name.
        # For now, use the class, which probably isn't unique.
        Match(wm_class="python"),
        Match(wm_class="openmw-launcher"),  # Morrowind
        Match(wm_class="pavucontrol"),  # Audio controls
        # Match(wm_class="steam"),  # All Steam windows
        # Zoom "you're using audio!" window
        # This isn't perfect, as it still floats the main zoom window, but at
        # least the meeting window isn't floated
        Match(wm_class="zoom", title=re.compile(r"^zoom$")),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"


if platform.node() == "BelowTheArch":

    @hook.subscribe.startup_once
    def autostart():
        subprocess.Popen("kodi")

elif platform.node() == "Osiris":

    @hook.subscribe.startup_once
    def autostart():
        subprocess.Popen(["firefox", "localhost:8096"])


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
