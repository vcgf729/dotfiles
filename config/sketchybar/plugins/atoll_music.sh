#!/bin/zsh
# While music (or any audio) is playing, Atoll widens the notch to show its
# now-playing activity. Widen the bar's resting notch gap to match, and shrink
# it back when playback stops. NotchGuard and the HUD script return to this
# "base gap" (stored in /tmp/sketchybar_base_gap) instead of the bare notch.
CONF="$HOME/.config/sketchybar/helpers/notchguard.conf"
typeset -A C
for k v in $(awk -F= '/^[a-z_]+ *=/{gsub(/ /,""); print $1, $2}' "$CONF" 2>/dev/null); do C[$k]=$v; done
BASE_FILE=/tmp/sketchybar_base_gap

# Which apps are playing audio right now (from the system's audio assertions)
playing_apps() {
  pmset -g assertions | awk '/Created for PID:/ {gsub(/[^0-9]/,"",$4); pid=$4} /audio-out/ && pid {print pid; pid=""}' |
    while read pid; do ps -o comm= -p $pid 2>/dev/null | sed 's#.*/##'; done
}
# Only media players count (games and calls don't make Atoll show now-playing)
APPS=${C[music_apps]:-Spotify,Music,zen,plugin-container,Safari,Google Chrome,firefox,Arc,Podcasts,TV}
is_media() {
  local a; while read a; do
    for m in ${(s:,:)APPS}; do [[ "${a// /}" == "${m// /}"* ]] && return 0; done
  done; return 1
}

EVENT_FILE=/tmp/sketchybar_music_event.$UID
if [ "$SENDER" = "spotify_change" ] || [ "$SENDER" = "music_change" ]; then
  # Instant: the player told us its state (INFO is the notification's JSON)
  touch $EVENT_FILE
  if [ "${C[music_enabled]}" != "0" ] && [[ "$INFO" == *'"Player State":"Playing"'* || "$INFO" == *'"Player State": "Playing"'* ]]; then
    WANT=${C[music_width]:-330}
  else
    WANT=210
  fi
else
  # Polling (browsers etc.). Right after a play/pause event, trust the event:
  # the system's audio flag lingers a few seconds after pausing.
  [ -n "$(find /tmp -maxdepth 1 -name "sketchybar_music_event.$UID" -mtime -6s 2>/dev/null)" ] && exit 0
  if [ "${C[music_enabled]}" != "0" ] && playing_apps | is_media; then
    WANT=${C[music_width]:-330}
  else
    WANT=210
  fi
fi
HAVE=$(cat $BASE_FILE 2>/dev/null || echo 210)
[ "$WANT" = "$HAVE" ] && exit 0
echo $WANT > $BASE_FILE

# Don't fight Atoll when it's fully open or its volume HUD is showing; they
# return to the new base gap on their own when they close.
LEFT=$(sketchybar --query left_pill | grep -A1 '"size"' | grep -oE '[0-9]+' | head -1)
FULL_OPEN_LEFT=$(( 756 - (${C[atoll_open_width]:-690} + 20) / 2 - 16 + 40 ))
(( LEFT <= FULL_OPEN_LEFT )) && exit 0
[ -n "$(find /tmp -maxdepth 1 -name "sketchybar_atoll_hud.$UID" -mtime -3s 2>/dev/null)" ] && exit 0
sketchybar --animate tanh ${C[music_frames]:-30} --bar notch_width=$WANT
