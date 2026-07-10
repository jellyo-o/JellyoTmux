# Work log

Append-only history of changes made to this repo, newest entries at the bottom.
Written so a future agent can catch up from this file alone without re-reading
the whole config.

## 2026-07-11 — Fix prefix+j switching the wrong client when two clients share a session

**Problem reported.** With two SSH clients attached to the same tmux user (one
shared server), when both were attached to the *same* session, pressing
`prefix + j` (the fuzzy session jumper) sometimes switched the *other* user's
client to the picked session instead of your own. It was intermittent.

**Root cause.** The old binding ran, inside a `display-popup`, a bare
`tmux switch-client -t <target>` with no `-c`. A bare `switch-client` has no
client attached to the invoking command, so tmux resolves the "current client"
to the most recently active client on that session. When two clients share the
session, that can be the other device, so your pick moved them. When the two
clients were on different sessions, resolution was unambiguous, which is why it
only happened "sometimes".

**Things verified on a throwaway isolated server (`tmux -L ...`), not the real one:**
- `display-popup -e "VAR=#{client_name}"` does NOT format-expand the value (got
  the literal `#{client_name}`), so the client cannot be injected via `-e`.
- The `display-popup` shell-command body is also NOT format-expanded.
- `set -gF @opt "#{client_name}"` DOES expand, and reads back via
  `show -gqv @opt`.
- `switch-client -c <client> -t <session>` targets exactly that client.

**Fix.** In `.tmux.conf`, the `prefix + j` binding now captures the pressing
client and current session at key-press time (where the client is unambiguous),
then pins the switch to that client:

```
bind j set -gF @jc "#{client_name}" \; set -gF @js "#{session_name}" \; display-popup -E -w 50% -h 50% \
  'C=$(tmux show -gqv @jc); S=$(tmux show -gqv @js); tmux list-sessions -F "#{session_name}" | grep -vxF "$S" | fzf --reverse --prompt="switch session> " | xargs -r tmux switch-client -c "$C" -t'
```

Key points for future edits:
- The capture MUST happen at key-press time (`set -gF ...` before the popup),
  because neither `-e` nor the command body expand formats.
- `@jc`/`@js` are global options, so two people pressing `prefix + j` at the
  exact same moment could race on them. Acceptable for now; revisit only if it
  bites.

**Not changed.** `prefix + s` (`choose-tree`) still renders on both screens when
two clients share a session, because a mode lives on the shared pane. That is
display-only and switches only the acting client, so it was left alone. The way
to avoid seeing each other entirely is to not share a session.

**Files changed.** `.tmux.conf` (prefix+j binding + comment). `~/.tmux.conf` on
this host was updated to match and the running server reloaded with
`tmux source-file`.

**How to verify live.** With both clients attached to the same session, press
`prefix + j` and confirm only your own client moves (`tmux list-clients` shows
the other client unchanged).
