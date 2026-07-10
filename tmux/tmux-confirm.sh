#!/bin/sh
# Single-keypress yes/no confirm. Prints the prompt ($1), then reads ONE key
# without waiting for Enter. Exit 0 only if 'y' or 'Y'; any other key -> exit 1.
# Falls back to a normal line read if stdin isn't a terminal.
printf '%s' "$1"
if old=$(stty -g 2>/dev/null); then
  stty -icanon -echo min 1 time 0 2>/dev/null   # raw-ish: 1 char, no echo, keep Ctrl-C
  ans=$(dd bs=1 count=1 2>/dev/null)
  stty "$old" 2>/dev/null
  printf '%s\n' "$ans"                          # echo the key + newline (echo was off)
else
  read ans                                      # no tty -> line read
fi
case "$ans" in
  y|Y) exit 0 ;;
  *)   exit 1 ;;
esac
