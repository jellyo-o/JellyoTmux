#!/bin/sh
# Pick an existing directory OR type a new path (confirmed before creating),
# then open a new window laid out as:
#   left  = claude   (IS_SANDBOX=1 claude-shared --dangerously-skip-permissions)
#   right = two stacked shells
# All three panes start in the chosen directory.
dir=$("$HOME/.tmux/tmux-pick-dir.sh" 'project (type a new name to create)> ') || exit 0
[ -z "$dir" ] && exit 0
"$HOME/.tmux/tmux-ensure-dir.sh" "$dir" || exit 0

tmux new-window -c "$dir" \; \
  split-window -h -c "$dir" \; \
  split-window -v -c "$dir" \; \
  select-pane -L \; \
  send-keys "IS_SANDBOX=1 claude-shared --dangerously-skip-permissions" Enter
