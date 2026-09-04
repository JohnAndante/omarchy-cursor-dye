#!/bin/bash
# Remove omarchy-cursor-dye and restore the default pointer.
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-cursor-dye"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-cursor-dye"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy-cursor-dye"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy-cursor-dye"
BIN="$HOME/.local/bin/omarchy-cursor-dye"
HOOK="$HOME/.config/omarchy/hooks/theme-set.d/50-omarchy-cursor-dye"
ICONS="${XDG_DATA_HOME:-$HOME/.local/share}/icons/omarchy-dye"
HYPR_DIR="$HOME/.config/hypr"

say() { printf '\033[36m::\033[0m %s\n' "$*"; }

KEEP_CONFIG=0
[[ ${1:-} == "--keep-config" ]] && KEEP_CONFIG=1

rm -f  "$BIN" "$HOOK"
rm -rf "$ICONS" "$CACHE_DIR" "$STATE_DIR" "$DATA_DIR"
say "removed command, hook, built theme, cache and data"

if ((! KEEP_CONFIG)); then
  rm -rf "$CONFIG_DIR"
  say "removed $CONFIG_DIR"
fi

# strip the managed hypr block(s)
for f in "$HYPR_DIR"/looknfeel.lua "$HYPR_DIR"/hyprland.lua "$HYPR_DIR"/hyprland.conf; do
  [[ -f $f ]] || continue
  if grep -q 'omarchy-cursor-dye' "$f"; then
    sed -i '/>>> omarchy-cursor-dye >>>/,/<<< omarchy-cursor-dye <<</d' "$f"
    # also drop the lua comment line that precedes the lua marker, if left dangling
    say "cleaned managed block from ${f/#$HOME/\~}"
  fi
done

# point the session back at a stock pointer
if command -v gsettings >/dev/null; then
  gsettings reset org.gnome.desktop.interface cursor-theme 2>/dev/null || true
  gsettings reset org.gnome.desktop.interface cursor-size  2>/dev/null || true
fi
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/default/index.theme"
command -v hyprctl >/dev/null && {
  hyprctl setcursor Adwaita 24 >/dev/null 2>&1 || true
  hyprctl setenv HYPRCURSOR_THEME "" >/dev/null 2>&1 || true
}

cat <<EOF

$(printf '\033[32m✓\033[0m') omarchy-cursor-dye removed.
Log out / back in (or restart Hyprland) to fully clear the pointer env.
The git checkout itself is untouched - delete it if you like.
EOF
