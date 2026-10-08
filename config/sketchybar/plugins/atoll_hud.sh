#!/bin/zsh
# When Atoll's small volume/brightness HUD pops out of the notch, widen the
# bar's notch gap to hug it, then slide back once the HUD goes away.
[ "$SENDER" = "volume_change" ] || [ "$SENDER" = "brightness_change" ] || exit 0
zmodload zsh/datetime

# Ignore auto-brightness: it changes brightness in tiny gradual steps, while the
# brightness keys jump by ~6%. Only a jump that big means Atoll's HUD is showing.
if [ "$SENDER" = "brightness_change" ]; then
  LAST_FILE="/tmp/sketchybar_brightness.$UID"
  NOW=$(( INFO <= 1.0 ? INFO * 100.0 : INFO ))
  LAST=$(cat "$LAST_FILE" 2>/dev/null || echo $NOW)
  echo $NOW > "$LAST_FILE"
  DELTA=$(( NOW > LAST ? NOW - LAST : LAST - NOW ))
  (( DELTA < 4 )) && exit 0
fi
CONF="$HOME/.config/sketchybar/helpers/notchguard.conf"
typeset -A C
for k v in $(awk -F= '/^[a-z_]+ *=/{gsub(/ /,""); print $1, $2}' "$CONF" 2>/dev/null); do C[$k]=$v; done
[ "${C[hud_enabled]}" = "0" ] && exit 0
HUD_W=${C[hud_width]:-400}
DUR=${C[hud_duration]:-1.5}
OPEN_FR=${C[hud_open_frames]:-10}
CLOSE_FR=${C[hud_close_frames]:-36}
CLOSED_GAP=210
TOKEN_FILE="/tmp/sketchybar_atoll_hud.$UID"

# Width of the left pill tells us the current gap; if Atoll is fully open, leave it alone.
left_w() { sketchybar --query left_pill | grep -A1 '"size"' | grep -oE '[0-9]+' | head -1; }
FULL_OPEN_LEFT=$(( 756 - (${C[atoll_open_width]:-690} + 20) / 2 - 16 + 40 ))
[ "$(left_w)" -le "$FULL_OPEN_LEFT" ] && exit 0

TOKEN=$EPOCHREALTIME
echo $TOKEN > "$TOKEN_FILE"
sketchybar --animate tanh $OPEN_FR --bar notch_width=$HUD_W

{
  sleep $DUR
  # Only restore if no newer HUD event came in and Atoll didn't fully open meanwhile.
  [ "$(cat "$TOKEN_FILE" 2>/dev/null)" = "$TOKEN" ] || exit 0
  [ "$(left_w)" -le "$FULL_OPEN_LEFT" ] && exit 0
  sketchybar --animate sin $CLOSE_FR --bar notch_width=$CLOSED_GAP
} &!
