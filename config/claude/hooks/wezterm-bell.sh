#!/bin/bash
# Send a BEL (\a) to the controlling terminal so that WezTerm fires its
# `bell` event for the current tab. The tab.lua handler records the tab id
# and renders an unread marker until the tab is activated.
#
# This script is intentionally minimal: WezTerm's bell event is the single
# source of truth, and the visual rendering lives in config/wezterm/tab.lua.

[ "$TERM_PROGRAM" = "WezTerm" ] || exit 0

printf '\a' > /dev/tty 2>/dev/null
exit 0
