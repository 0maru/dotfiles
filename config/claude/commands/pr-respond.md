---
allowed-tools: Bash(gh *), Bash(git *), Bash(jq *), Read, Edit, Grep, Glob, AskUserQuestion
description: 自分の PR のコメントを triage し、対応提案（コード修正案 / 返信文案）を生成する。実行は人が最終確認
arguments:
  - name: pr-target
    description: PR 番号 or URL（省略時は現ブランチの PR を自動検出、なければ自分の open PR から選択）
    required: false
---

# /pr-respond — PR コメント triage & 対応支援

自分が作っている PR の review comments / issue comments を収集し、triage した上で **対応案を提示**するコマンド。

## 動作レベル A（慎重派）

- **コードは勝手に変更しない** — diff を提示してユーザーが採用判断
- **コメントは勝手に投稿しない** — 文面を提示してユーザーが採用判断
- **thread の resolve も勝手にしない**
- **push もしない** — 採用された commit はローカルに残し、push は手動

bot コメント（codecov / dependabot / sentry / copilot review / claude review 等）も**フィルタせず対応**する。bot は無視せず、提案として扱う（CI 失敗の指摘など実際の問題が含まれることが多いため）。

## ワークフロー

```
Phase 1: 対象 PR 特定
   ↓
Phase 2: コメント収集 (review / issue / bot 全部)
   ↓
Phase 3: triage + 分類
   ↓
Phase 4: 対応案生成 (per comment)
   ↓
Phase 5: ユーザー確認 → 採用分のみ適用
   ↓
Phase 6: 完了レポート (push 案内)
```

## Phase 1: 対象 PR の特定

`$ARGUMENTS` の値で分岐:

| パターン | 動作 |
|---|---|
| 数字のみ (`123`) | 現リポジトリの PR #123 |
| URL (`https://github.com/owner/repo/pull/N`) | URL から owner/repo/N を抽出 |
| 省略 + 現ブランチに PR あり | 現ブランチの PR を使用 |
| 省略 + 現ブランチに PR なし | `gh pr list --author @me` で一覧取得し AskUserQuestion で選択 |

### 現ブランチ PR の検出

```bash
gh pr view --json number,url,headRefName,baseRefName,title,state
```

エラー（PR なし）の場合は次のステップへ。

### 自分の open PR 一覧（省略時のフォールバック）

```bash
gh pr list --author @me --state open --json number,title,headRefName,url,reviewDecision,statusCheckRollup,createdAt,updatedAt --limit 20
```

整形して AskUserQuestion で選択肢として提示:

```
質問: どの PR のコメントを処理しますか？
- #123 [REVIEW_REQUIRED] {title} (updated 2h ago)
- #122 [APPROVED]        {title} (updated 1d ago)
- #121 [CHANGES_REQUESTED] {title} (updated 5d ago)
```

候補が 0 件の場合: 「open PR がありません」と告知して終了。

### 1-1. 対象 PR の head branch と現在地の照合（必須）

対象 PR が確定したら、そのコード修正をローカルに適用しても安全か確認する。

```bash
gh pr view {N} --json headRefName,headRepository,headRepositoryOwner --jq '.headRefName + " " + .headRepositoryOwner.login + "/" + .headRepository.name'
git rev-parse --abbrev-ref HEAD
git rev-parse --show-toplevel
```

照合ルール:

| 状況 | 対応 |
|---|---|
| 現ブランチ == `headRefName` かつ同リポジトリ | そのまま続行 |
| 現ブランチ != `headRefName` | AskUserQuestion で確認: ① `git switch {headRefName}` で移動 / ② 中止 / ③ コード変更なしで triage と返信案のみ生成 |
| fork PR (head が別 owner) | コード修正は不可。triage と返信案のみのモードに切り替え |
| 未コミット変更あり (`git status --porcelain` 非空) | AskUserQuestion: ① 中止 / ② stash してから続行（自動 stash pop はしない） |

**この段階を飛ばすと別ブランチにレビュー対応を混入させる事故が起きるため、Phase 5 のコード適用は照合 OK の場合のみ許可する。**

## Phase 2: コメント収集

3 種類のコメントを並行取得する:

### 2-1. Review comments (line-level)

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate
```

各コメントから抽出:
- `id`, `user.login`, `body`, `path`, `line`, `original_line`
- `in_reply_to_id` (スレッド構造)
- `created_at`, `updated_at`

### 2-2. Issue comments (general)

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

### 2-3. Reviews (review submissions with summary)

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate
```

