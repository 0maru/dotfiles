#! /bin/bash
set -x

source "$(dirname "$0")/preset.sh"

# config/code/extensions.ymlを読み込む
extensions=$(yq '.extensions[]' "$REPO_DIR/config/code/extensions.yml")

# 拡張機能をインストールする
for extension in $extensions; do
  code --install-extension $extension
  cursor --install-extension $extension
done
