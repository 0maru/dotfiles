---
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git diff:*), Bash(git remote:*), Bash(git worktree list:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr checkout:*), Bash(gh api:*), Bash(gh auth status:*), Bash(ou list:*), Bash(ou add:*), Bash(cd:*), Bash(npm run lint:*), Bash(npm run typecheck:*), Bash(npm test:*), Bash(npm run test:*), Bash(npm run build:*), Bash(pnpm lint:*), Bash(pnpm run lint:*), Bash(pnpm typecheck:*), Bash(pnpm run typecheck:*), Bash(pnpm test:*), Bash(pnpm run test:*), Bash(pnpm build:*), Bash(pnpm run build:*), Bash(yarn lint:*), Bash(yarn typecheck:*), Bash(yarn test:*), Bash(yarn build:*), Bash(bun run lint:*), Bash(bun run typecheck:*), Bash(bun test:*), Bash(bun run build:*), Bash(go test:*), Bash(go vet:*), Bash(cargo test:*), Bash(cargo clippy:*), Bash(ruff check:*), Bash(pytest:*), Skill, AskUserQuestion
description: PR のレビューコメントを分類し、修正・検証・返信ドラフト作成まで行う
arguments:
  - name: target
    description: PR URL、PR番号、または対象の説明（省略時は現在ブランチの PR）
    required: false
---

# /review-respond

`review-respond` スキルを使って、PR に付いたレビューコメントへ対応する。
この command は入口に徹し、分類・修正・返信・投稿確認の基準は skill 側に従う。

## コンテキスト

- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "(git リポジトリではありません)"`
- Git ステータス: !`git status --short 2>/dev/null`
- 現在ブランチの PR: !`gh pr view --json number,url,headRefName,reviewDecision 2>/dev/null || echo "(現在ブランチの PR を取得できません)"`

## 実行手順

1. Skill ツールで `review-respond` を読み込む。
2. `$ARGUMENTS.target` があれば対象 PR として扱う。なければ現在ブランチの PR を `gh pr view` で取得する。
3. `gh pr view`、`gh pr diff`、`gh pr checks`、`gh api` でレビューコメント、review threads、CI 状態を取得する。
4. `review-respond` skill の分類に従い、対応一覧を作る。
5. ユーザーが修正対応を求めている場合は、対象 PR の head branch/worktree であることを確認してから修正する。
6. 変更内容に応じて検証を実行する。存在しないツールは導入しない。
7. 返信ドラフトを作成し、GitHub へ投稿または thread resolve する前に確認を取る。

## 制約

- 対象ブランチが違う状態でコードを修正しない。
- PR コメント投稿、review thread reply、resolve は確認後にだけ実行する。
- commit / push は行わない。必要なら最後に `/commit-push-pr` を案内する。
