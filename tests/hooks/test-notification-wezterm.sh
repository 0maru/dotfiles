#!/bin/bash
# WezTerm パターンで stop-notification.sh をテストする
# 使い方: bash tests/hooks/test-notification-wezterm.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_SCRIPT="$REPO_ROOT/config/claude/hooks/stop-notification.sh"

echo "=== stop-notification.sh テスト (WezTerm パターン) ==="
echo ""

if ! command -v terminal-notifier &>/dev/null; then
  echo "⚠ terminal-notifier が見つかりません (brew install terminal-notifier)"
  echo "  bash -x によるトレースのみ実行します"
fi

echo "環境変数:"
echo "  TERM_PROGRAM=WezTerm"
echo "  WEZTERM_PANE=0"
echo "  __CFBundleIdentifier=com.github.wez.wezterm"
echo "  PWD=$REPO_ROOT"
echo ""
echo "--- 実行トレース ---"

export TERM_PROGRAM=WezTerm
export WEZTERM_PANE=0
export __CFBundleIdentifier=com.github.wez.wezterm

cd "$REPO_ROOT"
bash -x "$HOOK_SCRIPT"
EXIT_CODE=$?

echo ""
echo "--- 結果 ---"
echo "終了コード: $EXIT_CODE"
