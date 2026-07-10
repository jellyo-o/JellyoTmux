#!/bin/sh
# Ensure a directory exists before it's used.
#   - if it already exists: succeed silently (exit 0)
#   - if it doesn't: ask for a single-key confirmation (guards typos); create
#     with mkdir -p on 'y', otherwise abort (exit 1)
# $1 = path
dir="$1"
[ -z "$dir" ] && exit 1
[ -d "$dir" ] && exit 0

if "$HOME/.tmux/tmux-confirm.sh" "Create new directory '$dir'? [y/N] "; then
  mkdir -p "$dir" && exit 0
fi
exit 1
