#!/usr/bin/env bash
# (Re)open the desktop widgets (big clock, music, system stats) once the eww daemon is up,
# then push them to the bottom of the X stack so windows cover them.
# Used by i3 at login and by autorandr after a monitor switch.
# "toggle": close them if open, otherwise open
if [ "$1" = toggle ] && eww active-windows 2>/dev/null | grep -q "^desktop-clock"; then
  eww close desktop-clock desktop-music desktop-stats; exit 0
fi

for _ in $(seq 20); do eww ping >/dev/null 2>&1 && break; sleep 0.25; done
eww close desktop-clock desktop-music desktop-stats >/dev/null 2>&1
eww open-many desktop-clock desktop-music desktop-stats
sleep 0.5

# eww's ":stacking bg" is ignored for unmanaged (wm-ignore) windows on i3,
# so lower them ourselves with XLowerWindow (python ctypes, no extra packages).
ids=$(xwininfo -root -tree | awk '/"Eww - desktop-(clock|music|stats)"/{print $1}')
python3 - $ids <<'PY'
import ctypes, sys
x = ctypes.cdll.LoadLibrary("libX11.so.6")
x.XOpenDisplay.restype = ctypes.c_void_p
d = x.XOpenDisplay(None)
for w in sys.argv[1:]:
    x.XLowerWindow(ctypes.c_void_p(d), ctypes.c_ulong(int(w, 16)))
x.XFlush(ctypes.c_void_p(d)); x.XCloseDisplay(ctypes.c_void_p(d))
PY
