#!/usr/bin/env bash
set -x

source "$(dirname "$0")/preset.sh"

mkdir -p "$XDG_CONFIG_HOME"

# リポジトリのconfig ディレクトリにあるファイルをXDG_CONFIG_HOME にシンボリックリンクを貼る
ln -sfv "$REPO_DIR/config/"* "$XDG_CONFIG_HOME"
# シンボリックリンクを貼ったファイルからXDG_CONFIG_HOME 以外に配置しているファイルにもシンボリックリンクを貼る
ln -sfv "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"
ln -sfv "$XDG_CONFIG_HOME/ideavim/.ideavimrc" "$HOME/.ideavimrc"

