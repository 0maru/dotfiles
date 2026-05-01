# ファイル分類ルール

人間レビュー時に「どのファイルから読むべきか」を判定するための分類基準。

## 目次

1. [3 段階分類](#3-段階分類)
2. [🔴 重点確認の判定](#-重点確認の判定)
3. [🟡 通常確認の判定](#-通常確認の判定)
4. [🟢 軽微確認の判定](#-軽微確認の判定)
5. [迷ったときの倒し方](#迷ったときの倒し方)
6. [agent-review との連動](#agent-review-との連動)

## 3 段階分類

| 分類 | 期待される人間の挙動 |
|---|---|
| 🔴 重点確認 | hunk まで丁寧に読む。テスト・ロールバック手順も確認する。 |
| 🟡 通常確認 | 変更箇所と直近の呼び出し元を読む。意図と命名を確認する。 |
| 🟢 軽微確認 | ファイル一覧で目視。中身は確認しなくてもよい想定。 |

## 🔴 重点確認の判定

以下のいずれかに該当したら 🔴 に分類する。

### セキュリティ・権限境界
- 認証・認可・セッション・トークン関連の処理変更
- secret / API キー / `.env` / credential ファイルの変更
- CORS / CSP / SameSite / cookie 設定変更
- 入力境界での validation / sanitize / escape の変更

### データ整合性
- DB migration（`migrations/`、`schema.rb`、`*.sql` 等）
- model / entity の追加・削除・型変更
- インデックスの追加・削除
- 一意制約・外部キー・NOT NULL 制約の変更

### 公開 API・契約
- public な REST/GraphQL/gRPC エンドポイントのスキーマ変更
- response 型の追加・削除・型変更（status code 変化含む）
- ライブラリの公開シンボルの破壊的変更

### 課金・金額計算
- 料金計算ロジック、課金タイミング、決済呼び出し
- 通貨換算、税計算、割引適用ロジック

### インフラ・実行環境
- Dockerfile / docker-compose / k8s manifest
- CI/CD ワークフロー（deploy step を含む）
- cron / scheduled job の追加・削除・頻度変更
- IAM ロール・ポリシーの変更

### agent-review シグナル
- agent-review の findings で `severity: blocker` または `major` がある
- 複数の reviewer が同じファイル/行を指摘している（corroborated）

## 🟡 通常確認の判定

🔴 にも 🟢 にも該当しない実装変更。

- 業務ロジックを含む `.ts / .tsx / .go / .py / .rb / .swift / .java / .kt` などの変更
- 設定値だが意味的な変更を伴うもの（feature flag の追加、閾値の変更）
- 新規ファイルの追加（実装系）
- リファクタ（テスト含む場合は 🟡 のまま）

## 🟢 軽微確認の判定

以下の **すべて** に当てはまる変更のみ 🟢 に置く。

- テスト追加のみ（`*.test.*`、`*_test.go`、`spec/`、`__tests__/`）かつ実装変更を伴わない
- lockfile（`package-lock.json`、`yarn.lock`、`pnpm-lock.yaml`、`Gemfile.lock`、`go.sum`、`Cargo.lock`、`Podfile.lock`）の機械的更新
- `*.md` / `docs/` のみの変更
- `.gitignore` / `.editorconfig` / `prettier`/`eslint` 等の lint 設定の値だけ
- 自動 format/lint 起因の whitespace / import sort のみの変更

注意:
- テスト変更でも、テスト対象を変更している場合は実装側に引きずられて 🟡 になる。
- migration を伴う lockfile（`schema.rb` 同時更新）は 🔴 寄りに倒す。
- ドキュメントでも公開 API の仕様書（OpenAPI、proto）変更は 🟡 以上。

## 迷ったときの倒し方

| 状況 | 倒す方向 |
|---|---|
| 🟡 と 🔴 で迷う | 🔴 に倒す（読む時間が増えるだけで害はない） |
| 🟡 と 🟢 で迷う | 🟡 に倒す（見落としリスクを避ける） |
| 拡張子から判定不能 | 中身の数行を読んで判定する |
| 大量にある場合 | 🔴 を優先確保し、🟡 は変更行数で並べる |

## agent-review との連動

agent-review の集約レポートが渡されている場合、ファイル分類の結果に findings を紐づける。

- **blocker** finding がある → 必ず 🔴
- **major** finding がある → 🔴
- **minor** finding がある → 🟡 のままで良い（findings は引用する）
- **nit** finding のみ → 分類は変えない（findings 引用は任意）
- **corroborated**（2 reviewer 以上が同じ箇所） → severity に関わらず 🔴 に倒す

agent-review の `確認ポイント` は分類に影響させず、出力の末尾に「AI 低信頼度」として残す。
