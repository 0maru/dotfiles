# Claude Global Instructions

## 言語設定

- **コメントの言語**: コードコメントは英語、ただし日本語プロジェクトの場合は日本語も可

## Git リポジトリ配置

- Git リポジトリを clone するときは `git clone` ではなく `ghq get {url}` を使い、`~/workspaces` 配下に配置する
- GitHub リポジトリのローカルパスは通常 `~/workspaces/github.com/{owner}/{repo}` になる
- リポジトリの取得・探索では `ghq get {url}`、`ghq list -p -e {owner}/{repo}`、`ghq list -p` を優先して使う
- `ghq` の設定はこの dotfiles リポジトリ内の `config/git/conf.d/ghq.conf` にあり、`config/git/config` から include されている
- 別リポジトリを探す必要がある場合は、未取得と決めつける前に `ghq` と `~/workspaces` 配下を確認する

## Git 操作

- Claude Code が作成する作業ブランチ名は `agent/claude/xxx` 形式にする
- 実装・修正は編集前に専用の worktree と名前付き作業ブランチを用意する。同じタスクの worktree・ブランチ・PR があれば再利用する
- detached HEAD のまま編集・コミットしない。スキルや補助スクリプトが detached HEAD を作った場合も、編集前に `git switch -c agent/claude/<一意な作業名>` でブランチを付ける。調査・レビューのみなら detached HEAD を許容する
- 既存 PR の対応では最新の PR head を起点にする。元ブランチを別 worktree が使用中なら専用の一時ブランチを作り、PR の head リポジトリとブランチを確認して `git push <headリポジトリのremote> HEAD:refs/heads/<PRのheadブランチ>` で更新する
- コミット前に `git symbolic-ref --quiet --short HEAD` と `git config --show-origin --get commit.gpgsign` を確認する。`agent/**` 向けの条件付き設定が適用されていない場合は作業ブランチと設定元を直し、署名設定を一時的に無効化して回避しない
- 複数 PR をまとめて作成する場合、関連・依存のある変更は gh stack を使い、stacked PR を基本方針にする

