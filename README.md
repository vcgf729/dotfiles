# dotfiles

A Linux-style macOS setup: i3-like tiling, a black & white status bar that
splits around the notch (and makes room for Atoll), and a riced terminal.

| Piece | Tool | Config |
|---|---|---|
| Tiling window manager | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | `aerospace.toml` |
| Focus borders | [JankyBorders](https://github.com/FelixKratz/JankyBorders) | started from `aerospace.toml` |
| Status bar | [SketchyBar](https://github.com/FelixKratz/SketchyBar) | `config/sketchybar/` |
| Notch / menu bar helper | NotchGuard (in this repo) | `config/sketchybar/helpers/` |
| Terminal | [Ghostty](https://ghostty.org) | `config/ghostty/config` |
| Prompt | [Starship](https://starship.rs) | `config/starship.toml` |
| System info | [fastfetch](https://github.com/fastfetch-cli/fastfetch) | `config/fastfetch/` |

## Install

```sh
git clone <this repo> ~/dotfiles
~/dotfiles/install.sh
```

The script installs everything with Homebrew, symlinks the configs into place
(backing up anything already there), builds NotchGuard, and prints the few
macOS settings to flip by hand.

## Keys (⌥ = Option)

| Keys | Action |
|---|---|
| `⌥ Enter` | New terminal |
| `⌥ h/j/k/l` | Focus left/down/up/right |
| `⌥⇧ h/j/k/l` | Move window |
| `⌥ 1–9` / `⌥⇧ 1–9` | Go to / send window to workspace |
| `⌥ f` | Fullscreen |
| `⌥⇧ Space` | Float / tile window |
| `⌥ /` `⌥ ,` | Tiles / accordion layout |
| `⌥ -` `⌥ =` | Resize |
| `⌥ Tab` | Last workspace |

## NotchGuard

A tiny helper that slides the bar away while the macOS menu bar is showing,
keeps the cursor off the top edge over the notch (so going for Atoll doesn't
reveal the menu bar), and resizes the bar's notch gap when Atoll opens.
Timing and sizes live in `config/sketchybar/helpers/notchguard.conf`.
