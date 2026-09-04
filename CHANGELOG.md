# Changelog

## v1.1.1

Bugfix: `bar-fill` / `bar-outline` / `accent-outline-bar` were silently
falling back to **accent** on stock themes instead of the bar's real colour
(worked correctly on a fully custom theme like a hand-authored one, since
those ship their own `shell.toml`). Two stacked causes, both fixed:

- `palette()` now reads the bar's colour from the theme's own `shell.toml`
  when it ships one, otherwise - only while that theme is the one actually
  active - from the *staged*, fully-merged
  `~/.local/state/omarchy/current/theme/shell.toml`, which is ground truth
  for every stock theme (none of which ship a `shell.toml` of their own).
- The colour-resolution fallback chain no longer defaults to accent for
  any slot but the literal `accent` one; everything else falls back to a
  neutral background instead.
- The `theme-set` hook no longer names the theme when calling `sync` -
  Omarchy has already staged it by the time the hook runs, so reading
  "current" is simpler and exactly as correct.
- CI: a dedicated regression test with a fixture where the bar colour
  deliberately differs from the background, so this class of bug can't
  silently pass again.

## v1.1.0

- Two more colour presets that drop the accent entirely: `bar-fill` and
  `bar-outline`, pairing the top bar's *real* colour (`shell.toml`'s
  `[bar].background`) with a computed dark/light neutral instead - six
  presets total now.
- `base`/`outline` colour resolution generalised so `"auto"` works on
  either slot (previously outline-only); the four v1.0.0 presets are
  unchanged bit-for-bit.
- README badges (release, license).

## v1.0.0

First release.

- Dyes the mouse pointer to the active Omarchy theme's palette, compiled as a
  single `omarchy-dye` cursor theme in **both** hyprcursor (vector) and
  XCursor (rasterised via `rsvg-convert` + `xcursorgen`) formats.
- Four colour presets - `accent-fill`, `accent-outline`, `accent-fill-bar`,
  `accent-outline-bar` - mixing the theme's accent, foreground, and the top
  bar's *actual* colour (read straight from `shell.toml`, not computed).
  Any of the three slots (`base` / `outline` / `watch`) can be overridden with
  a palette key or a literal hex colour.
- `style`: `modern` / `original` Bibata silhouette, each with a mirrored
  left-handed (`-right`) variant.
- Configurable size, applied live and persisted across logins.
- `~/.config/omarchy/hooks/theme-set.d` hook re-dyes on every
  `omarchy theme set`; builds are cached per colour set (well under a second,
  instant on a repeat).
- CLI: `sync`, `build`, `apply`, `status`, `clear-cache`, `config`, `env`.
- Idempotent `install.sh` / `uninstall.sh` (`--keep-config`), nothing touches
  files outside `~/.local` and `~/.config`.
