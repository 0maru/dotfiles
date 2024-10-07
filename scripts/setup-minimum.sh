#!/usr/bin/env bash
set -x

source "$(dirname "$0")/preset.sh"

# ln -sfv "$REPO_DIR/config/git/"* "$XDG_CONFIG_HOME/git"
ln -sfv "$REPO_DIR/config/wezterm" "$XDG_CONFIG_HOME"
