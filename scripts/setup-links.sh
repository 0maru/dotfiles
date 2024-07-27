#!/usr/bin/env bash
set -x

/bin/bash "$(dirname "$0")/preset.sh"

mkdir -p "$XDG_CONFIG_HOME"

ln -sfv "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"
ln -sfv "$REPO_DIR/config/"* "$XDG_CONFIG_HOME"
