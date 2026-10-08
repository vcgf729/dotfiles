#!/bin/zsh
# $1 = workspace id. Highlight focused; hide empty unfocused workspaces.
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
if [ "$1" = "$FOCUSED" ]; then
  sketchybar --set $NAME drawing=on background.drawing=on label.color=0xff000000
elif [ -n "$(aerospace list-windows --workspace "$1" 2>/dev/null)" ]; then
  sketchybar --set $NAME drawing=on background.drawing=off label.color=0xffffffff
else
  sketchybar --set $NAME drawing=off
fi
