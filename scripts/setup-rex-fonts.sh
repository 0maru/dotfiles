#!/usr/bin/env bash
set -euo pipefail

# Font preferences are local to the macOS app, not the Rex server init.lua.
# These keys were verified with Rex Beta 0.1.0 (1956).
if [[ $(uname -s) != Darwin ]]; then
  echo "Rex font preferences are only configured on macOS."
  exit 0
fi

rex_domain=com.superlogical.rex
/usr/bin/defaults write "$rex_domain" Workspace.terminalFontName -string "Berkeley Mono"
/usr/bin/defaults write "$rex_domain" Workspace.terminalFontPointSize -float 12
/usr/bin/defaults write "$rex_domain" Workspace.terminalFallbackFontNames -array \
  "Hack Nerd Font" \
  "Zen Kaku Gothic New"

echo "Rex fonts configured: Berkeley Mono 12pt, Hack Nerd Font, Zen Kaku Gothic New."
echo "If Rex is already open, reopen the app to load changed font preferences."
