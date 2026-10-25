# i3wm_config — Catppuccin Mocha i3 rice for Ubuntu

My i3 setup on Ubuntu 24.04 (Lenovo Legion S7 15ACH6, AMD iGPU + NVIDIA dGPU).
Everything is themed **Catppuccin Mocha** with **sharp corners**.

This README is a full, start-to-finish tutorial. Follow it top to bottom on a fresh
machine and you should end up with the same desktop, without hitting the problems
I hit the first time (they are all collected in [Troubleshooting](#13-troubleshooting--lessons-learned)).

| Part | Tool |
|---|---|
| Window manager | i3 |
| Compositor (shadows, transparency, blur) | picom |
| Bar | polybar |
| App launcher / window switcher | rofi (custom "edge" sidebar theme) |
| Notifications | dunst |
| Popups: calendar, volume/brightness OSD, dashboard, power menu | eww (built from source) |
| Desktop widgets on the wallpaper: clock, system stats, calendar, music + visualizer | eww + cava |
| "Show-off" terminal workspace: clock + weather, fastfetch, btop, now playing + cover, visualizer | kitty + i3 layout (`Alt+Shift+i`) |
| Shell prompt | bash `PS1` (Mocha colors, git branch) |
| Terminal | kitty |
| File manager (terminal) | yazi |
| Screenshots | flameshot |
| Monitor layouts | autorandr |
| Lock screen | i3lock + xss-lock (blurred wallpaper) |
| Wi-Fi TUI | nmtui (themed through newt colors) |
| GTK apps | Yaru-magenta-dark + Mocha color overrides |

---

## Table of contents

1. [How this repo works (bare git repo)](#1-how-this-repo-works-bare-git-repo)
2. [Install packages](#2-install-packages)
3. [Permissions (brightness keys)](#3-permissions-brightness-keys)
4. [Fonts](#4-fonts)
5. [Clone the dotfiles onto the new machine](#5-clone-the-dotfiles-onto-the-new-machine)
6. [Build and install eww](#6-build-and-install-eww)
7. [Things that are NOT in git (run once)](#7-things-that-are-not-in-git-run-once)
8. [Machine-specific values you must check](#8-machine-specific-values-you-must-check)
9. [First login and checking everything works](#9-first-login-and-checking-everything-works)
10. [Desktop widgets and the show-off workspace](#10-desktop-widgets-and-the-show-off-workspace)
11. [Shell: prompt, cursor, hostname](#11-shell-prompt-cursor-hostname)
12. [Keybindings and where they are configured](#12-keybindings-and-where-they-are-configured)
13. [Troubleshooting / lessons learned](#13-troubleshooting--lessons-learned)
14. [File map](#14-file-map)
15. [Color palette](#15-color-palette)
16. [Day-to-day: saving changes to this repo](#16-day-to-day-saving-changes-to-this-repo)

---

## 1. How this repo works (bare git repo)

The repo is a **bare git repository** stored in `~/.dotfiles`, and its *work tree* is
your whole home folder `$HOME`. Files stay exactly where programs expect them
(`~/.config/i3/config`, …) — no symlinks, no stow.

Because `$HOME` is full of other files, untracked files are hidden
(`status.showUntrackedFiles no`). That means **new files must be added explicitly**
with `dot add <file>`, otherwise they are silently not saved.

Everything is driven through one alias (already defined in `~/.bash_aliases`):

```bash
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

`dot status`, `dot add`, `dot commit`, `dot push` work like normal `git`.

This README lives in `~/.github/README.md` (GitHub shows it on the repo page, and it
keeps `~` clean).

---

## 2. Install packages

Tested on **Ubuntu 24.04 LTS**. Install everything in one go:

```bash
sudo apt update
sudo apt install -y \
  i3 i3lock xss-lock dex \
  polybar rofi dunst picom feh \
  kitty flameshot autorandr \
  brightnessctl playerctl pavucontrol pulseaudio-utils cava \
  blueman network-manager-gnome \
  libnotify-bin imagemagick x11-utils x11-xserver-utils xinput \
  git curl unzip fontconfig fonts-dejavu btop fastfetch toilet \
  yaru-theme-gtk yaru-theme-icon gnome-themes-extra \
  build-essential pkg-config libgtk-3-dev libdbusmenu-gtk3-dev
```

What each group is for:

| Packages | Why |
|---|---|
| `i3 i3lock xss-lock dex` | window manager, lock screen, lock-on-suspend, XDG autostart |
| `polybar rofi dunst picom feh` | bar, launcher, notifications, compositor, wallpaper |
| `kitty flameshot autorandr` | terminal, screenshots, monitor profiles |
| `brightnessctl playerctl pavucontrol pulseaudio-utils` | brightness keys, media keys, volume GUI, `pactl` |
| `blueman network-manager-gnome` | bluetooth + wifi tray icons (`nm-applet`) |
| `libnotify-bin` | `notify-send` (used by scripts) |
| `imagemagick x11-utils x11-xserver-utils xinput` | lock-screen blur (`convert`), `xdpyinfo`/`xwininfo`, `xrandr`, touchpad settings |
| `yaru-theme-* gnome-themes-extra` | GTK theme and icons (usually already installed on Ubuntu) |
| `build-essential pkg-config libgtk-3-dev libdbusmenu-gtk3-dev` | **only needed to build eww** (step 6) |

yazi is not in apt on 24.04 — install it as a snap:

```bash
sudo snap install yazi --classic
```

> Note: with the snap, yazi's helper tool is called **`yazi.ya`**, not `ya`.

Rust (only to build eww; installs into `~/.cargo`, does not touch your shell files):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
```

---

## 3. Permissions (brightness keys)

The brightness keys run `brightnessctl`. Writing brightness requires the **`video`**
group, and a fresh user is usually not in it — the keys then silently do nothing
(`Can't modify brightness: Permission denied`).

```bash
sudo usermod -aG video "$USER"
```

**Log out and back in** (or reboot). Group changes only apply to new sessions.
Check with `groups` — it must list `video`.

---

## 4. Fonts

| Font | Used for |
|---|---|
| **DejaVu Sans Mono** (`fonts-dejavu`) | all *text*: i3 titles, polybar, rofi, dunst, eww, kitty |
| **JetBrainsMono Nerd Font** | only the *icons* (polybar, eww, yazi) |

I tried JetBrainsMono for text too, but its spacing was harder to read, so it is only
the icon fallback.

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
curl -fL -o /tmp/JetBrainsMono.tar.xz \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xJf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts/JetBrainsMonoNerd --wildcards '*.ttf'
fc-cache -f
fc-list : family | grep -i "JetBrainsMono Nerd Font Mono"   # must print something
```

If this font is missing, all bar/widget icons show up as empty boxes.

---

## 5. Clone the dotfiles onto the new machine

```bash
git clone --bare git@github.com:TranDuong874/i3wm_config.git "$HOME/.dotfiles"
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dot config status.showUntrackedFiles no
dot checkout
```

If `dot checkout` fails with *"untracked working tree files would be overwritten"*
(typically `.profile`, `.bash_aliases`, `.config/gtk-3.0/settings.ini`), move those
default files out of the way and try again:

```bash
mkdir -p ~/.dotfiles-backup
dot checkout 2>&1 | grep -E '^\s+\.' | awk '{print $1}' | while read -r f; do
  mkdir -p ~/.dotfiles-backup/"$(dirname "$f")"; mv ~/"$f" ~/.dotfiles-backup/"$f"
done
dot checkout
```

Make sure scripts are executable (git keeps the bit, but check anyway):

```bash
chmod +x ~/.local/bin/powermenu ~/.local/bin/lock \
         ~/.config/eww/scripts/osd.sh ~/.config/polybar/launch.sh \
         ~/.config/autorandr/postswitch ~/.config/autorandr/docked/block
```

`~/.local/bin` must be on your `PATH`. Ubuntu's `~/.profile` adds it **only if the
folder exists at login** — it exists after checkout, so just log out/in once.

---

## 6. Build and install eww

eww has **no prebuilt Linux binary** — it must be compiled. Build only the X11 backend:

```bash
git clone --depth 1 --branch v0.6.0 https://github.com/elkowar/eww.git /tmp/eww
cd /tmp/eww
~/.cargo/bin/cargo build --release --no-default-features --features x11
install -m755 target/release/eww ~/.local/bin/eww
eww --version     # prints "eww 0.5.0 ..." even for v0.6.0 — that's just a stale label, it's fine
```

Takes about 2–3 minutes. If it fails with missing `gtk+-3.0` / `pkg-config` errors,
the build packages from step 2 are missing.

---

## 7. Things that are NOT in git (run once)

Some settings live in dconf/gsettings or caches, not in files:

```bash
# GTK: dark mode + theme + icons (libadwaita/GTK4 apps read these)
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme  Yaru-magenta-dark
gsettings set org.gnome.desktop.interface icon-theme Yaru-magenta-dark

# yazi: download the Catppuccin Mocha flavor listed in ~/.config/yazi/package.toml
yazi.ya pkg install

# lock screen image (also rebuilt automatically when needed)
~/.local/bin/lock --prepare

# optional: shorter hostname, so the prompt isn't tranduong@tranduong-Legion-S7-15ACH6
sudo hostnamectl set-hostname Legion-S7-15ACH6
sudo sed -i 's/<old-hostname>/Legion-S7-15ACH6/' /etc/hosts   # keep /etc/hosts in sync, see §11
```

Also already handled by tracked files, but good to know:

- `~/.config/autostart/picom.desktop` (`Hidden=true`) stops Ubuntu's *system* picom
  autostart, so picom is started **once**, by i3, with our config.
- `~/.profile` exports `TERMINAL=kitty` and `NEWT_COLORS_FILE` (nmtui colors).
  `.profile` is only read at login → log out/in after changing it.

---

## 8. Machine-specific values you must check

These are hard-coded for my laptop. On another machine, check each one.

| What | Where | How to find the right value |
|---|---|---|
| **Touchpad name** (tap-to-click, natural scrolling) | `~/.config/i3/config` (bottom, `xinput set-prop "SYNA2BA6:00 06CB:CE44 Touchpad" ...`) | `xinput list \| grep -i touchpad` |
| **Backlight device** | `~/.config/polybar/config.ini` → `[module/backlight]` `card = nvidia_wmi_ec_backlight` | `ls /sys/class/backlight/` — use the one that actually dims the screen (see below) |
| **Battery / adapter** | `~/.config/polybar/config.ini` → `battery = BAT0`, `adapter = ADP1`; eww dashboard uses `EWW_BATTERY.BAT0` in `~/.config/eww/eww.yuck` | `ls /sys/class/power_supply/` |
| **Monitor profiles** | `~/.config/autorandr/{both,docked,mobile}` | must be **re-saved on every machine** (they contain the monitors' EDID) — see below |
| **Wallpaper** | `~/wallpapers/pexels-frostroomhead-17807337.jpg` (tracked), referenced in i3 config, `autorandr/postswitch`, `~/.local/bin/lock` | change all three if you change the file |
| **Mod key** | `~/.config/i3/config` line 1: `set $mod Mod1` (Alt) | `Mod4` = Super/Windows key |
| **Battery name in eww** | `~/.config/eww/eww.yuck`: `EWW_BATTERY.BAT0` (dashboard **and** `desktop-stats`) | `ls /sys/class/power_supply/` |
| **Weather city** (show-off clock) | guessed from your IP by wttr.in; to pin it add `export TERMCLOCK_CITY=Hanoi` to `~/.profile` | `curl 'wttr.in/?format=%l'` shows what it guesses |
| **Prefer LAN over Wi-Fi** | NetworkManager connection, not a file | see [LAN or Wi-Fi](#am-i-on-lan-or-wi-fi) |

### Finding the right backlight device

Laptops with hybrid graphics often show **two** devices (here `amdgpu_bl1` and
`nvidia_wmi_ec_backlight`). `brightnessctl` uses the first one it finds. Test which one
really changes the screen:

```bash
brightnessctl -l -c backlight                       # list devices
brightnessctl -d amdgpu_bl1 set 30%                 # watch the screen
brightnessctl -d nvidia_wmi_ec_backlight set 30%    # watch the screen
```

If only the non-default one works, add `-d <device>` to the `brightnessctl` calls in
`~/.config/eww/scripts/osd.sh` and set `card =` in polybar to the same device.

### Saving monitor profiles (autorandr)

autorandr identifies a layout by **which monitors are connected (EDID) on which port**.
Save each profile on the new machine:

```bash
xrandr                         # see output names, e.g. eDP and DP-1-0

# 1) "mobile" — UNPLUG the external monitor first
autorandr --save mobile --force

# 2) plug the monitor in, then "both": laptop left, external right (primary, 144 Hz)
xrandr --output eDP --auto --pos 0x0 \
       --output DP-1-0 --mode 1920x1080 --rate 144 --right-of eDP --primary
autorandr --save both --force

# 3) "docked": external only
xrandr --output eDP --off --output DP-1-0 --mode 1920x1080 --rate 144 --pos 0x0 --primary
autorandr --save docked --force

autorandr --load both
autorandr                      # list: should show "both (detected) (current)"
```

Replace `eDP` / `DP-1-0` with your names from `xrandr`. Notes:

- `docked/block` makes autorandr **never pick "docked" automatically** (only via
  `Alt+p` → `e` or `monitor docked`). When you plug in, you get "both".
- The output name depends on **which port** you plug into (I've seen `DP-1-0` and
  `DP-1-2` on the same laptop). If plugging in does nothing, set the layout once by
  hand and re-run `autorandr --save both --force`.
- Ubuntu's `autorandr.service` + udev rule switch profiles on plug/unplug automatically.
  Check: `systemctl is-enabled autorandr.service` → `enabled`.
- `autorandr` prints a few `SyntaxWarning: invalid escape sequence` lines on Ubuntu
  24.04 — a harmless bug in the packaged script.

---

## 9. First login and checking everything works

1. Log out. On the login screen click the **gear icon** and pick **i3**. Log in.
2. Go through this checklist:

| Check | Expected |
|---|---|
| Bar | polybar on every monitor, icons visible (not boxes) |
| `Alt+Enter` | kitty opens, dark navy, padding, no scrollbar |
| `Alt+d` | rofi sidebar on the left |
| Volume keys | value changes + popup bar near the bottom of the screen |
| Brightness keys | screen dims + popup bar; polybar 󰃠 % changes |
| Click the clock | calendar popup top-right |
| `Alt+Shift+d` / 󰕮 in bar | dashboard (clock, calendar, cpu/ram/disk/battery, sliders, music) |
| On the wallpaper (empty workspace) | big clock (top left), system + calendar cards (top right), music card with cover (bottom left, only while something plays) with moving visualizer bars; `Alt+Shift+w` hides/shows them |
| `Alt+Shift+i` | show-off workspace 10: clock + weather, fastfetch, btop, now playing with cover, cava waves. Press again to go back; `Alt+Ctrl+i` closes it |
| New terminal | prompt `user@host:~/path  branch` on one line, `❯` on the next; blinking block cursor |
| `Alt+Shift+e` / ⏻ in bar | power menu; `Esc` closes it |
| `Print` | flameshot area select, saved to `~/Pictures/Screenshots` |
| `notify-send test hello` | Mocha notification with icon, top-right |
| `Alt+n` | yazi with icons and Mocha colors |
| Touchpad | tap = click, two-finger scroll in "natural" direction |
| `loginctl lock-session` | blurred wallpaper lock screen |
| `Alt+p` → `b` / `l` / `e` | monitor layouts switch; bar + wallpaper redraw; notification |

Validate the i3 config any time with:

```bash
i3 -C -c ~/.config/i3/config     # no output + exit code 0 = OK
```

---

## 10. Desktop widgets and the show-off workspace

### Desktop widgets (eww, on the wallpaper)

```
 23:50 39                                   ┃ system
 Sunday, 25 October 2026                    ┃ 󰍛 cpu  18%  ━━──────
                                            ┃ 󰘚 ram  40%  ━━━─────  ...
                                            ┃ calendar
                                            ┃ ‹ October ›  ‹ 2026 ›  ...
 ┃ [cover]  Song title
 ┃          Artist
 ┃          ▖▗▌▌▖▗▌▖  (visualizer, only while playing)
 ┃          ━━━━━━━──  2:56 / 3:32   ⏮ ⏸ ⏭
```

| Widget (eww window) | Where | Notes |
|---|---|---|
| `desktop-clock` | top left | time, seconds, date |
| `desktop-stats` | top right | cpu / ram / disk / battery + uptime, calendar card under it |
| `desktop-music` | bottom left | cover, title, artist, cava bars, progress, buttons; hidden when nothing plays |

How it fits together:

- `~/.config/eww/scripts/desktop.sh` opens all three at login (i3 `exec`) and after every
  monitor switch (`autorandr/postswitch`). `desktop.sh toggle` = `Alt+Shift+w`.
- **They must sit behind windows.** eww's `:stacking "bg"` is ignored on i3 for
  `:wm-ignore true` windows, so `desktop.sh` lowers them itself with `XLowerWindow`
  (python `ctypes`, no extra package). If they ever cover your apps, run `desktop.sh` again.
- picom must not blur/shadow the transparent widget windows (you get a grey box/strip):
  see `shadow-exclude` / `blur-background-exclude` in `picom.conf`.
- Album art: `scripts/cover.sh` downloads Spotify's https cover once into
  `~/.cache/eww/covers/` (keeps the newest 50).
- Visualizer: `scripts/cava.sh` runs `cava -p ~/.config/cava/eww.conf` (raw output,
  28 bars, values 0–100) and turns each frame into a JSON list; eww draws one thin vertical
  `progress` per value. Requires `cava` (in the apt list). For about a second after music
  starts all bars can sit near the top while cava auto-adjusts sensitivity — normal.
- Positions: `:geometry` in `eww.yuck`. With `:anchor "... right"` or `"bottom ..."`,
  offsets go **outward**, so use **negative** `x`/`y` to move inward.

### Show-off workspace (`Alt+Shift+i`)

A tiled "dashboard with more information" made of kitty panes, built on **workspace 10**:

```
┌───────────────────────────────┬──────────────────────────────────┐
│     good night, tranduong     │ btop (Catppuccin theme)           │
│      ┏━┓┏━┓ ╺┓ ┏━┓  (future)   │                                   │
│   Monday, 26 October 2026     │                                   │
│ 󰖑 27°C haze · Hanoi · week 44 ├──────────────────────────────────┤
├───────────────────────────────┤ [cover]  ♪ Song · Artist          │
│ fastfetch (small logo, Mocha) │          ━━━━━━━──  1:08 / 3:11   │
│                               ├──────────────────────────────────┤
│ ❯                             │ ▂▅▇█▆▃ cava (mauve→pink→blue)     │
└───────────────────────────────┴──────────────────────────────────┘
```

| Key / command | Does |
|---|---|
| `Alt+Shift+i` / `showoff` | build it on ws 10; if it already exists, jump to it, or back to where you were |
| `Alt+Ctrl+i` / `showoff close` | close all its panes (waits until they're gone); i3 removes the empty workspace |
| `showoff 3` | build it on another workspace instead |

Pieces:

| Pane | Program | Config |
|---|---|---|
| clock | `~/.local/bin/termclock` — greeting, `toilet -f future` digits, date, weather (wttr.in, cached 30 min in `~/.cache/termclock-weather`), ISO week + day of year | kitty `-o font_size=17 -o box_drawing_scale=0.001,1.5,3,4` (thicker digits) in `showoff` |
| system info | `fastfetch` | `~/.config/fastfetch/config.jsonc` (small logo, short GPU names) |
| monitor | `btop` | `~/.config/btop/btop.conf` → `color_theme = "catppuccin_mocha"`, `theme_background = False` |
| now playing | `~/.local/bin/nowplaying` — cover via `kitty +kitten icat`, title, artist, progress | shares the cover cache with eww |
| waves | `cava -p ~/.config/cava/showoff.conf` | gradient colors, bar width/spacing |

The layout is `~/.config/i3/layouts/showoff.json` (`append_layout`); each placeholder
"swallows" a kitty started with `--name showoff-<pane>`. Change the pane sizes with the
`percent` values there. To fix a messed-up layout (e.g. after `Alt+s`/`Alt+w`):
`Alt+Ctrl+i` then `Alt+Shift+i`.

---

## 11. Shell: prompt, cursor, hostname

**Prompt** — set at the end of `~/.bash_aliases` (read after `.bashrc`, so it overrides
Ubuntu's default `PS1`):

```
tranduong@Legion-S7-15ACH6:~/projects/foo  main     ← green user, grey @host, blue path, yellow git branch
❯                                                    ← mauve, you type here
```

- No blank line before the prompt, `user@host:path` spacing like Ubuntu's default.
- `PROMPT_DIRTRIM=3` shortens deep paths to `…/a/b/c`.
- The branch comes from `__git_ps1` (ships with git on Ubuntu).
- The same block strips **bold** from `LS_COLORS`, so `ls` folders are colored but not bold.
- Colors are 24-bit escapes (`\e[38;2;R;G;Bm`); keep every escape inside `\[ \]` or line
  editing breaks.

**Cursor** — `~/.config/kitty/kitty.conf`: `cursor_shape block`,
`cursor_blink_interval -1` (GNOME Terminal style) and `shell_integration no-cursor`
(otherwise kitty's shell integration switches it to a beam at the prompt). Options:
`block` / `beam` / `underline`. Reload kitty: `Ctrl+Shift+F5`.

**Hostname** — the prompt shows `\h`. Rename with `hostnamectl` *and* update
`/etc/hosts` (see §7). Terminals opened before the rename keep showing the old name.

---

## 12. Keybindings and where they are configured

`$mod` = **Alt** (`set $mod Mod1` in `~/.config/i3/config`). All keybindings live in
**`~/.config/i3/config`** unless noted. Mouse actions in the bar live in
**`~/.config/polybar/config.ini`**.

### Apps and launchers

| Keys | Action | Runs |
|---|---|---|
| `Alt+Enter` | terminal | `kitty` |
| `Alt+n` | file manager | `kitty -e yazi` |
| `Alt+d` | app launcher | `rofi -show drun` |
| `Alt+Tab` | window switcher | `rofi -show window` |
| `Alt+Shift+d` | dashboard (toggle) | `eww open --toggle dashboard` |
| `Alt+Shift+i` | show-off terminal workspace (builds it on ws 10, then jumps there / back) | `~/.local/bin/showoff` |
| `Alt+Ctrl+i` | close the show-off workspace (all its panes) | `~/.local/bin/showoff close` |
| `Alt+Shift+w` | desktop clock, stats, music (toggle) | `~/.config/eww/scripts/desktop.sh toggle` |
| `Alt+Shift+q` | close window | i3 `kill` |

### Mode menus (press the combo, then a letter; `Esc` cancels)

| Keys | Menu | Letters |
|---|---|---|
| `Alt+c` | Controls | `a` pavucontrol, `b` blueman-manager, `w` nmtui (in kitty) |
| `Alt+p` | Display (autorandr) | `a` auto-detect, `e` external only (docked), `l` laptop only (mobile), `b` both |
| `Alt+Shift+e` | Power menu (eww + i3 mode `power`) | `l` lock, `e` logout, `s` suspend, `r` reboot, `p` shutdown, `Esc`/`Alt+Shift+e` close |
| `Alt+r` | Resize | arrows or `j k l ;` to resize, `Enter`/`Esc` exit |

### Hardware keys

| Key | Action | Configured in |
|---|---|---|
| Volume up / down / mute | `pactl` ±2 % / toggle + popup | i3 config → `~/.config/eww/scripts/osd.sh` |
| Mic mute | `pactl set-source-mute` | i3 config |
| Brightness up / down | `brightnessctl` ±10 % + popup | i3 config → `~/.config/eww/scripts/osd.sh` |
| Play / Next / Prev | `playerctl` | i3 config |

### Screenshots (flameshot; settings in `~/.config/flameshot/flameshot.ini`)

| Keys | Action |
|---|---|
| `Print` or `Alt+Shift+s` | select area (GUI) |
| `Shift+Print` | all monitors → clipboard |
| `Ctrl+Print` or `Alt+Ctrl+s` | current monitor → clipboard |

### Windows, layouts, workspaces (mostly i3 defaults)

| Keys | Action |
|---|---|
| `Alt+←↓↑→` or `Alt+j k l ;` | focus window (crosses to the other monitor at the edge) |
| `Alt+Shift+←↓↑→` / `j k l ;` | move window |
| `Alt+1…0` | go to workspace 1–10 |
| `Alt+Shift+1…0` | move window to workspace |
| `Alt+h` / `Alt+v` | next window splits horizontally / vertically |
| `Alt+f` | fullscreen |
| `Alt+s` / `Alt+w` / `Alt+e` | stacked / tabbed / split layout of the focused container (stacked/tabbed hide the gaps; `Alt+e` returns to split) |
| `Alt+Shift+Space` | float / tile window |
| `Alt+Space` | focus between floating and tiled |
| `Alt+a` / `Alt+Shift+a` | focus parent / child container |
| `Alt+Shift+-` / `Alt+-` | send to / show scratchpad |
| `Alt+Shift+c` | reload i3 config |
| `Alt+Shift+r` | restart i3 (keeps windows) |
| Alt + drag | move floating window |

### Mouse actions in polybar (`~/.config/polybar/config.ini`)

| Click | Action |
|---|---|
| Clock (left) | calendar popup |
| Volume (right) | pavucontrol |
| Network (left) | nmtui in kitty |
| Brightness (scroll) | change brightness |
| 󰕮 (left) | dashboard |
| 󰄀 (left / right) | flameshot area / screen to clipboard |
| ⏻ (left) | power menu |

### Shell (`~/.bash_aliases`)

| Command | Action |
|---|---|
| `dot …` | git for this dotfiles repo |
| `y` | yazi, and `cd` to the folder you were in when you quit |
| `monitor` | list autorandr profiles (current is marked) |
| `monitor both\|docked\|mobile\|auto` | switch layout |
| `picomc` / `i3conf` | edit picom / i3 config in nano |

### Things started automatically at login (i3 config)

`dex` (XDG autostart), `xss-lock` → `~/.local/bin/lock`, `nm-applet`, `blueman-applet`,
polybar (`exec_always launch.sh`), `picom`, `dunst`, `eww daemon`, desktop widgets
(`~/.config/eww/scripts/desktop.sh`), `feh` wallpaper (`exec_always`),
`autorandr --change`, touchpad `xinput` settings (`exec_always`).

---

## 13. Troubleshooting / lessons learned

Every problem below actually happened while building this setup.

### Brightness keys do nothing
`brightnessctl set +10%` → *Permission denied*. You're not in the `video` group →
[step 3](#3-permissions-brightness-keys), then **log out/in**. Terminals opened before
the re-login still have the old groups and keep failing — open a new one.
If permission is fine but the screen doesn't dim, you're driving the wrong backlight
device → [section 8](#finding-the-right-backlight-device).

### Icons are empty boxes (polybar / eww / yazi)
JetBrainsMono Nerd Font isn't installed → [step 4](#4-fonts). Polybar loads it as
`font-1` (icons only); kitty maps icon code points to it with `symbol_map`.

### yazi icons look squashed / overlap
You're in gnome-terminal, which falls back to a *non-Mono* Nerd Font whose icons are
wider than one cell. Use kitty — its `symbol_map` uses **JetBrainsMono Nerd Font Mono**
(icons fit exactly one cell).

### `Alt+Enter` still opens gnome-terminal
`i3-sensible-terminal` reads `$TERMINAL`, which only exists after re-login. To avoid that
trap the i3 config calls `kitty` directly.

### Touchpad: can drag but tap doesn't click / scroll direction "inverted"
X11/libinput defaults tap-to-click **off** (GNOME turns it on, i3 doesn't). The i3 config
sets both, using the touchpad's exact name:
```bash
xinput set-prop "<touchpad name>" "libinput Tapping Enabled" 1
xinput set-prop "<touchpad name>" "libinput Natural Scrolling Enabled" 1   # 0 = traditional
```

### `Alt+p` display switching does nothing
The old version hard-coded an output name (`DP-1-2`) but the monitor appeared as
`DP-1-0`. Now everything goes through autorandr profiles, which must be saved per
machine → [section 8](#saving-monitor-profiles-autorandr). If all three profiles are
identical (same checksum: `md5sum ~/.config/autorandr/*/config`), they were all saved
in the same layout — re-save them.

### Popups appear off-screen (eww)
With `:anchor "bottom center"`, eww adds the y offset *downwards*. Use a **negative**
offset (`:y "-80px"`) to lift it above the bottom edge. Find a window's real position
with `xwininfo -root -tree | grep Eww`.

### `eww logs` never returns
It follows the log forever (like `tail -f`). Use `Ctrl+C`. To check config errors once:
`eww reload` and `eww debug`.

### Bar restart hangs
An old `launch.sh` waited forever for polybar to exit. The current one sends `pkill`,
waits max 2 s, then `pkill -9`.

### polybar warns "Systray selection already managed"
Happens when a new polybar starts before the old one released the tray. Restart the bar
once more (`~/.config/polybar/launch.sh`); it goes away.

### picom running twice / ignoring config
Ubuntu ships `/etc/xdg/autostart/picom.desktop`, which `dex` launches with default
settings. The tracked `~/.config/autostart/picom.desktop` (`Hidden=true`) disables it;
i3 starts picom with `--config ~/.config/picom/picom.conf`. Reload picom's config:
`pkill -USR1 picom`.

### Rounded corners
Set by picom: `corner-radius = 0;` in `~/.config/picom/picom.conf` (sharp). Window
borders are i3's `default_border pixel 2` (2 px, no title bar).

### Notifications without icons
dunst needs an icon theme: `icon_theme = "Yaru-magenta-dark, Yaru, Adwaita"` and
`enable_recursive_icon_lookup = true` in `~/.config/dunst/dunstrc`.

### nmtui colors
newt only knows 16 terminal color names (`black`, `magenta`, `default`, …), so its colors
come from kitty's palette. `default` = terminal background.

### "Am I on LAN or Wi-Fi?"
Both can be connected; Linux sends traffic over the default route with the **lowest
metric**. Check: `ip route show default`.
NetworkManager adds ~20000 to a connection whose internet check fails, so the winner can
flip: once LAN was 20100 vs Wi-Fi 20600 (LAN used), later Wi-Fi was 600 vs LAN 20100
(**Wi-Fi used** even with the cable in). Cloudflare WARP/Tailscale ride on whichever wins.
- Use LAN now: `nmcli radio wifi off`
- Always prefer LAN (use your connection name from `nmcli connection`):
  ```bash
  nmcli connection modify netplan-enx00e04c155b17 ipv4.route-metric 100 ipv6.route-metric 100
  nmcli connection up netplan-enx00e04c155b17
  ```
The polybar network module only shows **wireless** (`interface-type = wireless`), so it
displays the Wi-Fi name even when traffic goes over LAN.

### Power menu "lock" does nothing
`loginctl lock-session` only *asks* for a lock; `xss-lock` is the program that answers by
running `~/.local/bin/lock`. It's started by i3 `exec` **at login only**, so right after
adding it (or if it crashed) nothing listens. The power menu now runs
`~/.local/bin/lock` directly. Check the suspend lock: `pgrep -a xss-lock`; start it
without re-login: `setsid xss-lock --transfer-sleep-lock -- ~/.local/bin/lock &`.

### Desktop widgets cover my windows
eww's `:stacking "bg"` doesn't work for unmanaged windows on i3. Run
`~/.config/eww/scripts/desktop.sh` (it lowers them with `XLowerWindow`).

### Grey box / blurry strip around a desktop widget
picom blurs and shadows the whole (transparent) widget window. Add it to
`shadow-exclude` and `blur-background-exclude` by name (`"name = 'Eww - desktop-…'"`),
then restart picom.

### A widget is half off the screen
With a right/bottom anchor, a positive `x`/`y` pushes it **outward**. Use `-56px`.

### Text widget truncated with "…"
eww sizes the window to its first content; give big labels a `:width` in `:geometry`.

### Progress bar made of `━` doesn't show (bash script)
`tr ' ' '━'` is byte-based and mangles multi-byte characters. Use bash:
`bar=$(printf "%${n}s" ""); bar=${bar// /━}`.

### Album cover disappears in the kitty pane
In kitty, clearing the screen (`\e[2J`) also deletes images. `nowplaying` therefore
only clears + redraws the cover when the track changes or the pane is resized, and
updates the text with cursor moves.

### `Alt+Shift+i` jumps to the previous workspace instead of workspace 10
The i3 config has `workspace_auto_back_and_forth yes`: asking for the workspace you're
already on sends you back. `showoff` uses `workspace --no-auto-back-and-forth 10` when
building.

### Show-off layout: gaps gone / panes stacked or tabbed
`Alt+s` (stacked) or `Alt+w` (tabbed) was pressed on a pane. `Alt+e` returns that
container to split; for a clean reset `Alt+Ctrl+i` then `Alt+Shift+i`.

### Rebuilding right after closing does nothing
Windows take a moment to close; if `showoff` still sees them it only switches
workspace. `showoff close` now waits until all panes are gone.

### Prompt still shows the old hostname / `sudo: unable to resolve host`
Old terminals keep the old `\h` — open a new one. The sudo warning means `/etc/hosts`
still has the old name on the `127.0.1.1` line.

### Testing screens/windows from a script
`pkill -f '<pattern>'` also matches the shell running the command (its command line
contains the pattern) and kills it. Use `pkill -x <name>` or a unique `--class`.

---

## 14. File map

| Path | What |
|---|---|
| `.config/i3/config` | i3: keys, modes, gaps/borders/colors, autostart, touchpad |
| `.config/picom/picom.conf` | sharp corners, shadows, terminal transparency, exclusions |
| `.config/autostart/picom.desktop` | disables Ubuntu's duplicate picom autostart |
| `.config/polybar/config.ini` | bar modules, colors, click actions |
| `.config/polybar/launch.sh` | starts one bar per monitor |
| `.config/rofi/config.rasi` | rofi behavior, uses theme "edge" |
| `.local/share/rofi/themes/edge.rasi` | sharp sidebar theme with match counter |
| `.config/dunst/dunstrc` | notification look + icons |
| `.config/eww/eww.yuck` | widgets: desktop clock / stats+calendar / music, calendar popup, osd, dashboard, powermenu |
| `.config/eww/eww.scss` | widget styling |
| `.config/eww/scripts/osd.sh` | change volume/brightness + show popup |
| `.config/eww/scripts/desktop.sh` | open the desktop widgets (clock, stats + calendar, music) and push them behind windows (eww's `:stacking "bg"` doesn't work for unmanaged windows on i3, so it calls `XLowerWindow` via python ctypes) |
| `.local/bin/showoff` | terminal show-off workspace (`Alt+Shift+i`, or `showoff` → ws 10, `showoff 3` → ws 3): clock, fastfetch, btop, now playing, cava visualizer (`.config/cava/showoff.conf`). Layout in `.config/i3/layouts/showoff.json`, panes matched by `kitty --name` |
| `.local/bin/termclock`, `.local/bin/nowplaying` | the clock and music panes used by `showoff` (the cover is drawn with `kitty +kitten icat`, so the music pane only works in kitty) |
| `.config/btop/btop.conf`, `.config/btop/themes/catppuccin_mocha.theme`, `.config/fastfetch/config.jsonc` | Mocha colors for btop / fastfetch |
| `.config/i3/layouts/showoff.json` | pane layout of the show-off workspace |
| `.config/cava/showoff.conf` | cava look in the show-off workspace |
| `.config/eww/scripts/cava.sh`, `.config/cava/eww.conf` | audio visualizer bars in the desktop music card (cava raw output → JSON list → eww vertical progress bars; shown only while playing) |
| `.config/eww/scripts/cover.sh` | downloads album art for the music widget into `~/.cache/eww/covers` |
| `.local/bin/powermenu` | toggle power menu / run lock (calls `~/.local/bin/lock` directly), logout, suspend, reboot, shutdown |
| `.local/bin/lock` | blurred-wallpaper i3lock (`--prepare` = only build image) |
| `.config/kitty/kitty.conf` | terminal font, padding, Mocha colors, blinking block cursor |
| `.config/yazi/theme.toml`, `package.toml` | yazi uses the catppuccin-mocha flavor |
| `.config/flameshot/flameshot.ini` | screenshot colors + save path |
| `.config/autorandr/{both,docked,mobile}/` | monitor profiles (machine-specific) |
| `.config/autorandr/docked/block` | don't auto-select "docked" |
| `.config/autorandr/postswitch` | after a layout switch: bar, wallpaper, lock image, notify |
| `.config/newt/colors` | nmtui colors |
| `.config/gtk-3.0/settings.ini`, `gtk.css` | GTK3 theme/icons + Mocha colors |
| `.config/gtk-4.0/settings.ini`, `gtk.css` | GTK4/libadwaita theme + Mocha colors |
| `.profile` | `TERMINAL=kitty`, `NEWT_COLORS_FILE`, `~/.local/bin` in PATH |
| `.bash_aliases` | `dot`, `y`, `monitor`, editor shortcuts, the prompt (`PS1`), non-bold `LS_COLORS` |
| `wallpapers/pexels-frostroomhead-17807337.jpg` | wallpaper (Pexels) |

---

## 15. Color palette

Catppuccin **Mocha**, used everywhere:

| Name | Hex | Used for |
|---|---|---|
| base | `#1e1e2e` | backgrounds |
| mantle | `#181825` | cards, sidebars |
| crust | `#11111b` | header bars |
| surface0 | `#313244` | unfocused borders, highlights |
| surface1 | `#45475a` | separators |
| overlay0 | `#6c7086` | dim text |
| text | `#cdd6f4` | text |
| **mauve** | `#cba6f7` | **main accent** (focused border, bar accents, popups) |
| blue | `#89b4fa` | second accent |
| pink | `#f5c2e7` | i3 split indicator, nmtui accent |
| red | `#f38ba8` | urgent, battery low, shutdown |
| green | `#a6e3a1` | success |

---

## 16. Day-to-day: saving changes to this repo

```bash
dot status                       # changed tracked files
dot add ~/.config/some/new/file  # new files MUST be added explicitly
dot commit -m "what changed"
dot push
```

Before committing i3 changes, run `i3 -C -c ~/.config/i3/config`.
