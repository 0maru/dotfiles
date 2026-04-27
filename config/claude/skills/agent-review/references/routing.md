# Agent Review Routing

diff と変更ファイルから必要な Agent だけを選択する。迷った場合は「起動する」よりも「確認ポイントに回す」を優先し、過剰な専門 Agent 起動でノイズを増やさない。

## 常時起動

| Agent | 起動理由 |
|---|---|
| `hygiene` | 不要差分、debug log、未使用コード、lockfile、CI 失敗などを毎回確認する |
| `correctness` | 実行時バグ、境界値、エラー処理、非同期の破綻は変更種別を問わず起こる |

## 条件付き Agent

| Agent | 起動条件 |
|---|---|
| `security` | auth, permission, role, token, cookie, session, CORS, CSRF, env, secret, upload, SQL, shell execution, path, URL fetch, dependency 変更 |
| `architecture` | shared module, public API, dependency direction, cross-layer 変更、大きめの責務移動、抽象化追加、既存境界の変更 |
| `typescript-type-safety` | `.ts`, `.tsx`, `d.ts`, schema, API client, generated types, `any`, `unknown`, type assertion, generics, discriminated union の変更 |
| `database-design` | migration, schema, index, constraint, transaction, query, ORM model, repository, N+1 に関わる変更 |
| `frontend-ux` | React/Vue/Svelte component, form, CSS, UI state, accessibility, loading/error/empty state, responsive layout の変更 |
| `api-contract` | route, controller, handler, request/response schema, status code, pagination, API client/server contract の変更 |
| `test-maintainability` | ロジック変更、bugfix、API/DB/security 変更、既存テストの大きな変更、テスト追加なしの振る舞い変更 |
| `infrastructure` | CI/CD, workflow, Dockerfile, IaC, deploy config, runtime env, permission, scheduled job の変更 |

## 起動数の目安

- 通常: 常時 2 Agent + 条件付き 1〜3 Agent。
- 大きい PR: 最大 6 Agent。全部起動したくなる場合は、リスクが高い順に絞る。
- docs/comment only: `hygiene` のみ。仕様変更を含む docs は `api-contract` または `architecture` を追加する。
- test only: `hygiene` と `test-maintainability`。本番コードのリスクは原則見ない。

## 優先順位

条件付き Agent が多すぎる場合はこの順で残す:

1. `security`
2. `database-design`
3. `api-contract`
4. `typescript-type-safety`
5. `frontend-ux`
6. `architecture`
7. `infrastructure`
8. `test-maintainability`

ただし、PR の主目的がテスト改善なら `test-maintainability` を優先する。

## Router 判断の材料

- ファイルパス: `auth/`, `api/`, `db/`, `migrations/`, `components/`, `.github/workflows/`
- 拡張子: `.ts`, `.tsx`, `.sql`, `.prisma`, `.py`, `.go`, `.tf`, `.yaml`
- diff 内キーワード: `permission`, `role`, `token`, `cookie`, `query`, `transaction`, `useEffect`, `any`, `as`, `migration`
- PR title/body: bugfix, refactor, auth, migration, performance, breaking change
- 自動チェック失敗: typecheck 失敗なら `typescript-type-safety`、test 失敗なら `test-maintainability`

## Router 出力形式

```markdown
## Router Decision

### Selected
- {agent-id}: {起動理由}

### Skipped
- {agent-id}: {起動しない理由}

### Risk Notes
- Router 時点で気になるが専門 Agent 起動までは不要な点
```
