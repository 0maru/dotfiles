#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/preset.sh
source "$(dirname "$0")/preset.sh"

mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_CONFIG_HOME/pnpm" \
  "$HOME/.local/bin" \
  "$HOME/.claude" \
  "$HOME/.codex"

# AI 操作用のグローバル Playwright 更新コマンド
ln -sfv "$SCRIPTS_DIR/update-playwright" "$HOME/.local/bin/update-playwright"

# リポジトリの config ディレクトリにあるファイルを XDG_CONFIG_HOME にシンボリックリンクを貼る
for config_path in "$REPO_DIR"/config/*; do
  config_name="$(basename "$config_path")"
  [ "$config_name" = "pnpm" ] && continue
  ln -sfv "$config_path" "$XDG_CONFIG_HOME"
done

# pnpm は既存ディレクトリを残して rc だけ管理する
ln -sfv "$REPO_DIR/config/pnpm/rc" "$XDG_CONFIG_HOME/pnpm/rc"
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

# commands / hooks / agents は per-entry symlink ではなくディレクトリ単位の
# symlink にする。skills は gh skill install で管理するためここでは触らない。
#
# 旧構成からの移行時は既存ディレクトリの中身が全て symlink（dotfiles 由来）であることを
# 確認してから削除する。dotfiles 外の実体（手動配置ファイル等）
# が残っていたら停止して人手対応を促す。
for claude_dir in commands hooks agents; do
  target="$HOME/.claude/$claude_dir"
  if [ -d "$target" ] && [ ! -L "$target" ]; then
    extras=$(find "$target" -mindepth 1 -maxdepth 1 ! -type l 2>/dev/null || true)
    if [ -n "$extras" ]; then
      echo "ERROR: $target に dotfiles 外の実体が残っています:" >&2
      echo "$extras" >&2
      echo "  -> 必要なら config/claude/$claude_dir/ に移し、不要なら削除してから再実行してください" >&2
      exit 1
    fi
    rm -rf "$target"
  fi
  ln -sfn "$XDG_CONFIG_HOME/claude/$claude_dir" "$target"
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

# Codex rules はディレクトリ単位 symlink にする。
for codex_subdir in rules; do
  target="$HOME/.codex/$codex_subdir"
  if [ -d "$target" ] && [ ! -L "$target" ]; then
    extras=$(find "$target" -mindepth 1 -maxdepth 1 ! -type l 2>/dev/null || true)
    if [ -n "$extras" ]; then
      echo "ERROR: $target に dotfiles 外の実体が残っています:" >&2
      echo "$extras" >&2
      echo "  -> 必要なら config/codex/$codex_subdir/ に移し、不要なら削除してから再実行してください" >&2
      exit 1
    fi
    rm -rf "$target"
  fi
  ln -sfn "$XDG_CONFIG_HOME/codex/$codex_subdir" "$target"
done
