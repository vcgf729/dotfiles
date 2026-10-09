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
and resizes the bar's notch gap when Atoll opens. It also keeps the cursor off
the top edge from the left side of the screen through the notch, so reaching
for the workspace numbers or Atoll never reveals the macOS menu bar. To the
right of the notch, the menu bar works as normal (set where with
`menubar_block_until`).

The bar also makes room for Atoll's smaller expansions: its volume/brightness
HUD (`plugins/atoll_hud.sh`, ignoring auto-brightness) and its now-playing
activity while music plays (`plugins/atoll_music.sh`, `music_width`).
Timing and sizes live in `config/sketchybar/helpers/notchguard.conf` and are
re-read live, so tweaking them needs no rebuild.

NotchGuard needs **Accessibility** permission to fully block the menu bar.
`install.sh` signs it ad hoc, so every rebuild changes its signature and macOS
silently stops trusting it. After a rebuild, remove NotchGuard from
Privacy & Security → Accessibility with **−** and add it again with **+**.
Just toggling the old entry off and on is not enough.

## Credits

This repo is mostly configuration. The real work was done by the people who
built these tools. Please star their projects and support them.

| Project | Made by | What it does here | License |
|---|---|---|---|
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | [Nikita Bobko](https://github.com/nikitabobko) | The i3-style tiling window manager. `aerospace.toml` started from AeroSpace's default config. | MIT |
| [SketchyBar](https://github.com/FelixKratz/SketchyBar) | [Felix Kratz](https://github.com/FelixKratz) | The custom status bar. The plugin scripts follow SketchyBar's example setup. | GPL-3.0 |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | [Felix Kratz](https://github.com/FelixKratz) | The white border around the focused window. | GPL-3.0 |
| [Ghostty](https://github.com/ghostty-org/ghostty) | [Mitchell Hashimoto](https://github.com/mitchellh) and the [Ghostty contributors](https://github.com/ghostty-org/ghostty/graphs/contributors) | The terminal. | MIT |
| [Starship](https://github.com/starship/starship) | The [Starship contributors](https://github.com/starship/starship/graphs/contributors) | The shell prompt. | ISC |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | The [fastfetch contributors](https://github.com/fastfetch-cli/fastfetch/graphs/contributors) | The system info banner. | MIT |
| [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) | [Ryan L McIntyre](https://github.com/ryanoasis) and contributors | The icon glyphs in the bar and prompt. | Various (see repo) |
| [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) | [JetBrains](https://github.com/JetBrains) | The font underneath the Nerd Font patch. | OFL-1.1 |
| [Atoll](https://github.com/Ebullioscopic/Atoll) | [Ebullioscopic](https://github.com/Ebullioscopic) | The Dynamic Island–style notch app. Not installed by this repo; the bar and NotchGuard are built to work around it. | GPL-3.0 |
| [Homebrew](https://github.com/Homebrew/brew) | The [Homebrew maintainers](https://github.com/Homebrew/brew/graphs/contributors) | Installs everything. | BSD-2-Clause |

Other credit:

- The AeroSpace ↔ SketchyBar workspace integration and the "start borders from
  AeroSpace" approach come from the
  [AeroSpace guide](https://nikitabobko.github.io/AeroSpace/goodies).
- The idea came from the video
  [I made MacOS feel like Linux](https://www.youtube.com/watch?v=a7ve8kl4aK4).
- The configs, plugin scripts, NotchGuard and `install.sh` in this repo were
  written with help from [Claude](https://claude.ai) (Anthropic).

All of the projects above keep their own licenses. This repo doesn't include or
redistribute their code; `install.sh` installs them from their official sources
with Homebrew.