各 review の `state` (APPROVED / CHANGES_REQUESTED / COMMENTED) と `body` を保持。

### 2-4. Resolved 状態の取得（GraphQL）

review comment の thread が resolve されているかは REST では取れないので GraphQL を使う。**100 件を超える PR でも漏れなく取得するため `--paginate` を必須**にする:

```bash
gh api graphql --paginate -f query='
  query($owner: String!, $repo: String!, $number: Int!, $endCursor: String) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100, after: $endCursor) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            comments(first: 100) { nodes { databaseId } }
          }
        }
      }
    }
  }' -f owner={owner} -f repo={repo} -F number={number}
```

`gh api graphql --paginate` は `pageInfo.hasNextPage` を見て自動的に次ページを取得する（`endCursor` 変数を使う場合、クエリ内で `$endCursor` を使うこと）。出力は複数の JSON オブジェクトが連結された形になるので、`jq -s '[.[].data.repository.pullRequest.reviewThreads.nodes[]]'` でフラット化する。

各 thread 内の `comments.nodes[].databaseId` を Phase 2-1 の REST 経由 `comment.id` と突き合わせ、resolved 済みは triage で除外候補にする。1 thread に 100 件を超えるコメントがあるケースも理論上ありうるが極めて稀なので、本コマンドでは「先頭 100 コメント」までで十分とする（必要になった時点で再ページング対応を検討）。

## Phase 3: triage + 分類

各コメントを以下のカテゴリに分類:

| カテゴリ | 例 | 対応方針 |
|---|---|---|
| **修正対応** | "ここ null チェックが抜けてる" | コード修正案を生成 |
| **質問回答** | "なぜこの実装にした?" | 返信文案を生成 |
| **議論** | "アーキ的に X の方がいいのでは" | 立場を 2〜3 案ユーザーに提示 |
| **無視 / wontfix** | nit / 既知の制約 | 「対応しない」理由を返信文案に |
| **resolved 済み** | thread closed | スキップ（一覧表示はする） |
| **ack のみで OK** | LGTM / 👍 | スキップ |

### bot コメントの扱い

bot 判定: `user.type == "Bot"` または login が `*-[bot]` パターン、または既知の bot login (`copilot`, `claude` 等)。

bot ごとの典型パターン（提案生成のヒント）:

| bot | 内容例 | 提案方針 |
|---|---|---|
| dependabot | dep bump | tests OK ならマージ推奨、breaking change なら手動確認案内 |
| codecov | coverage drop | 該当ファイル / 関数のテスト追加案 |
| sentry | new error introduced | エラー箇所のコード提示 + 修正案 |
| github-actions | CI 失敗ログ抜粋 | ログを読んで原因仮説 |
| copilot review / claude review | line-level 提案 | 通常 review と同様に triage |

### 分類結果の表示

```markdown
## Triage 結果 (PR #N: {title})

総コメント数: 12 件
- resolved 済み (スキップ): 3 件
- ack のみ (スキップ): 2 件
- 修正対応: 4 件
- 質問回答: 1 件
- 議論: 1 件
- bot からの修正提案: 1 件
```

未対応カテゴリのコメント全件を、続く Phase 4 で順次処理する。

## Phase 4: 対応案生成

未対応カテゴリのコメントを **1 件ずつ** 順番に処理する。並列にしない（コード修正のコンフリクトを避けるため）。

各コメントについて:

### 4-1. コンテキスト読み込み

- review comment なら: `path` の該当行 ±20 行を Read
- 関連するテスト・呼び出し元を Grep で確認

### 4-2. 提案の生成

カテゴリ別:

#### 修正対応
```
コード修正案:
- ファイル: {path}:{line}
- 変更前: {コード抜粋}
- 変更後: {提案コード}
- 理由: {1〜2 行}

返信文案（任意で添える）:
> 修正しました。{commit_sha} で対応しています。
```

#### 質問回答
```
返信文案:
> {質問内容を踏まえた回答 200 字程度}
```

#### 議論（複数立場）
```
立場 A: {現状維持の根拠}
立場 B: {変更受け入れの根拠}
立場 C: {折衷案}

→ AskUserQuestion でユーザーがどの立場を取るか選択
```

