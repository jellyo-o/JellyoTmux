#!/bin/sh
# Fuzzy-pick a directory under ~ (noise/build/cache dirs pruned), OR type a
# path that doesn't exist yet and press Enter to have the caller create it.
# Prints the chosen path (absolute). $1 = fzf prompt string.
res=$(find "$HOME" -type d \( \
    -name .git -o -name node_modules -o -name .cache -o -name __pycache__ \
    -o -name .venv -o -name venv -o -name miniforge3 -o -name Steam \
    -o -name go -o -name .cargo -o -name .rustup -o -name .npm \
    -o -name .pnpm-store -o -name dist -o -name build -o -name .next \
    -o -name target \
  \) -prune -o -type d -print 2>/dev/null \
  | fzf --reverse --print-query --prompt="$1")
code=$?

# 130 = user aborted (Esc / Ctrl-C) -> signal cancel to the caller
[ "$code" -eq 130 ] && exit 1

sel=$(printf '%s\n' "$res" | sed -n '2p')   # highlighted selection, if any
q=$(printf '%s\n' "$res" | sed -n '1p')     # typed query (used to create a new dir)
choice=${sel:-$q}
[ -z "$choice" ] && exit 1

# Absolutize a typed relative path (e.g. "gh-projs/newthing" -> ~/gh-projs/newthing)
case "$choice" in
  /*) : ;;
  *)  choice="$HOME/$choice" ;;
esac

printf '%s\n' "$choice"
