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
| `codex` | （subagent ではなく `codex review` CLI） | OpenAI Codex による別ベンダーのセカンドオピニオン。観点横断で実体ある問題を洗う |

## 呼び出し方

`codex` 以外の reviewer はメインスレッドから Agent ツールで起動する。1 メッセージ内に複数の Agent 呼び出しを並べて並列実行する。

`codex` は subagent ではなく `codex review` CLI を Bash の `run_in_background: true` で起動する。openai/codex-plugin-cc が提供する `/codex:review` slash command は `disable-model-invocation: true` でモデルから呼べないため、CLI を直接叩く方式を採用している。Agent 並列起動と同じメッセージ内でバックグラウンド起動し、stdout は `/tmp/agent-review-codex-{セッション識別子}.txt` にリダイレクトする。サブエージェント完了後に出力ファイルを読んで結果を回収し、Aggregator 側で reviewer 共通フォーマットに正規化してから集約に投入する。Codex がエラー / 認証切れ / タイムアウト / リモート PR 対象の場合は `Codex: SKIPPED ({理由})` を集約レポートに明記して続行する。

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

`codex` の起動は次の通り（Bash ツールで `run_in_background: true` を指定する）:

```bash
codex review --uncommitted > /tmp/agent-review-codex-${session_id}.txt 2>&1
# または
codex review --base {base-branch} > /tmp/agent-review-codex-${session_id}.txt 2>&1
```

uncommitted 差分対象なら `--uncommitted`、ブランチ差分対象なら `--base {base-branch}` を使う。Codex 起動 → サブエージェント並列起動 → サブエージェント完了 → 出力ファイル読み取りの順で回収する。リモート PR 対象（PR URL/番号でローカル checkout していない）時は別ブランチをレビューしてしまうため起動しない。

## reviewer 定義の編集

reviewer の責務、見るもの、見ないもの、出力フォーマットを変更したい場合は `~/.claude/agents/agent-review-{id}.md` を直接編集する。SKILL.md / reviewers.md には繰り返さない。
