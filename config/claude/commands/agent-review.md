---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git branch:*), Bash(git log:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(npm run lint:*), Bash(npm run typecheck:*), Bash(npm test:*), Bash(npm run test:*), Bash(npm run build:*), Bash(pnpm lint:*), Bash(pnpm run lint:*), Bash(pnpm typecheck:*), Bash(pnpm run typecheck:*), Bash(pnpm test:*), Bash(pnpm run test:*), Bash(pnpm build:*), Bash(pnpm run build:*), Bash(yarn lint:*), Bash(yarn typecheck:*), Bash(yarn test:*), Bash(yarn build:*), Bash(bun run lint:*), Bash(bun run typecheck:*), Bash(bun test:*), Bash(bun run build:*), Bash(go test:*), Bash(go vet:*), Bash(cargo test:*), Bash(cargo clippy:*), Bash(ruff check:*), Bash(pytest:*), Agent, Skill, AskUserQuestion
description: PR/差分を読み、必要な専門Agentを選んで低ノイズにレビューする
arguments:
  - name: target
    description: PR URL、PR番号、base branch、またはレビュー対象の説明（省略時はローカル差分）
    required: false
---

# /agent-review

`agent-review` スキルを使って、PR/差分を複数 Agent でレビューする。
この command は入口に徹し、レビュー観点・Agent 選択・集約基準は skill 側に従う。

## コンテキスト

- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "(git リポジトリではありません)"`
- Git ステータス: !`git status --short 2>/dev/null`
- 未コミット変更ファイル: !`git diff --name-only HEAD 2>/dev/null`
- origin/main 以降のコミット: !`git log origin/main..HEAD --oneline 2>/dev/null || echo "(origin/main と比較できません)"`
- ブランチ変更ファイル: !`git diff --name-only origin/main...HEAD 2>/dev/null || echo "(origin/main と比較できません)"`

## 実行手順

1. Skill ツールで `agent-review` を読み込む。
2. `$ARGUMENTS.target` からレビュー対象を決める。
   - PR URL/番号: `gh pr view` と `gh pr diff` で PR 情報と diff を取得する。
   - base branch: `git diff {base}...HEAD` と `git diff --name-only {base}...HEAD` を取得する。
   - 引数なし: 未コミット変更があれば `git diff HEAD`、なければ `git diff origin/main...HEAD` を対象にする。
3. diff が空なら、レビュー対象がないことを伝えて終了する。
4. 変更ファイル、diff、PR 情報、取得できた CI/check 情報を整理する。
5. package scripts やプロジェクト設定から、実行できる自動チェックだけを実行する。存在しないツールは導入しない。
6. `agent-review` skill の [routing.md](../skills/agent-review/references/routing.md) に従って Router Decision を出す。
7. 選択した Agent だけを、可能な限り 1 メッセージ内で並列起動する。
8. [severity.md](../skills/agent-review/references/severity.md) に従って結果を集約し、最終レポートを出す。

## 制約

- レビューのみ行う。ユーザーが明示しない限り、修正・PR コメント投稿・approve/request changes はしない。
- 全専門 Agent を毎回起動しない。PR 内容に基づいて必要な Agent だけ選ぶ。
- Agent の生出力をそのまま貼らない。重複、低信頼度、好みの指摘を落としてから報告する。
- 自動チェック失敗は findings と混ぜず、`自動チェック結果` に分離する。
