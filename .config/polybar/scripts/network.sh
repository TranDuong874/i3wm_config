#!/usr/bin/env bash
# Polybar network label: shows the connection your traffic actually uses
# (the default route with the lowest metric), wired or Wi-Fi.
#   󰈀 LAN        cable
#   󰖩 <SSID>     Wi-Fi
#   󰖪 offline    no default route
M='%{F#cba6f7}'; R='%{F-}'
dev=$(ip -o route show default 2>/dev/null | awk '{
  d=""; m=0
  for (i=1; i<=NF; i++) { if ($i=="dev") d=$(i+1); if ($i=="metric") m=$(i+1) }
  print m, d }' | sort -n | head -1 | cut -d' ' -f2)

if [ -z "$dev" ]; then
  echo "%{F#6c7086}󰖪 offline%{F-}"; exit 0
fi
case "$(nmcli -g GENERAL.TYPE device show "$dev" 2>/dev/null)" in
  wifi)     echo "${M}󰖩${R} $(nmcli -g GENERAL.CONNECTION device show "$dev")" ;;
  ethernet) echo "${M}󰈀${R} LAN" ;;
  *)        echo "${M}󰛳${R} $dev" ;;
esac
