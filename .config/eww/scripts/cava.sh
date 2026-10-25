#!/usr/bin/env bash
# Audio visualizer data for the eww music widget: one JSON list per frame, e.g. [3,40,87,...]
# Waits for cava to be installed (sudo apt install cava), so no eww reload is needed.
until command -v cava >/dev/null; do sleep 10; done
cava -p ~/.config/cava/eww.conf 2>/dev/null | sed -u 's/;$//; s/^/[/; s/$/]/; s/;/,/g'
