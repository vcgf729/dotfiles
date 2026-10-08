#!/bin/zsh
# Sets up the tiling/bar/terminal config on a Mac. Safe to re-run.
set -e
DOT="${0:A:h}"

echo "==> Installing apps (Homebrew)"
command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
brew tap felixkratz/formulae
brew trust --formula felixkratz/formulae/sketchybar felixkratz/formulae/borders 2>/dev/null || true
brew bundle --file "$DOT/Brewfile"

echo "==> Linking configs"
link() {  # link <repo path> <target>
  local src="$DOT/$1" dst="$2"
  mkdir -p "${dst:h}"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then mv "$dst" "$dst.backup-$(date +%s)"; echo "   backed up $dst"; fi
  ln -sfn "$src" "$dst"; echo "   $dst -> $src"
}
link aerospace.toml          ~/.aerospace.toml
link config/sketchybar       ~/.config/sketchybar
link config/ghostty          ~/.config/ghostty
link config/fastfetch        ~/.config/fastfetch
link config/starship.toml    ~/.config/starship.toml

echo "==> Building NotchGuard (notch/menu-bar helper)"
H="$DOT/config/sketchybar/helpers"
mkdir -p "$H/NotchGuard.app/Contents/MacOS"
swiftc -O "$H/menubar_watch.swift" -o "$H/NotchGuard.app/Contents/MacOS/menubar_watch"
codesign --force -s - --identifier local.notchguard "$H/NotchGuard.app"

echo "==> Shell prompt"
grep -q 'starship init zsh' ~/.zshrc 2>/dev/null || cat >> ~/.zshrc <<'ZSH'

# Starship prompt
eval "$(starship init zsh)"

# System info banner (only in Ghostty)
[[ "$TERM_PROGRAM" == "ghostty" ]] && fastfetch
ZSH

echo "==> Starting everything"
brew services stop borders >/dev/null 2>&1 || true   # AeroSpace launches borders itself
brew services restart sketchybar
open -a AeroSpace

cat <<'MSG'

Done! A few one-time macOS settings to finish:
  1. Privacy & Security → Accessibility: allow AeroSpace and NotchGuard
     (NotchGuard.app is in ~/.config/sketchybar/helpers/)
  2. Control Center → "Automatically hide and show the menu bar": Always
  3. Desktop & Dock → turn off "Drag windows to screen edges to tile",
     "Drag windows to menu bar to fill screen", and "Show Widgets: On Desktop"
MSG
