#!/bin/zsh
# Tells NotchGuard how far from the left edge to block the macOS menu bar.
# Everything from the left edge up to this x position (points) is blocked:
# the Apple logo, the workspace numbers and Atoll. To the right of it, pushing
# the mouse to the top edge shows the macOS menu bar as normal.
CONF="$HOME/.config/sketchybar/helpers/notchguard.conf"
X=$(awk -F= '{gsub(/ /,"")} $1=="menubar_block_until" {print $2}' "$CONF" 2>/dev/null)
echo "${X:-890}" > /tmp/sketchybar_guard_left
