#!/bin/sh
# Pick an existing directory OR type a new path (confirmed before creating),
# then cd EVERY pane in the current window into it.
# The leading space keeps the cd out of shell history (HIST_IGNORE_SPACE).
dir=$("$HOME/.tmux/tmux-pick-dir.sh" 'cd all panes (type a new name to create)> ') || exit 0
[ -z "$dir" ] && exit 0
"$HOME/.tmux/tmux-ensure-dir.sh" "$dir" || exit 0

for p in $(tmux list-panes -F '#{pane_id}'); do
  tmux send-keys -t "$p" " cd '$dir'" Enter
done
