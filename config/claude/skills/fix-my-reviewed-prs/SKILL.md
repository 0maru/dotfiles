---
name: fix-my-reviewed-prs
description: |
  自分が作成した open PR のうち、レビュー対応・requested changes・未解決 review thread・CI 失敗があるものを
  検出し、優先順位付けし、必要に応じて worktree を準備するときに使用する。「自分のレビュー対応待ち PR を直す」
  「対応が必要な PR を探して」「reviewed PR を開いて」「fix my reviewed PRs」といった依頼で必ず起動する。
  各 PR の実際のコメント対応は review-respond スキルへ引き継ぐ。
---

# Fix My Reviewed PRs

自分の open PR を棚卸しし、レビュー対応が必要なものだけを作業可能な状態へ寄せる。目的は「どの PR から直すべきか」を即決できるキューを作り、必要なら worktree を用意して `review-respond` に引き継ぐこと。

## 最重要ルール

- 対象は原則として現在の GitHub repository の、自分が author の open PR。
- commit / push / PR close / merge は行わない。
- worktree 作成はローカル状態を変えるため、対象一覧を提示してから実行する。ユーザーが「全部開いて」など明示した場合はその範囲で進める。
- このリポジトリの方針に従い、worktree 作成は `ou add` を優先する。`git worktree add` は使わない。
- 既存 worktree がある PR は再作成せず、そのパスを使う。
- PR ごとの修正実装はこのスキル内で抱え込まず、選択した PR ごとに `review-respond` を使う。

## 入力

呼び出し側は取れる範囲で次を用意する:

- 対象 repository（省略時は現在の repo）
- 自分の GitHub login
- 自分が author の open PR 一覧
- 各 PR の reviewDecision、latestReviews、reviewThreads、comments、checks、updatedAt
- worktree 一覧（既に開いている PR を判定するため）
- ユーザー指定: すべて / 上位 N 件 / requested changes のみ / CI 失敗のみ

## 検出条件

PR は次のいずれかに該当したら「対応候補」に入れる。

| 理由 | 条件 | 優先度 |
|---|---|---|
| `CHANGES_REQUESTED` | `reviewDecision` が `CHANGES_REQUESTED`、または latest review に changes requested がある | P0 |
| `UNRESOLVED_THREADS` | 未解決 review thread があり、最後のコメントが自分以外 | P0 |
| `FAILING_CHECKS` | required check または主要 CI が failure / error / cancelled | P1 |
| `ACTIONABLE_COMMENTS` | PR comment / review comment に明確な修正依頼がある | P1 |
| `STALE_AFTER_REVIEW` | レビュー後に返信・push がなく一定時間経過 | P2 |
| `DRAFT_OR_BLOCKED` | draft、依存待ち、レビュー待ちだけで自分の対応不要 | 除外または P3 |

bot コメントは CI 失敗の入口としては扱うが、重複通知や summary だけなら除外する。

## 優先順位

1. `CHANGES_REQUESTED` かつ未解決 thread あり
2. required checks failure
3. レビューコメントが多く、更新が古い PR
4. 小さい PR（短時間で解消できるもの）
5. draft / blocked は最後

同じ優先度なら `updatedAt` が古いものを先にする。

## ワークフロー

1. **repo と login 確認**: `git remote get-url origin`、`gh auth status`、`gh api user --jq .login` を確認する。
2. **自分の open PR 取得**: `gh pr list --author {login} --state open --json number,title,url,headRefName,baseRefName,isDraft,reviewDecision,mergeStateStatus,updatedAt,statusCheckRollup,latestReviews,comments`
3. **候補の詳細取得**: 対応が必要そうな PR だけ `gh pr view`、`gh pr checks`、GraphQL の `reviewThreads` を追加取得する。全 PR に高コストな GraphQL を打たない。
4. **対応候補分類**: 検出条件に従って理由と優先度を付ける。
5. **worktree 状態確認**: `ou list` を優先し、必要なら `git worktree list --porcelain` で既存 worktree と branch を照合する。
6. **キュー提示**: P0/P1/P2 に分けて、PR 番号、タイトル、理由、推奨アクション、既存 worktree の有無を表示する。
7. **対象選択**: ユーザー指定がなければ、P0 を開くか確認する。明示指定があればその範囲で進める。
8. **worktree 準備**:
   - 既存 worktree があれば、そのパスを返す。
   - なければ `ou add {headRefName}` を使う。
   - `ou add` 後、必要に応じてその worktree で `gh pr checkout {number}` して PR head と一致させる。
   - 失敗した場合は無理に `git worktree add` へ逃げず、失敗理由と手動手順を出す。
9. **引き継ぎ**: 各 PR について、次に実行すべき `review-respond {PR URL}` と作業パスを出す。ユーザーが「そのまま直して」と言っている場合は、優先度順に 1 PR ずつ `review-respond` へ移る。

## 出力

最終出力は次の形式にする:

```markdown
# My Reviewed PRs

## 対応キュー
| Priority | PR | Reason | Checks | Worktree | Next |
|---|---:|---|---|---|---|
| P0 | #123 | CHANGES_REQUESTED, 2 unresolved threads | failing | /path | review-respond |

## 今回準備した worktree
- #123: `/path/to/worktree`

## 除外した PR
- #124: review wait only

## 次のアクション
- `/review-respond {PR URL}` を実行
```

## review-respond への引き継ぎメモ

各 PR へ移るときは、次を短く渡す:

- PR URL
- worktree path
- 優先理由
- 未解決 thread 件数
- failing check 名
- 先に見るべきファイル

## 失敗モード

- **gh 認証切れ**: `gh auth status` の結果を示し、ログイン後に再実行してもらう。
- **GraphQL 取得失敗**: `reviewDecision` と REST comments だけで暫定キューを作り、未解決 thread 数は「不明」にする。
- **fork PR**: `headRepositoryOwner` が自分または base repo と違う場合、checkout/worktree 作成前に確認する。
- **同名 branch が別 worktree で使用中**: 既存 worktree を使う。別名 branch を勝手に作らない。
- **未コミット変更あり**: 対象 worktree の状態を表示し、`review-respond` へ進む前に確認を取る。
