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
  case "$config_name" in
    pnpm | homebrew) continue ;;
  esac
  ln -sfv "$config_path" "$XDG_CONFIG_HOME"
done

# Homebrew が作る trust.json などを残し、実ディレクトリには Brewfile だけ配置する。
homebrew_config_dir="$XDG_CONFIG_HOME/homebrew"
if [ -L "$homebrew_config_dir" ]; then
  # 旧構成のリンク先で Brewfile 自体を上書きしないよう、ディレクトリのリンクを更新する。
  ln -sfnv "$REPO_DIR/config/homebrew" "$homebrew_config_dir"
else
  mkdir -p "$homebrew_config_dir"
  ln -sfv "$REPO_DIR/config/homebrew/Brewfile" "$homebrew_config_dir/Brewfile"
fi

# ~/.gitconfig が残っている環境でも agent 用設定が後勝ちするようにする
git config --file "$HOME/.gitconfig" --replace-all \
  'includeIf.onbranch:agent/**.path' "$XDG_CONFIG_HOME/git/conf.d/agent.conf"

# pnpm は既存ディレクトリを残して rc だけ管理する
ln -sfv "$REPO_DIR/config/pnpm/rc" "$XDG_CONFIG_HOME/pnpm/rc"
# シンボリックリンクを貼ったファイルからXDG_CONFIG_HOME 以外に配置しているファイルにもシンボリックリンクを貼る
ln -sfv "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"

# Claude Code
ln -sfv "$XDG_CONFIG_HOME/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sfv "$XDG_CONFIG_HOME/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfv "$XDG_CONFIG_HOME/claude/statusline.ts" "$HOME/.claude/statusline.ts"

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
