# Agent Reviewers Index

各 reviewer は独立したサブエージェント（`~/.claude/agents/agent-review-{id}.md`）として定義されている。`agent-review` skill はこのインデックスを使い、Router で選んだ reviewer-id を `subagent_type` に渡して並列起動する。

各 reviewer の「役割」「見るもの」「見ないもの」「出力フォーマット」「禁止事項」はすべてサブエージェント定義側に固定済みのため、SKILL.md 側で重複させない。

## reviewer 一覧

| reviewer-id | subagent_type | 観点（拾うもの） |
|---|---|---|
| `hygiene` | `agent-review-hygiene` | 不要差分、debug log、未使用 import、lockfile、自動チェック失敗 |
| `correctness` | `agent-review-correctness` | null/boundary、async race、error handling、仕様不整合、互換性破壊 |
| `security` | `agent-review-security` | 認証境界、IDOR、injection、secret、cookie/CSRF、supply chain |
| `architecture` | `agent-review-architecture` | module boundary、dependency direction、public API、abstraction |
| `typescript-type-safety` | `agent-review-typescript-type-safety` | `any`、narrowing 不足、discriminated union、schema 整合 |
| `database-design` | `agent-review-database-design` | migration 安全性、index、transaction、N+1、ORM 整合 |
| `frontend-ux` | `agent-review-frontend-ux` | state/effect、form、loading/error/empty、accessibility |
| `api-contract` | `agent-review-api-contract` | request/response schema、status code、互換性、retry/idempotency |
| `test-maintainability` | `agent-review-test-maintainability` | 主経路・異常系・境界値、回帰テスト、brittle mock |
| `infrastructure` | `agent-review-infrastructure` | workflow、Dockerfile、deploy、secret/env、cron |

## 呼び出し方

メインスレッドから Agent ツールで起動する。1 メッセージ内に複数の Agent 呼び出しを並べて並列実行する。

```
Agent({
  subagent_type: "agent-review-security",
  description: "security レビュー",
  prompt: "...PR 情報、変更ファイル一覧、diff、自動チェック結果、補足説明..."
})
```

prompt には以下を必ず含める:

- PR 情報（あれば: title/body/base/head/additions/deletions）
- 変更ファイル一覧
- diff 本文
- 自動チェック結果（あれば: lint, typecheck, test, build, CI）
- タスクの補足説明

reviewer サブエージェントは独立したコンテキストで動くため、メインの会話履歴は見えない。必要な情報はすべて prompt に同梱する。

## reviewer 定義の編集

reviewer の責務、見るもの、見ないもの、出力フォーマットを変更したい場合は `~/.claude/agents/agent-review-{id}.md` を直接編集する。SKILL.md / reviewers.md には繰り返さない。
