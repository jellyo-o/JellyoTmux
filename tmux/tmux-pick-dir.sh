#!/bin/sh
# Fuzzy-pick a directory under ~ (noise/build/cache dirs pruned).
#   Enter    -> open the highlighted match (normal fuzzy search/select)
#   Ctrl-X   -> create a NEW dir from EXACTLY what you typed, even when it
#               partially matches an existing entry in the list
# Prints the chosen path (absolute). $1 = fzf prompt string.
res=$(find "$HOME" -type d \( \
    -name .git -o -name node_modules -o -name .cache -o -name __pycache__ \
    -o -name .venv -o -name venv -o -name miniforge3 -o -name Steam \
    -o -name go -o -name .cargo -o -name .rustup -o -name .npm \
    -o -name .pnpm-store -o -name dist -o -name build -o -name .next \
    -o -name target \
  \) -prune -o -type d -print 2>/dev/null \
  | fzf --reverse --print-query --expect=ctrl-x \
        --header='Enter = open highlighted     Ctrl-X = create what you typed' \
        --prompt="$1")
code=$?

# 130 = user aborted (Esc / Ctrl-C) -> signal cancel to the caller
[ "$code" -eq 130 ] && exit 1

# With --print-query --expect, fzf prints three things in order:
query=$(printf '%s\n' "$res" | sed -n '1p')   # 1) what you typed
key=$(printf '%s\n'   "$res" | sed -n '2p')   # 2) 'ctrl-x' if create was pressed, else empty
sel=$(printf '%s\n'   "$res" | sed -n '3p')   # 3) the highlighted match, if any

if [ "$key" = ctrl-x ]; then
  choice=$query                               # force a new dir from the typed text
else
  choice=${sel:-$query}                       # Enter: the match, or the query if nothing matched
fi
[ -z "$choice" ] && exit 1

# Absolutize a typed relative path (e.g. "gh-projs/newthing" -> ~/gh-projs/newthing)
case "$choice" in
  /*) : ;;
  *)  choice="$HOME/$choice" ;;
esac

printf '%s\n' "$choice"
