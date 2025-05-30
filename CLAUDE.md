# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## プロジェクト概要

0maru氏のdotfilesリポジトリで、macOS開発環境を自動的にセットアップするための設定ファイル群です。ターミナル、エディタ、開発ツールの設定を一元管理しています。

## コマンド

### インストール・セットアップ
```bash
# 完全インストール（リポジトリのクローン/更新を含む）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/0maru/dotfiles/main/install.sh)"

# 既存リポジトリからのセットアップ
./scripts/setup.sh

# 個別のセットアップスクリプト
./scripts/setup-brew.sh              # Homebrewとパッケージのインストール
./scripts/setup-links.sh             # シンボリックリンクの作成
./scripts/install-code-extensions.sh # VS Code拡張機能のインストール
```

### 設定の更新
```bash
# Brewfile修正後
brew bundle --file=config/homebrew/Brewfile

# 全ghqリポジトリの更新
ghq list | ghq get --update --parallel
```

## アーキテクチャ

XDG Base Directory仕様に準拠し、設定ファイルは`~/.config`に配置されます。

### 主要な設計パターン
- **シンボリックリンク**: リポジトリから期待される場所へ全設定をシンボリックリンク
- **モジュール化されたGit設定**: Git設定は`config/git/conf.d/`内の個別`.conf`ファイルに分割
- **クロスエディタ対応**: VS Code設定をCode、Code Insiders、Cursor間で共有
- **Zsh最適化**: 起動パフォーマンスのためエイリアスを`nonlazy.zsh`と`lazy.zsh`に分割

### 重要なシンボリックリンクのマッピング
- `config/*` → `~/.config/*` （ほとんどの設定）
- `config/zsh/.zshenv` → `~/.zshenv`
- `config/vscode/settings.json` → VS Code/Insiders/Cursorのユーザー設定
- `config/claude/CLAUDE.md` → `~/.claude/CLAUDE.md` （コピー、シンボリックリンクではない）

### 技術スタック
- **パッケージマネージャー**: Homebrew
- **シェル**: Zsh（sheldonプラグインマネージャー使用）
- **ターミナル**: WezTerm、iTerm2
- **エディタ**: Neovim（メイン）、VS Code/Insiders/Cursor
- **プロンプト**: Starship
- **Gitツール**: lazygit、gh、ghq