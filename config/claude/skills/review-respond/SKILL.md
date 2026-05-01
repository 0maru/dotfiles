---
name: review-respond
description: |
  自分の PR に付いた GitHub review comments / review threads / PR comments / CI 指摘へ対応するときに使用する。
  「レビューコメント対応」「PR コメントを直して」「指摘に返信して」「レビュー返信」「requested changes 対応」
  といった依頼で必ず起動する。コメントを取得して対応方針を分類し、必要な修正・検証・返信文作成まで行う。
  PR コメント投稿や review thread resolve は、ユーザーが明示した場合または投稿前確認が取れた場合だけ行う。
---

# Review Respond

PR に付いたレビュー指摘を、漏れなく低ノイズに対応するためのワークフロー。目的は「コメントを読む」「直す」「返信する」を分断せず、対応済み・要確認・保留を追跡可能にすること。

## 最重要ルール

- ユーザーの未コミット変更を巻き戻さない。作業前に `git status --short` を確認する。
- 現在の worktree が対象 PR の head branch でない場合、勝手に checkout しない。対象ブランチへの移動または worktree 作成が必要なら確認する。
- GitHub へのコメント投稿、thread resolve、review submit は外部状態を変えるため、投稿内容を提示して確認してから実行する。
- 返信文だけ求められた場合はコードを編集しない。修正対応を求められた場合だけ実装する。
- outdated / resolved / bot の重複コメントは対応対象から外し、必要なら「除外理由」に残す。
- レビューコメントをすべて鵜呑みにしない。仕様確認が必要なものは質問に分類する。

## 入力

呼び出し側は取れる範囲で次を用意する:

- 対象 PR: URL / 番号 / 現在ブランチの PR
- PR 情報: title, body, author, base/head, reviewDecision, mergeStateStatus
- review threads: unresolved / resolved, outdated, path, line, body, author, url
- PR comments と latest reviews
- CI/checks の失敗概要
- diff と変更ファイル一覧
- ユーザーの意図: 修正まで行う / 返信案だけ / コメント投稿まで行う

## コメント取得

PR の全体情報は `gh pr view`、inline review comments は REST API、未解決 thread は GraphQL を優先する。

- `gh pr view {target} --json number,title,body,url,author,headRefName,baseRefName,reviewDecision,mergeStateStatus,latestReviews,comments,files`
- `gh pr diff {target}`
- `gh pr checks {target}`（取得できる場合）
- `gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate`
- `gh api graphql` で `pullRequest.reviewThreads` を取得し、`isResolved` / `isOutdated` / `comments.nodes` を見る

GraphQL が失敗した場合は REST と `gh pr view` の情報だけで続行し、未解決 thread の精度が落ちることを明記する。

## 分類

各コメントを 1 つの主分類に入れる。迷ったら上に倒す。

| 分類 | 条件 | 対応 |
|---|---|---|
| `MUST_FIX` | Requested changes、bug/security/data loss、CI failure、明確な仕様違反 | 修正して検証する |
| `SHOULD_FIX` | 保守性、型安全性、テスト不足など実害が説明できる | 原則修正する |
| `QUESTION` | 仕様・意図・トレードオフ確認が必要 | 質問返信を作る |
| `EXPLAIN` | 実装意図の説明で解決しそう | 根拠付き返信を作る |
| `OPTIONAL` | 好み、将来改善、nit、MAY | まとめて任意対応にする |
| `SKIP` | resolved、outdated、重複、bot noise、変更範囲外 | 除外理由だけ残す |

分類時は次を保持する:

- comment/thread URL
- author
- file:line（あれば）
- 指摘要約
- 対応方針
- 修正対象ファイル
- 返信ドラフト

## ワークフロー

1. **対象確定**: 引数がなければ `gh pr view --json number,url,headRefName` で現在ブランチの PR を探す。見つからない場合は終了する。
2. **作業場所確認**: `git status --short` と現在ブランチを確認する。対象 PR と違うブランチなら、checkout / worktree 作成の確認を取る。
3. **コメント収集**: review threads、PR comments、latest reviews、CI/checks を取得する。
4. **分類表作成**: 上記の分類で対応一覧を作る。`MUST_FIX` / `SHOULD_FIX` / `QUESTION` を先頭に並べる。
5. **対応方針提示**: 修正する項目、質問する項目、スキップする項目を短く提示する。大量なら件数と代表例に圧縮する。
6. **修正実装**: ユーザーが修正対応を求めている場合、`MUST_FIX` と `SHOULD_FIX` を小さく直す。無関係なリファクタを混ぜない。
7. **検証**: 変更内容に応じて lint / typecheck / test / build を実行する。実行できない検証は理由を残す。
8. **返信ドラフト作成**: 各 thread/comment に対して、対応内容・検証結果・質問を 1〜3 文で書く。
9. **投稿確認**: コメント投稿または thread resolve を行う前に、投稿対象と文面を提示して確認する。
10. **投稿 / resolve**: 確認が取れた場合だけ `gh api graphql` や `gh pr comment` で実行する。失敗したら手動投稿用の文面を残す。

## 返信文の基準

- 日本語で簡潔に書く。相手の指摘を復唱しすぎない。
- 修正した場合: 「対応内容」と「確認したコマンド」を含める。
- 仕様確認の場合: 判断に必要な選択肢か前提を明示する。
- 対応しない場合: 理由を短く書き、必要なら代替案を出す。
- 複数コメントへ同じ返信を機械的に貼らない。各 thread の文脈に合わせる。

例:

```md
ご指摘の通り境界値の扱いが漏れていたため、`null` の場合は早期 return するよう修正しました。`pnpm test` で関連テストが通ることを確認しています。
```

```md
ここは既存 API の互換性を優先して現在の形にしています。次のメジャー更新でレスポンス形式を揃える方針なら、この PR では TODO コメントだけ追加するのがよいと考えています。
```

## 出力

最終報告は次の形式にする:

```markdown
# Review Respond Report

## 対象
- PR: {url}
- Branch: {headRefName}
- Review decision: {reviewDecision}

## 対応サマリー
- MUST_FIX: {n} 件
- SHOULD_FIX: {n} 件
- QUESTION: {n} 件
- EXPLAIN/OPTIONAL/SKIP: {n} 件

## 修正した内容
- ...

## 検証
- `command`: PASS/FAIL/SKIPPED（理由）

## 返信ドラフト
### {comment url}
- 分類: MUST_FIX
- 本文: ...

## 投稿状態
- POSTED / NOT_POSTED / PARTIAL
```

## 失敗モード

- **コメント取得不能**: `gh auth status` と対象 PR URL を確認し、取れた情報だけで分類する。
- **対象ブランチ不一致**: 修正せず、対象 PR の branch/worktree に移る確認を取る。
- **未コミット変更あり**: 既存変更とレビュー対応が衝突しそうなら、どのファイルが衝突するか示して止める。
- **CI が外部でしか再現できない**: `gh pr checks` の失敗 job とログ URL を残し、ローカル検証できた範囲を明記する。
- **投稿 API が失敗**: 投稿済み / 未投稿を分け、未投稿分は手動で貼れる形に残す。
