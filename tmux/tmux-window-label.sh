#!/bin/sh
# Print the git branch for a directory, or the short SHA if detached,
# or the directory basename if it isn't a git repo. Used by tmux
# window-status-format to auto-label windows by branch.
d="$1"
b=$(git -C "$d" symbolic-ref --short -q HEAD 2>/dev/null)
if [ -n "$b" ]; then
  printf '%s' "$b"
elif s=$(git -C "$d" rev-parse --short HEAD 2>/dev/null) && [ -n "$s" ]; then
  printf ':%s' "$s"
else
  basename "$d"
fi
