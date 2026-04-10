#!/bin/bash
# VSCode パターンで stop-notification.sh をテストする
# 使い方: bash tests/hooks/test-notification-vscode.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_SCRIPT="$REPO_ROOT/config/claude/hooks/stop-notification.sh"

echo "=== stop-notification.sh テスト (VSCode パターン) ==="
echo ""

if ! command -v terminal-notifier &>/dev/null; then
  echo "⚠ terminal-notifier が見つかりません (brew install terminal-notifier)"
  echo "  bash -x によるトレースのみ実行します"
fi

echo "環境変数:"
echo "  TERM_PROGRAM=vscode"
echo "  __CFBundleIdentifier=com.microsoft.VSCode"
echo "  PWD=$REPO_ROOT"
echo ""
echo "--- 実行トレース ---"

export TERM_PROGRAM=vscode
export __CFBundleIdentifier=com.microsoft.VSCode
unset WEZTERM_PANE 2>/dev/null || true

cd "$REPO_ROOT"
bash -x "$HOOK_SCRIPT"
EXIT_CODE=$?

echo ""
echo "--- 結果 ---"
echo "終了コード: $EXIT_CODE"
