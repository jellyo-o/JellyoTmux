#!/bin/sh
# Fuzzy-pick a session to kill, with a single-key confirmation. Excludes the
# current session (kill the one you're in via  prefix + :  then  k<enter>).
cur=$(tmux display-message -p '#S')
target=$(tmux list-sessions -F '#S' | grep -vxF "$cur" \
  | fzf --reverse --prompt='kill session> ')
[ -z "$target" ] && exit 0

if "$HOME/.tmux/tmux-confirm.sh" "Kill session '$target'? [y/N] "; then
  tmux kill-session -t "=$target"
fi
