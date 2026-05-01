---
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git remote:*), Bash(git worktree list:*), Bash(gh auth status:*), Bash(gh api:*), Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh pr checks:*), Bash(gh pr checkout:*), Bash(ou list:*), Bash(ou add:*), Bash(cd:*), Skill, AskUserQuestion
description: 自分の open PR からレビュー対応が必要なものを検出し、優先順位付けして worktree を準備する
arguments:
  - name: filter
    description: all、p0、changes-requested、ci-failed、上位N件など（省略時は対応候補を一覧）
    required: false
---

# /fix-my-reviewed-prs

`fix-my-reviewed-prs` スキルを使って、自分の open PR のうち対応が必要なものを棚卸しする。
PR ごとの実際のコメント対応は `review-respond` スキルへ引き継ぐ。

## コンテキスト

- 現在の repo: !`git remote get-url origin 2>/dev/null || echo "(git リポジトリではありません)"`
- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "(git リポジトリではありません)"`
- Git ステータス: !`git status --short 2>/dev/null`
- gh auth: !`gh auth status 2>&1 | head -3`
- ou worktrees: !`ou list 2>/dev/null || echo "(ou list を取得できません)"`

## 実行手順

1. Skill ツールで `fix-my-reviewed-prs` を読み込む。
2. `gh api user --jq .login` で自分の login を取得する。
3. 現在の repository で、自分が author の open PR を `gh pr list --author {login} --state open` で取得する。
4. reviewDecision、latestReviews、comments、checks を見て対応候補を絞る。
5. 必要な候補だけ GraphQL の reviewThreads を追加取得し、未解決 thread の有無を判定する。
6. `$ARGUMENTS.filter` に従って対象を絞る。指定がなければキューを表示し、worktree 作成前に確認する。
7. 選択された PR について既存 worktree を確認し、なければ `ou add {headRefName}` で準備する。
8. 各 PR の作業パスと、次に実行する `/review-respond {PR URL}` を出力する。

## 制約

- commit / push / merge / close は行わない。
- worktree 作成には `ou add` を使い、`git worktree add` は使わない。
- worktree 作成や checkout が失敗した場合は、状態を壊そうとせず失敗理由を報告する。
