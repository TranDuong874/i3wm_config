#!/usr/bin/env bash
# Prints a local path to the current track's album art (for eww's music widget).
# Spotify gives https:// URLs, so download them once into ~/.cache/eww/covers.
dir="${XDG_CACHE_HOME:-$HOME/.cache}/eww/covers"
mkdir -p "$dir"
playerctl --follow metadata --format '{{ mpris:artUrl }}' 2>/dev/null | while read -r url; do
  case "$url" in
    "")        echo "" ;;
    file://*)  echo "${url#file://}" ;;
    http*)
      f="$dir/$(printf '%s' "$url" | md5sum | cut -c1-16).jpg"
      [ -s "$f" ] || curl -fsSL --max-time 10 -o "$f" "$url" || { echo ""; continue; }
      echo "$f"
      # keep the cache small
      ls -1t "$dir"/*.jpg 2>/dev/null | tail -n +51 | xargs -r rm -f ;;
    *)         echo "" ;;
  esac
done
