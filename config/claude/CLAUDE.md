# Claude Global Instructions

このファイルは、Claude Code が全プロジェクトで共通して参照すべき指示事項を記載しています。

## 言語設定

- **CLAUDE.md の言語**: 日本語で記述すること
- **コメントの言語**: コードコメントは英語、ただし日本語プロジェクトの場合は日本語も可
- **コミットメッセージ**: プロジェクトの慣習に従う（指定がない場合は日本語）
- **文字コード**: すべてのファイルは UTF-8 で保存すること

## コーディング規約

### ファイル作成
- 新規ファイルの作成は最小限に留める
- 既存ファイルの編集を優先する

### テスト
- 新機能追加時は対応するテストも作成
- 既存のテストフレームワークとパターンに従う

## Git リポジトリ配置
- Git リポジトリを clone するときは `git clone` ではなく `ghq get {url}` を使い、`~/workspaces` 配下に配置する
- GitHub リポジトリのローカルパスは通常 `~/workspaces/github.com/{owner}/{repo}` になる
- リポジトリの取得・探索では `ghq get {url}`、`ghq list -p -e {owner}/{repo}`、`ghq list -p` を優先して使う
- `ghq` の設定はこの dotfiles リポジトリ内の `config/git/conf.d/ghq.conf` にあり、`config/git/config` から include されている
- 別リポジトリを探す必要がある場合は、未取得と決めつける前に `ghq` と `~/workspaces` 配下を確認する

## Git 操作

- Claude Code が作成する作業ブランチ名は `agent/claude/xxx` 形式にする
- 複数 PR をまとめて作成する場合、関連・依存のある変更は stacked PR を基本方針にする

## Codex レビュー
- **プランレビュー**: プランモードで ExitPlanMode を呼ぶ前に、`codex-plan-review` スキルを使って Codex CLI にプランをレビューさせること
- **コードレビュー**: 実装タスク完了後、コミット前に `codex-code-review` スキルを使って `codex review --uncommitted` で変更をレビューさせること
- Codex が SUGGEST_CHANGES / REJECT を返した場合は、指摘を検討して対応すること
- Codex が利用できない場合（未インストール、認証切れ等）はスキップして続行

### 軽微な変更のスキップ基準
以下の条件を**すべて**満たす場合、Codex レビュー（プラン・コード両方）をスキップする:
- 設定値のみの変更（Brewfile 追加、エイリアス追加、キーバインド変更など）
- 1〜2 ファイルの単純な編集
- 既存パターンの踏襲（同じフォーマットでの追記）
- ドキュメント・コメントのみの変更

