#!/usr/bin/env bash

# Screenshots フォルダがなければ作成する
if [ ! -d ~/Screenshots ]; then
  mkdir ~/Screenshots
fi
# スクリーンショットの保存先を ~/Screenshots フォルダに変更する
defaults write com.apple.screencapture location ~/Screenshots
# dock は自動で隠す
defaults write com.apple.dock autohide -bool TRUE
# ネットワークディスクで.DS_Store ファイルを作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TREU

killall Dock
killall Finder
killall SystemUIServer
