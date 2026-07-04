# JellyoTmux

My personal tmux setup — config, helper scripts, plugins, and a one-command
installer. Prefix is **Ctrl-a**.

## Install

One-liner (from my domain or GitHub — both run the same bootstrap, which always
pulls the latest files from GitHub):

```sh
curl -fsSL https://jellyo.net/tmux-config.sh | sh
# or
curl -fsSL https://raw.githubusercontent.com/jellyo-o/JellyoTmux/main/install.sh | sh
```

Or from a clone:

```sh
git clone https://github.com/jellyo-o/JellyoTmux.git
cd JellyoTmux && ./install.sh
```

Re-run any time to update. The installer:

1. Installs prerequisites if missing — `tmux`, `git`, `fzf`, `less` (and `xclip`
   where available) via apt / brew / dnf / pacman / zypper / apk.
2. Symlinks `.tmux.conf` → `~/.tmux.conf` and `tmux/*.sh` → `~/.tmux/`
   (symlinks, so `git pull` updates everything live).
3. Installs [TPM](https://github.com/tmux-plugins/tpm) and all plugins
   (tmux-resurrect, tmux-continuum).
4. Reloads a running tmux server.

## Cheat-sheet

Inside tmux press **`prefix + ?`** for a full, scrollable guide to the custom
and default keys. Highlights:

| Key | Action |
| --- | --- |
| `prefix + j` | fuzzy-jump between sessions |
| `prefix + g` | new window: claude + 2 shells, in a picked/created dir |
| `prefix + a` | cd every pane in the window to a picked/created dir |
| `prefix + \| / -` | split left-right / top-bottom |
| `Alt + arrows` | move between panes (no prefix) |
| `Shift + arrows` | previous / next window (no prefix) |
| `prefix + ?` | this cheat-sheet |

## Layout

```
.tmux.conf        the config (prefix is the first setting — edit to taste)
tmux/             helper scripts, symlinked into ~/.tmux/ by the installer
  tmux-window-label.sh   window labels: git branch / SHA / dir name
  tmux-pick-dir.sh       fzf directory picker (pick or type-to-create)
  tmux-ensure-dir.sh     confirm-and-create for typed paths
  tmux-new-project.sh    the prefix+g layout
  tmux-cd-all.sh         the prefix+a bulk-cd
  tmux-help.sh           the prefix+? cheat-sheet
install.sh        the installer (host it anywhere; pulls files from GitHub)
```

## Notes

- **Changing the prefix:** edit the single `set -g prefix C-a` line at the top of
  `.tmux.conf`. The popups and cheat-sheet read it live, so nothing else changes.
- **`prefix + g` dependency:** it launches `IS_SANDBOX=1 claude-shared
  --dangerously-skip-permissions`, which relies on a `claude-shared` shell
  function defined in my `.zshrc` (not in this repo). Bring that along, or edit
  `tmux/tmux-new-project.sh` to run whatever command you use.
- **Clipboard:** copies reach the local clipboard via OSC 52, so it works over
  SSH as long as your terminal supports it (iTerm2, kitty, WezTerm, Windows
  Terminal, Ghostty, …).
- **Session restore on first launch:** this config sets `@continuum-restore 'on'`
  and `@continuum-boot 'on'`, so tmux-continuum restores your last saved session
  layout when the tmux server starts, and (per `@resurrect-processes`) relaunches
  `node`, `npm`, etc. On a brand-new machine nothing is saved yet, so nothing
  happens — but if you carry over saved state, expect a burst of restored
  processes on the first `tmux` launch. The installer itself never starts a
  server, so installing is always quiet; restore only fires when *you* start tmux.
