#!/bin/sh
# Fuzzy-pick a session to kill, with confirmation. Excludes the current session
# (kill the one you're in via  prefix + :  then  k<enter>  if you need to).
cur=$(tmux display-message -p '#S')
target=$(tmux list-sessions -F '#S' | grep -vxF "$cur" \
  | fzf --reverse --prompt='kill session> ')
[ -z "$target" ] && exit 0

printf "Kill session '%s'? [y/N] " "$target"
read ans
case "$ans" in
  y|Y|yes|YES) tmux kill-session -t "=$target" ;;
  *) ;;
esac