#### 無視 / wontfix
```
返信文案:
> ご指摘ありがとうございます。{wontfix の理由 50〜100 字}。今回はスコープ外として、別 issue で追跡することを提案します。
```

### 4-3. ユーザー確認

各コメントの提案について AskUserQuestion で:

```
質問: 提案を採用しますか？
- 採用 (そのまま適用)
  Pros: 即時対応 / Cons: 提案文面が固いかも
- 修正して採用 (文面を編集)
  Pros: トーン調整可 / Cons: 一手間
- 却下 (このコメントはスキップ)
  Pros: 後で対応 / Cons: 残タスク化
- 後回し (後でまとめて対応)
  Pros: バッチ処理 / Cons: 抜け漏れリスク
```

「修正して採用」の場合は AskUserQuestion で修正文面を受け取る（自由入力）。

## Phase 5: 採用分の適用

### 5-1. コード修正

#### 前提: clean tree の確認（必須）

コード適用の直前に、対象ファイルが clean であることを確認する。Phase 1-1 で既存変更を stash 済みでも、その後新たに変更が入っていないかを再チェックする:

```bash
git status --porcelain {file}
```

出力が非空（既存変更あり）の場合、AskUserQuestion で確認:
- 中止（推奨）: コメント対応を保留し、ユーザーに既存変更を整理させる
- stash 後に続行: `git stash push -- {file}` してから適用、適用 commit 後に `git stash pop` を案内
- 既存変更も含めて 1 commit にまとめる（注意付き）: 1 コメント 1 コミット原則が崩れることを警告した上で続行

**自動で `git stash pop` はしない**（衝突時のリカバリが面倒なため、ユーザーに案内するに留める）。

#### Edit + commit

採用された修正を Edit ツールで適用する。**1 修正につき 1 コミット**で記録:

```bash
git add {file}
git commit -m "{コメント内容を踏まえた日本語要約}

PR #{N} のレビュー指摘 (https://github.com/{owner}/{repo}/pull/{N}#discussion_r{comment_id}) に対応。

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

`git add {file}` 実行前に再度 `git diff --staged` と `git diff {file}` で「適用した変更だけ」が含まれることを目視確認する。複数の修正を 1 コミットにまとめるかは AskUserQuestion でユーザーに確認（デフォルト: 1 コメント 1 コミット）。

### 5-2. 返信投稿

採用された返信文を gh CLI で投稿:

**Issue comment (general):**
```bash
gh pr comment {N} --body "{返信文面}"
```

**Review comment (line-level reply):**
```bash
gh api -X POST \
  /repos/{owner}/{repo}/pulls/{N}/comments/{parent_comment_id}/replies \
  -f body="{返信文面}"
```

### 5-3. push しない

このコマンドは push を行わない。完了レポートで「push が必要」と案内するだけ。

## Phase 6: 完了レポート

```markdown
## /pr-respond 完了レポート (PR #N)

### 適用されたコード変更
- {commit_sha}: {要約}
- ...

### 投稿された返信
- {file}:{line} に返信投稿
- ...

### 後回し / 却下したコメント
- {url}: {理由}
- ...

### 残タスク
- [ ] 動作確認: ...
- [ ] `git push` で remote に反映
- [ ] 必要なら `/commit-push-pr` で他の変更と一括 push
- [ ] resolve thread は手動で（Action level A の方針）
```

## エラー処理

- `gh pr view` 失敗 → Phase 1 のフォールバック (`gh pr list --author @me`) へ
- `gh api` 失敗 → エラー内容を表示し、ユーザーに継続可否を確認
- ファイル位置が現在のブランチで存在しない（renamed / deleted） → 該当コメントは「議論」カテゴリに格上げしてユーザーに提示

## 重要な注意事項

- **A レベル**: コード変更も返信投稿も、**必ずユーザーの明示的承認後にのみ**実行する
- bot コメントもフィルタせず提案を生成する（CI / coverage / security の signal は重要）
- 1 コメント 1 コミットを基本とし、巨大なコミットを避ける
- push は行わない。最後にユーザー判断で
- thread の resolve は行わない。GitHub UI 側で人が確認

## 既存ワークフローとの連携

- 適用後の push は `/commit-push-pr` を使うのが自然
- コードレビュー観点での「自分の PR を見直す」用途には `/code-review` や `/agent-review` を併用
