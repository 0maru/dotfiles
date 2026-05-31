#!/usr/bin/env bash
set -euo pipefail

# Screenshots フォルダがなければ作成する
mkdir -p "$HOME/Screenshots"

# スクリーンショットの保存先を ~/Screenshots フォルダに変更する
defaults write com.apple.screencapture location "$HOME/Screenshots"
# dock は自動で隠す
defaults write com.apple.dock autohide -bool true
# ネットワークディスクで.DS_Store ファイルを作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

for process in Dock Finder SystemUIServer; do
  killall "$process" 2>/dev/null || true
done
