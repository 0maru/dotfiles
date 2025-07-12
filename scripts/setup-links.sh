#!/usr/bin/env bash
set -x

source "$(dirname "$0")/preset.sh"

mkdir -p "$XDG_CONFIG_HOME"

# リポジトリのconfig ディレクトリにあるファイルをXDG_CONFIG_HOME にシンボリックリンクを貼る
ln -sfv "$REPO_DIR/config/"* "$XDG_CONFIG_HOME"
# シンボリックリンクを貼ったファイルからXDG_CONFIG_HOME 以外に配置しているファイルにもシンボリックリンクを貼る
ln -sfv "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"
ln -sfv "$XDG_CONFIG_HOME/ideavim/.ideavimrc" "$HOME/.ideavimrc"

# VS Code
ln -sfv "$XDG_CONFIG_HOME/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
ln -sfv "$XDG_CONFIG_HOME/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
# VS Code Insiders
ln -sfv "$XDG_CONFIG_HOME/vscode/keybindings.json" "$HOME/Library/Application Support/Code - Insiders/User/keybindings.json"
ln -sfv "$XDG_CONFIG_HOME/vscode/settings.json" "$HOME/Library/Application Support/Code - Insiders/User/settings.json"
# Cursor
ln -sfv "$XDG_CONFIG_HOME/vscode/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
ln -sfv "$XDG_CONFIG_HOME/vscode/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
# Claude Code
ln -sfv "$XDG_CONFIG_HOME/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sfv "$XDG_CONFIG_HOME/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfv "$XDG_CONFIG_HOME/claude/commands/"* "$HOME/.claude/commands/"
