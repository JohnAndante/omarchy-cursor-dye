#!/bin/bash
# omarchy-cursor-dye installer / updater. Safe to re-run.
set -euo pipefail

BIBATA_REPO="https://github.com/ful1e5/Bibata_Cursor.git"
BIBATA_REF="v2.0.7"   # the release our vendored cursors.toml was distilled from

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-cursor-dye"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy-cursor-dye"
HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
HYPR_DIR="$HOME/.config/hypr"

say()  { printf '\033[36m::\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- dependencies --------------------------------------------------------------
missing=()
for c in git python3 hyprcursor-util rsvg-convert; do
  command -v "$c" >/dev/null || missing+=("$c")
done
command -v xcursorgen >/dev/null || warn "xcursorgen not found - XCursor output will be skipped (pacman -S xorg-xcursorgen)"
command -v xcur2png  >/dev/null || warn "xcur2png not found - hyprcursor-util may need it (pacman -S xcur2png)"

if ((${#missing[@]})); then
  die "missing required tools: ${missing[*]}
  install with:  sudo pacman -S --needed ${missing[*]/python3/python} xorg-xcursorgen xcur2png librsvg hyprcursor"
fi

python3 - <<'PY' || die "python 3.11+ required (need tomllib)"
import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)
PY

# --- Bibata SVG sources -------------------------------------------------------
if [[ -d $DATA_DIR/svg && ${1:-} != "--refresh-svg" ]]; then
  say "Bibata SVGs already present ($DATA_DIR/svg) - pass --refresh-svg to re-fetch"
else
  say "fetching Bibata cursor SVGs ($BIBATA_REF) ..."
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$BIBATA_REF" "$BIBATA_REPO" "$tmp/bibata"
  rm -rf "$DATA_DIR/svg"
  mkdir -p "$DATA_DIR"
  cp -r "$tmp/bibata/svg" "$DATA_DIR/svg"
  rm -rf "$tmp"; trap - EXIT
fi

install -Dm644 "$REPO_DIR/share/cursors.toml" "$DATA_DIR/cursors.toml"
install -Dm644 "$REPO_DIR/share/cursors-right.toml" "$DATA_DIR/cursors-right.toml"

# --- the command -------------------------------------------------------------
mkdir -p "$BIN_DIR"
ln -sf "$REPO_DIR/bin/omarchy-cursor-dye" "$BIN_DIR/omarchy-cursor-dye"
say "linked $BIN_DIR/omarchy-cursor-dye"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) warn "$BIN_DIR is not on your PATH - add it so the hook can find the command" ;;
esac

# --- Omarchy theme-set hook -------------------------------------------------
mkdir -p "$HOOK_DIR"
install -Dm755 "$REPO_DIR/hooks/theme-set.d/50-omarchy-cursor-dye" "$HOOK_DIR/50-omarchy-cursor-dye"
say "installed theme-set hook"

# --- config ----------------------------------------------------------------
if [[ ! -f $CONFIG_DIR/config.toml ]]; then
  install -Dm644 "$REPO_DIR/config.example.toml" "$CONFIG_DIR/config.toml"
  say "wrote default config to $CONFIG_DIR/config.toml"
fi

# --- Hyprland persistence --------------------------------------------------
# Pin the pointer (name + size) so it survives a relogin. Re-running the
# installer refreshes the block, so a size change in config.toml propagates.
manage_block() {
  local file="$1" fmt="$2" open close body
  open=">>> omarchy-cursor-dye >>>"
  close="<<< omarchy-cursor-dye <<<"
  body="$("$BIN_DIR/omarchy-cursor-dye" env --format "$fmt")"

  [[ -f $file ]] && sed -i "/$open/,/$close/d" "$file"

  if [[ $fmt == lua ]]; then
    { printf '\n-- %s\n' "$open"
      printf -- '-- Pins the "omarchy-dye" pointer across logins. Refresh with ./install.sh,\n'
      printf -- '-- remove with ./uninstall.sh.\n'
      printf '%s\n' "$body"
      printf -- '-- %s\n' "$close"
    } >>"$file"
  else
    { printf '\n# %s\n' "$open"; printf '%s\n' "$body"; printf '# %s\n' "$close"; } >>"$file"
  fi
  say "wrote hypr env block to ${file/#$HOME/\~}"
}

if [[ -f $HYPR_DIR/looknfeel.lua ]]; then
  manage_block "$HYPR_DIR/looknfeel.lua" lua
elif [[ -f $HYPR_DIR/hyprland.lua ]]; then
  manage_block "$HYPR_DIR/hyprland.lua" lua
elif [[ -f $HYPR_DIR/hyprland.conf ]]; then
  manage_block "$HYPR_DIR/hyprland.conf" conf
else
  warn "no Hyprland config found in $HYPR_DIR - set HYPRCURSOR_THEME=omarchy-dye yourself"
fi

# --- first run -----------------------------------------------------------
say "building the initial cursor ..."
"$BIN_DIR/omarchy-cursor-dye" sync

cat <<EOF

$(printf '\033[32m✓\033[0m') omarchy-cursor-dye installed.

  omarchy-cursor-dye status      what's applied
  omarchy-cursor-dye sync        rebuild for the current theme
  omarchy-cursor-dye --help      everything else

The pointer re-dyes automatically on your next \`omarchy theme set\`.
Some already-running apps only pick up the new cursor after a restart.
EOF
