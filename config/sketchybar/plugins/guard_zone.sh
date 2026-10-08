#!/bin/zsh
# Writes how far the Apple logo + workspace numbers reach, so NotchGuard can
# keep the macOS menu bar from popping up while the mouse is over them.
sleep 0.3   # let the workspace items finish showing/hiding
MAX=0
for i in $(aerospace list-workspaces --all); do
  read X W <<< $(sketchybar --query space.$i | awk -F'[][,]' '/"origin"/{x=$2} /"size"/ && !s {w=$2; s=1} END{print x+0, w+0}')
  (( X > 0 && X + W > MAX )) && MAX=$(( X + W ))
done
echo $(( MAX + 8 )) > /tmp/sketchybar_guard_left
