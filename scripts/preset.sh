#!/usr/bin/env bash

# scripts の中にあるスクリプトを実行するとき、一番最初に実行するスクリプト
# スクリプトの実行に必要な変数を定義する

echo "run preset.sh"

set -x

#export SCRIPTS_DIR REPO_DIR

export SCRIPTS_DIR="$(cd "$(dirname $0)" || exit && pwd)"
export REPO_DIR="$(cd "$(dirname $0)/.." || exit && pwd)"

export XDG_CONFIG_HOME="$HOME/.config"
