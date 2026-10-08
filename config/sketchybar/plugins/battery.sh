#!/bin/zsh
BATT="$(pmset -g batt)"
PCT=$(echo "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
[ -z "$PCT" ] && exit 0
case $PCT in
  9[0-9]|100) ICON=$'' ;;
  [6-8][0-9]) ICON=$'' ;;
  [3-5][0-9]) ICON=$'' ;;
  [1-2][0-9]) ICON=$'' ;;
  *)          ICON=$'' ;;
esac
echo "$BATT" | grep -q 'AC Power' && ICON=$''
sketchybar --set $NAME icon="$ICON" label="${PCT}%"
