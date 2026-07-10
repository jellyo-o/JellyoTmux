#!/bin/sh
# Curated tmux cheat-sheet, shown in a popup via `prefix + ?`.
# The prefix is read live from tmux, so it stays correct if you ever change it.
# Scroll with arrows / PgUp / PgDn; press q to close.
pfx=$(tmux show -g prefix 2>/dev/null | awk '{print $2}')
[ -z "$pfx" ] && pfx="C-a"

pager="less -R"
command -v less >/dev/null 2>&1 || pager="cat"

{
cat <<EOF

  ===============================================================
   tmux cheat-sheet          PREFIX = $pfx
  ===============================================================

   <p>  = press the prefix ($pfx), release, then the next key.
   Keys marked (no prefix) are pressed directly.

  -- YOUR CUSTOM SHORTCUTS --------------------------------------
   <p> r        reload this config
   <p> |        split pane left / right
   <p> -        split pane top / bottom
   Alt+arrows   move between panes             (no prefix)
   Shift+ < >   previous / next window         (no prefix)
   <p> Tab      flip to last-used session (Alt-Tab-style toggle)
   <p> j        jump to a session (fuzzy picker)
   <p> g        new SESSION: claude + 2 shells (pick/create a dir)
   <p> a        cd every pane in the window to a dir
   <p> .        move this window to another session (pick/create)
   <p> X        pick a session to kill (with confirm)
   <p> Enter    floating scratch shell in the current dir
   <p> ?        show this guide

  -- SESSIONS  (you run one per project) ------------------------
   <p> Tab      flip to last-used session (toggle)  (custom)
   <p> j        fuzzy session switcher             (custom)
   <p> s        session / window tree + preview
   <p> d        detach (leaves everything running)
   <p> \$        rename current session
   <p> ( / )    previous / next session
   <p> : n      new session   (alias, then Enter)
   <p> : k      kill session  (alias, then Enter)

  -- WINDOWS ----------------------------------------------------
   <p> c        new window
   <p> n / p    next / previous window   (also Shift+ < / > )
   <p> 1..9     jump to window N         (numbering starts at 1)
   <p> ,        rename window
   <p> w        window tree (across all sessions)
   <p> f        find window by text
   <p> &        kill window
   <p> l        last (previously used) window

  -- PANES ------------------------------------------------------
   <p> | / -    split left-right / top-bottom      (custom)
   Alt+arrows   focus pane by direction  (no prefix, custom)
   <p> z        zoom pane (toggle fullscreen)
   <p> Space    cycle through layouts
   <p> { / }    swap pane with previous / next
   <p> !        break pane out into its own window
   <p> x        kill pane
   <p> q        show pane numbers (type one to jump)
   <p> Ctrl+arrows   resize pane (hold to repeat)
   mouse        click to focus, drag borders to resize

  -- COPY / SCROLLBACK  (vi keys) -------------------------------
   <p> [        enter copy mode (scroll back through history)
   hjkl/arrows  move        PgUp / PgDn  page up / down
   /  then Enter   search forward     ?  search backward
   v            start selection
   Ctrl-v       block / column selection
   y            copy selection to system clipboard and exit
   q            quit copy mode
   <p> ]        paste

  -- MISC -------------------------------------------------------
   <p> :        command prompt
   <p> t        big clock
   <p> ?        this guide (replaces the default raw key list)
   full raw key list:  <p> :  then type  list-keys

   (scroll with arrows / PgUp / PgDn   -   press q to close)

EOF
} | $pager
