import subprocess
from dataclasses import dataclass

from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook


# Wallpaper setup
@hook.subscribe.startup_once
def startup():
    subprocess.Popen(["swww-daemon"])


# Colors
@dataclass
class Colors:
    red: str = "#ff0000"
    white: str = "#ffffff"
    light_purple: str = "#d75fff"
    purple: str = "#8f3dfd"
    green: str = "#00a000"


alt = "mod1"
super = "mod4"

terminal = guess_terminal(["kitty",  "alacritty", "gnome-terminal"])

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([alt], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([alt], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([alt], "j", lazy.layout.down(), desc="Move focus to right"),
    Key([alt], "k", lazy.layout.up(), desc="Move focus up"),
    Key([alt], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [alt, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [alt, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([alt, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([alt, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([alt, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [alt, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([alt, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([alt, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([alt], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [alt, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([alt], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([alt], "e", lazy.spawn("nautilus"), desc="Launch File Manager"),
    # Toggle between different layouts as defined below
    Key([alt], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([alt], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [alt],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [alt],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key([alt, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([alt, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),

    # Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([super], "Alt_L", lazy.spawn("rofi -show drun"), desc="App launcher (rofi)"),

    Key([super], "space", lazy.widget["keyboardlayout"].next_keyboard(), desc="Switch keyboard layout"),
    Key([super], "f", lazy.spawn("rofi -show filebrowser"), desc="Browse files with rofi"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [alt],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [alt, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layout_theme_config = {
        "border_width": 2,
        "margin": 3,
        "border_focus": Colors.purple,
        "border_normal":Colors.white,
        }

layouts = [
    layout.Columns(**layout_theme_config),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)

extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.KeyboardLayout(
                    configured_keyboards=["us", "ru"]
                    ),
                widget.Sep(),
                widget.CurrentLayout(),
                widget.Sep(),
                widget.Prompt(),
                widget.WindowName(),

                widget.Spacer(),
                widget.TextBox(">"),
                widget.GroupBox(
                    rounded=True,
                    ),
                widget.TextBox("<"),
                widget.Spacer(),

                widget.StatusNotifier(),
                widget.SwayNC(),
                widget.Notify(),
                widget.Sep(),
                widget.Systray(
                    padding=10,
                    ),
                widget.Wlan(),
                widget.Sep(),
                widget.Bluetooth(),
                widget.Sep(),
                widget.Volume(
                    emoji=False,
                    fmt="Vol: {}",
                    ),
                widget.Sep(),
                widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
                widget.Sep(),
                widget.QuickExit(
                    default_text='[quit Qtile]', 
                    countdown_format='[{}]',
                )
                ,
            ],
            size=30,
            margin=[5, 5, 5, 5],
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["#ff00ff", "#000000", "#ff00ff", "#000000"]  # Borders are magenta
        ),
    ),
]

mousemods = [alt]

mouse = [
    Drag(
        [alt],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [alt],
        "Button3",
        lazy.window.set_size_floating(),
        start=lazy.window.get_size(),
    ),
    Click([alt], "Button1", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules: list = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # git commit
        Match(wm_class="makebranch"),  # git branches
        Match(wm_class="meld"),  # meld merge tool
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # git branch
        Match(title="pinentry"),  # gpg pinentry
        Match(wm_class="ig，草"),
    ]
)
auto_fullscreen = True
reconfigure_screens = True
wl_input_rules: dict = {}

# XXX: Gasp! We're lying to the user about what their keys do.
# We are using words (e.g. "Alt"), where we should be using the actual modifier key.
# variable definitions for X11/Wayland compatibility.
wmname = "Qtile"
