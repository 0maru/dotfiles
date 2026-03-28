#!/bin/bash
# Notify on Claude Code stop and activate the source terminal on click.
# Requires: brew install terminal-notifier

command -v terminal-notifier &>/dev/null || exit 0

# Resolve bundle ID based on which terminal is running Claude Code
case "$TERM_PROGRAM" in
  WezTerm)    BUNDLE_ID="com.github.wez.wezterm" ;;
  vscode)     BUNDLE_ID="com.microsoft.VSCode" ;;
  *)          BUNDLE_ID="" ;;
esac

[ -z "$BUNDLE_ID" ] && exit 0

terminal-notifier \
  -title "Claude Code" \
  -subtitle "$(basename "$PWD")" \
  -message "応答完了" \
  -activate "$BUNDLE_ID" \
  -sound default \
  -ignoreDnD
