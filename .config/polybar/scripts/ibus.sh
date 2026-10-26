#!/usr/bin/env bash
# Polybar input-method label (IBus): EN / VI. Left click (or `ibus.sh toggle`) switches.
# Engines: English (xkb:us::eng) and Vietnamese (Unikey). Super+Space also switches (IBus hotkey).
EN=xkb:us::eng; VI=Unikey
cur=$(ibus engine 2>/dev/null)
if [ "$1" = toggle ]; then
  if [ "$cur" = "$VI" ]; then ibus engine "$EN"; else ibus engine "$VI"; fi
  exit 0
fi
case "$cur" in
  "$VI") echo "%{F#cba6f7}󰌌%{F-} VI" ;;
  "")    echo "%{F#6c7086}󰌌 --%{F-}" ;;      # ibus not running
  *)     echo "%{F#cba6f7}󰌌%{F-} EN" ;;
esac
