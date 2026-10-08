#!/bin/zsh
VOL="${INFO:-$(osascript -e 'output volume of (get volume settings)')}"
case $VOL in
  [6-9][0-9]|100) ICON=$'' ;;
  [1-5][0-9]|[1-9]) ICON=$'' ;;
  *) ICON=$'' ;;
esac
sketchybar --set $NAME icon="$ICON" label="${VOL}%"
