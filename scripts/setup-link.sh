#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/preset.sh
source "$(dirname "$0")/preset.sh"

mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$HOME/.claude/commands" \
  "$HOME/.claude/hooks" \
  "$HOME/.claude/skills" \
  "$HOME/.codex" \
  "$HOME/.codex/skills" \
  "$HOME/.codex/rules"

# リポジトリのconfig ディレクトリにあるファイルをXDG_CONFIG_HOME にシンボリックリンクを貼る
ln -sfv "$REPO_DIR/config/"* "$XDG_CONFIG_HOME"
# シンボリックリンクを貼ったファイルからXDG_CONFIG_HOME 以外に配置しているファイルにもシンボリックリンクを貼る
ln -sfv "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"
ln -sfv "$XDG_CONFIG_HOME/ideavim/.ideavimrc" "$HOME/.ideavimrc"

for editor in "Code" "Code - Insiders" "Cursor"; do
  editor_user_dir="$HOME/Library/Application Support/$editor/User"
  mkdir -p "$editor_user_dir"
  ln -sfv "$XDG_CONFIG_HOME/vscode/keybindings.json" "$editor_user_dir/keybindings.json"
  ln -sfv "$XDG_CONFIG_HOME/vscode/settings.json" "$editor_user_dir/settings.json"
done

# Claude Code
ln -sfv "$XDG_CONFIG_HOME/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sfv "$XDG_CONFIG_HOME/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfv "$XDG_CONFIG_HOME/claude/statusline.ts" "$HOME/.claude/statusline.ts"

for claude_dir in commands hooks skills; do
  ln -sfv "$XDG_CONFIG_HOME/claude/$claude_dir/"* "$HOME/.claude/$claude_dir"
done

# Codex
codex_config_src="$XDG_CONFIG_HOME/codex/config.toml"
codex_config_dest="$HOME/.codex/config.toml"

# config.toml は個別に編集できるよう、シンボリックリンクではなく実ファイルで配置する
python3 "$SCRIPTS_DIR/sync-codex-config.py" \
  --source "$codex_config_src" \
  --dest "$codex_config_dest"

ln -sfv "$XDG_CONFIG_HOME/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfv "$XDG_CONFIG_HOME/codex/hooks.json" "$HOME/.codex/hooks.json"

for codex_rule in "$XDG_CONFIG_HOME"/codex/rules/*; do
  [ -e "$codex_rule" ] || continue
  ln -sfv "$codex_rule" "$HOME/.codex/rules"
done

# repo 管理の Codex skill を ~/.codex/skills に追加する
for codex_skill in "$XDG_CONFIG_HOME"/codex/skills/*; do
  [ -e "$codex_skill" ] || continue
  ln -sfv "$codex_skill" "$HOME/.codex/skills"
done
