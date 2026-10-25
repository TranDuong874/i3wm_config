#!/usr/bin/env bash
pkill -x polybar
for _ in $(seq 20); do pgrep -u "$UID" -x polybar >/dev/null || break; sleep 0.1; done
pkill -9 -x polybar 2>/dev/null

for m in $(polybar --list-monitors | cut -d: -f1); do
  MONITOR=$m polybar --reload main >/dev/null 2>&1 &
done
