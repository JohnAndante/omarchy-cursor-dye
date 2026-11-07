#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MENU_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/extensions"
MENU_FILE="$MENU_DIR/omarchy-menu.jsonc"

mkdir -p "$MENU_DIR"

if [[ ! -e $MENU_FILE ]]; then
  install -Dm644 "$REPO_DIR/share/omarchy-menu.jsonc" "$MENU_FILE"
elif ! grep -q 'omarchy-cursor-dye' "$MENU_FILE"; then
  [[ $(tail -n 1 "$MENU_FILE") == "}" ]] || { echo "error: menu extension must end with }" >&2; exit 1; }
  last=$(grep -nE '^[[:space:]]*"[^"]+"[[:space:]]*:' "$MENU_FILE" | tail -n 1 | cut -d: -f1 || true)
  if [[ -n $last ]]; then
    line=$(sed -n "${last}p" "$MENU_FILE")
    [[ $line == *, ]] || sed -i "${last}s/$/,/" "$MENU_FILE"
  fi
  sed -i '$d' "$MENU_FILE"
  sed '1d;$d' "$REPO_DIR/share/omarchy-menu.jsonc" >>"$MENU_FILE"
  printf '}\n' >>"$MENU_FILE"
fi

omarchy menu refresh 2>/dev/null || true
echo "Cursor Dye menu entries installed."
