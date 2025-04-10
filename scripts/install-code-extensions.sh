#! /bin/bash
set -x

source "$(dirname "$0")/preset.sh"

# config/code/extensions.ymlを読み込む
extensions=$(yq '.extensions[]' "$REPO_DIR/config/vscode/extensions.yml")

# 拡張機能をインストールする
for extension in $extensions; do
  if hash code 2>/dev/null; then
    code --install-extension $extension
  fi
  if hash code-insiders 2>/dev/null; then
    code-insiders --install-extension $extension
  fi
  if hash cursor 2>/dev/null; then
    cursor --install-extension $extension
  fi
done

