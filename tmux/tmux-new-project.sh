#!/bin/sh
# Pick an existing directory OR type a new path (confirmed before creating),
# then open it as a NEW SESSION (named after the directory), laid out as:
#   left  = claude   (IS_SANDBOX=1 claude-shared --dangerously-skip-permissions)
#   right = two stacked shells
# Switches to the new session. If one with that name already exists, just
# switches to it instead of making a duplicate.
dir=$("$HOME/.tmux/tmux-pick-dir.sh" 'project (type a new name to create)> ') || exit 0
[ -z "$dir" ] && exit 0
"$HOME/.tmux/tmux-ensure-dir.sh" "$dir" || exit 0

# Session names can't contain . : or spaces — sanitise the dir basename.
name=$(basename "$dir" | tr ' .:/' '____')

if tmux has-session -t "=$name" 2>/dev/null; then
  tmux switch-client -t "=$name"
  exit 0
fi

tmux new-session -d -s "$name" -c "$dir"
tmux split-window  -h -t "$name" -c "$dir"
tmux split-window  -v -t "$name" -c "$dir"
tmux select-pane   -t "$name" -L
tmux send-keys     -t "$name" "IS_SANDBOX=1 claude-shared --dangerously-skip-permissions" Enter
tmux switch-client -t "$name"
