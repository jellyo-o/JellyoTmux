#!/bin/sh
# Ensure a directory exists before it's used.
#   - if it already exists: succeed silently (exit 0)
#   - if it doesn't: ask for confirmation (guards against typos); create with
#     mkdir -p on yes, otherwise abort (exit 1)
# $1 = path
dir="$1"
[ -z "$dir" ] && exit 1
[ -d "$dir" ] && exit 0

printf "Create new directory '%s'? [y/N] " "$dir"
read ans
case "$ans" in
  y|Y|yes|YES) mkdir -p "$dir" && exit 0 || exit 1 ;;
  *) exit 1 ;;
esac
