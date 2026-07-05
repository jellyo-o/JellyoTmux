#!/bin/sh
# JellyoTmux installer — sets up tmux config, helper scripts, prerequisites,
# TPM and all plugins in one shot.
#
#   Remote (one-liner) — from your own domain or GitHub, either works:
#     curl -fsSL https://jellyo.net/tmux-config.sh | sh          # your domain
#     curl -fsSL https://raw.githubusercontent.com/jellyo-o/JellyoTmux/main/install.sh | sh
#
#   From a clone:
#     git clone https://github.com/jellyo-o/JellyoTmux.git
#     cd JellyoTmux && ./install.sh
#
# This script is host-agnostic: wherever it's served from, the actual config
# files are always pulled fresh from GitHub (REPO_URL below), so GitHub stays
# the single source of truth. Point your domain path at the GitHub raw URL
# (redirect/proxy) so it always serves the latest.
#
# Re-run any time to update (the remote path does a git pull automatically).

REPO_URL="https://github.com/jellyo-o/JellyoTmux.git"
CLONE_DIR="$HOME/.jellyotmux"

say()  { printf '==> %s\n' "$1"; }
warn() { printf '  ! %s\n' "$1" >&2; }

# ---------------------------------------------------------------------------
# 0. Confirm before touching anything (skip with JELLYOTMUX_YES=1).
# ---------------------------------------------------------------------------
if [ -z "$JELLYOTMUX_YES" ]; then
  cat <<'SUMMARY'

  JellyoTmux installer — this will:
    - link ~/.tmux.conf + helper scripts into ~/.tmux/
    - install any missing prereqs (tmux, git, fzf, less)
    - install TPM + plugins (tmux-resurrect, tmux-continuum)
  It does NOT start tmux or restore any sessions.

SUMMARY
  if [ -r /dev/tty ]; then          # read the key even though stdin is the curl pipe
    printf '  Proceed? [y/N] '
    read ans </dev/tty
    case "$ans" in
      y|Y|yes|YES) ;;
      *) printf '  Aborted.\n'; exit 0 ;;
    esac
  else
    say "non-interactive shell (no /dev/tty) — proceeding"
  fi
fi

# ---------------------------------------------------------------------------
# 1. Prerequisites: tmux, git, fzf, less (xclip optional). Best-effort install.
# ---------------------------------------------------------------------------
PKG=""
if   command -v apt-get >/dev/null 2>&1; then PKG="apt-get install -y"
elif command -v brew    >/dev/null 2>&1; then PKG="brew install"
elif command -v dnf     >/dev/null 2>&1; then PKG="dnf install -y"
elif command -v pacman  >/dev/null 2>&1; then PKG="pacman -S --noconfirm"
elif command -v zypper  >/dev/null 2>&1; then PKG="zypper install -y"
elif command -v apk     >/dev/null 2>&1; then PKG="apk add"
fi
SUDO=""
[ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"

install_pkg() {  # $1 = command to check, $2 = package name, $3 = "optional" (skip warn on fail)
  command -v "$1" >/dev/null 2>&1 && return 0
  if [ -z "$PKG" ]; then
    [ "$3" = optional ] || warn "please install '$2' manually (no known package manager found)"
    return 1
  fi
  say "Installing $2"
  case "$PKG" in
    brew*) $PKG "$2" >/dev/null 2>&1 ;;      # brew must not run under sudo
    *)     $SUDO $PKG "$2" >/dev/null 2>&1 ;;
  esac
  command -v "$1" >/dev/null 2>&1 || { [ "$3" = optional ] || warn "could not install $2"; return 1; }
}

install_pkg git   git
install_pkg tmux  tmux
install_pkg fzf   fzf
install_pkg less  less
install_pkg xclip xclip optional   # only used when tmux runs locally under X

command -v git >/dev/null 2>&1 || { warn "git is required and missing — aborting"; exit 1; }

# ---------------------------------------------------------------------------
# 2. Source files: use this checkout if we're inside one, else clone the repo.
# ---------------------------------------------------------------------------
SELF_DIR=$(CDPATH= cd -- "$(dirname -- "$0" 2>/dev/null)" 2>/dev/null && pwd)
if [ -n "$SELF_DIR" ] && [ -f "$SELF_DIR/tmux/tmux-help.sh" ] && [ -f "$SELF_DIR/.tmux.conf" ]; then
  SRC="$SELF_DIR"
  say "Installing from local checkout: $SRC"
elif [ -d "$CLONE_DIR/.git" ]; then
  say "Updating existing clone: $CLONE_DIR"
  git -C "$CLONE_DIR" pull --ff-only >/dev/null 2>&1 || warn "git pull failed; using existing copy"
  SRC="$CLONE_DIR"
else
  say "Cloning $REPO_URL -> $CLONE_DIR"
  git clone --depth 1 "$REPO_URL" "$CLONE_DIR" || { warn "clone failed — aborting"; exit 1; }
  SRC="$CLONE_DIR"
fi

# ---------------------------------------------------------------------------
# 3. Link config + helper scripts into place (symlinks, so `git pull` updates).
# ---------------------------------------------------------------------------
say "Linking ~/.tmux.conf and ~/.tmux/*.sh"
mkdir -p "$HOME/.tmux"
ln -sfn "$SRC/.tmux.conf" "$HOME/.tmux.conf"
for f in "$SRC"/tmux/*.sh; do
  chmod +x "$f" 2>/dev/null
  ln -sfn "$f" "$HOME/.tmux/$(basename "$f")"
done

# ---------------------------------------------------------------------------
# 4. TPM + plugins — cloned DIRECTLY (this script never starts a tmux server).
#
#    Why not TPM's install_plugins? It needs a running server that has loaded
#    the config, and this config sets @continuum-restore 'on'. Starting a fresh
#    server would make tmux-continuum immediately restore every saved session
#    and re-spawn all their processes — a big CPU/memory spike. A plain git
#    clone into ~/.tmux/plugins/<name> is exactly what TPM does, minus the
#    server, so it's equivalent and safe.
# ---------------------------------------------------------------------------
say "Installing TPM + plugins (direct clone — no tmux server started)"
mkdir -p "$HOME/.tmux/plugins"

clone_plugin() {  # $1 = owner/repo
  dest="$HOME/.tmux/plugins/$(basename "$1")"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only >/dev/null 2>&1 || true
  else
    say "  + $1"
    git clone --depth 1 "https://github.com/$1" "$dest" >/dev/null 2>&1 \
      || warn "failed to clone $1"
  fi
}

# TPM itself, plus every @plugin 'owner/repo' declared in the config.
clone_plugin tmux-plugins/tpm
grep -E "^[[:space:]]*set(-option)?[[:space:]]+-g[[:space:]]+@plugin[[:space:]]" "$SRC/.tmux.conf" 2>/dev/null \
  | sed -E "s/.*@plugin[[:space:]]+['\"]([^'\"]+)['\"].*/\1/" \
  | while IFS= read -r repo; do
      [ -n "$repo" ] && [ "$repo" != tmux-plugins/tpm ] && clone_plugin "$repo"
    done

# ---------------------------------------------------------------------------
# 5. Finish — intentionally NO tmux commands here (no source-file, no
#    new-session), so nothing can trigger continuum-restore.
# ---------------------------------------------------------------------------
say "Done."
printf '\n'
printf 'Next steps:\n'
printf '  - Start tmux — plugins load automatically.\n'
printf '  - Already inside tmux? Reload with:  prefix + r   (prefix is Ctrl-a)\n'
printf '  - Press  prefix + ?  for the cheat-sheet.\n'
