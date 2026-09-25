#!/usr/bin/env bash
set -euo pipefail

command_line_tools_ready() {
  xcode-select --print-path >/dev/null 2>&1 && xcrun --find clang >/dev/null 2>&1
}

if ! command_line_tools_ready; then
  echo "Xcode Command Line Tools をインストールします。表示される画面でインストールを完了してください。"
  if ! xcode-select --install; then
    echo "Command Line Tools のインストールを開始できませんでした。ソフトウェアアップデートと xcode-select の設定を確認してください。" >&2
    exit 1
  fi

  # --install は画面を開くだけなので、Git や Homebrew に進む前に完了を待つ。
  echo "Command Line Tools のインストール完了を待っています（最大30分）。"
  for ((attempt = 0; attempt < 360; attempt++)); do
    if command_line_tools_ready; then
      break
    fi
    sleep 5
  done

  if ! command_line_tools_ready; then
    echo "Command Line Tools の導入を確認できませんでした。インストール完了後に再実行してください。" >&2
    exit 1
  fi
fi

# ローカルの setup スクリプトからも同じ前提チェックを利用する。
if [ "${1:-}" = "--command-line-tools-only" ]; then
  exit 0
fi

INSTALL_DIR="$HOME/workspaces/github.com/0maru/dotfiles"

if [ -d "$INSTALL_DIR" ]; then
  echo -e "\033[32mUpdating dotfiles...\033[m"
  git -C "$INSTALL_DIR" pull --ff-only
else
  echo -e "\033[32mInstalling dotfiles...\033[m"
  git clone https://github.com/0maru/dotfiles "$INSTALL_DIR"
fi

/bin/bash "$INSTALL_DIR/scripts/setup.sh"
