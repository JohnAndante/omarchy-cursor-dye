# Security policy

omarchy-cursor-dye is a local command-line tool: it reads files under
`~/.config` and `~/.local`, shells out to `hyprcursor-util`, `rsvg-convert`
and `xcursorgen`, and writes a cursor theme under `~/.local/share/icons`.
Nothing here runs with elevated privileges, listens on a network port, or
talks to a remote service at runtime.

## Reporting a vulnerability

Please use GitHub's private **[Report a vulnerability](../../security/advisories/new)**
form (Security tab → Advisories) rather than a public issue, so a fix can go
out before the details are public. If that's not an option, open an issue
without exploit details and ask for a private channel.

There's no bug bounty - this is a personal project - but reports are
genuinely welcome and I'll credit you in the fix.

## Supply chain

- `install.sh` fetches [Bibata](https://github.com/ful1e5/Bibata_Cursor)'s
  cursor SVGs from a **pinned tag** (`BIBATA_REF` at the top of the script),
  never a branch, so an install always gets the exact bytes that were
  reviewed.
- No step in this repo pipes a remote script into a shell.
- GitHub Actions dependencies are kept current via Dependabot
  (`.github/dependabot.yml`).

## Supported versions

Only the latest release is supported. Please upgrade before reporting an
issue that might already be fixed.
