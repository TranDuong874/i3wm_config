#!/usr/bin/env bash
# Change volume/brightness, then flash the eww "osd" popup for a moment.
# usage: osd.sh vol-up | vol-down | vol-mute | bright-up | bright-down

STAMP="${XDG_RUNTIME_DIR:-/tmp}/eww-osd.stamp"

case "$1" in
  vol-up)      pactl set-sink-volume @DEFAULT_SINK@ +2% ;;
  vol-down)    pactl set-sink-volume @DEFAULT_SINK@ -2% ;;
  vol-mute)    pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
  bright-up)   brightnessctl -q set +10% ;;
  bright-down) brightnessctl -q set 10%- ;;
  *) echo "usage: $0 vol-up|vol-down|vol-mute|bright-up|bright-down" >&2; exit 1 ;;
esac

case "$1" in
  vol-*)
    value=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1 | tr -d %)
    if pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes; then icon="󰖁"
    elif [ "$value" -lt 34 ]; then icon="󰕿"
    elif [ "$value" -lt 67 ]; then icon="󰖀"
    else icon="󰕾"; fi
    label=volume ;;
  bright-*)
    value=$(brightnessctl -m | cut -d, -f4 | tr -d %)
    if   [ "$value" -lt 34 ]; then icon="󰃞"
    elif [ "$value" -lt 67 ]; then icon="󰃟"
    else icon="󰃠"; fi
    label=brightness ;;
esac

# the bar can't show more than 100%
[ "${value:-0}" -gt 100 ] && bar=100 || bar=${value:-0}

eww update osd_icon="$icon" osd_value="$bar" osd_label="$label"
eww active-windows 2>/dev/null | grep -q '^osd' || eww open osd

# close after 1.5s, unless another key press came in meanwhile
now=$(date +%s%N)
echo "$now" > "$STAMP"
(
  sleep 1.5
  [ "$(cat "$STAMP" 2>/dev/null)" = "$now" ] && eww close osd
) >/dev/null 2>&1 &
disown
