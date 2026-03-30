#!/bin/bash
# Notify on Claude Code stop and activate the source terminal/editor on click.
# Requires: brew install terminal-notifier

command -v terminal-notifier &>/dev/null || exit 0

PROJECT_NAME="$(basename "$PWD")"
PROJECT_DIR="$PWD"
ACTIVATE_ARGS=()

case "$TERM_PROGRAM" in
  WezTerm)
    PANE_ID="${WEZTERM_PANE:-}"
    if [ -n "$PANE_ID" ] && command -v wezterm &>/dev/null; then
      # Bring WezTerm to front, then switch to the exact pane/tab
      ACTIVATE_ARGS=(-execute "open -a WezTerm; wezterm cli activate-pane --pane-id ${PANE_ID}")
    else
      ACTIVATE_ARGS=(-activate "com.github.wez.wezterm")
    fi
    ;;
  vscode)
    if command -v code &>/dev/null; then
      ACTIVATE_ARGS=(-execute "code \"${PROJECT_DIR}\"")
    else
      ACTIVATE_ARGS=(-activate "com.microsoft.VSCode")
    fi
    ;;
  *)
    exit 0
    ;;
esac

terminal-notifier \
  -title "Claude Code" \
  -subtitle "$PROJECT_NAME" \
  -message "応答完了" \
  "${ACTIVATE_ARGS[@]}" \
  -sound default \
  -ignoreDnD
