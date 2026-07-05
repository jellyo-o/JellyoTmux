#!/bin/sh
# Move the CURRENT window into another session — pick an existing session from
# the list, or type a new name to create one. The window follows to its new home.
src=$(tmux display-message -p '#{session_name}:#{window_index}')
cur=$(tmux display-message -p '#{session_name}')

choice=$(tmux list-sessions -F '#{session_name}' \
  | fzf --reverse --print-query --prompt='move window to session> ')
sel=$(printf '%s\n' "$choice" | sed -n '2p')   # highlighted existing session
q=$(printf '%s\n'   "$choice" | sed -n '1p')   # typed name -> create a new session
dest=${sel:-$q}
[ -z "$dest" ] && exit 0
# session names can't contain . : or spaces
dest=$(printf '%s' "$dest" | tr ' .:/' '____')
[ "$dest" = "$cur" ] && exit 0                  # already here — nothing to do

if tmux has-session -t "=$dest" 2>/dev/null; then
  tmux move-window -s "$src" -t "$dest:"
else
  # create the destination session, move our window in, drop the placeholder
  path=$(tmux display-message -p -t "$src" '#{pane_current_path}')
  tmux new-session -d -s "$dest" -c "$path"
  ph=$(tmux display-message -p -t "$dest" '#{window_id}')
  tmux move-window -s "$src" -t "$dest:"
  tmux kill-window -t "$ph" 2>/dev/null
fi
tmux switch-client -t "$dest"
