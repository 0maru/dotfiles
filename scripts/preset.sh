#!/usr/bin/env bash
set -euo pipefail

# scripts の中にあるスクリプトを実行するとき、一番最初に実行するスクリプト
# スクリプトの実行に必要な変数を定義する

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1 && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." || exit 1 && pwd)"

export SCRIPTS_DIR="$SCRIPT_DIR"
export REPO_DIR
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
