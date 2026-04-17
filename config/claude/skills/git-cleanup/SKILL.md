---
name: git-cleanup
description: リモートで削除されたブランチのローカルクリーンアップと不要な git worktree の削除を行うスキル。「ブランチ削除」「ブランチ掃除」「gone ブランチ削除」「worktree 削除」「worktree 掃除」「git クリーンアップ」「upstream ブランチ削除」「不要なブランチを消して」と言われた時に使用する。
---

# Git クリーンアップスキル

リモートで削除済みの `[gone]` ブランチと、不要な git worktree を一括でクリーンアップする。

## 基本ルール

- 現在チェックアウト中のブランチ（`main` 等）は削除しない
- 削除前にユーザーに対象一覧を提示し、確認を取る
- worktree 削除の対象: [gone] ブランチに紐づくもの、および孤立した（リンク切れの）worktree

## Phase 1: 状態の確認

リモートの最新情報を取得し、ローカルの状態を確認する。

### 1-1. リモート追跡情報を最新化し、孤立 worktree をクリーンアップ

```bash
git fetch --prune
git worktree prune
```

`git fetch --prune` がネットワークエラーで失敗した場合は、ローカル情報のみで続行する旨をユーザーに伝える。

### 1-2. ブランチの状態一覧を取得

```bash
git branch -vv
```

出力から以下を分類する:

- **[gone] ブランチ**: リモートで削除済み（`[origin/...: gone]` と表示）
- **追跡なしブランチ**: リモート追跡が設定されていないローカルブランチ（`main` 以外）
- **現在のブランチ**: `*` が付いているブランチ（削除対象外）

### 1-3. worktree の状態を確認

```bash
git worktree list
```

worktree 一覧を取得し、以下を特定する:
- [gone] ブランチに紐づく worktree
- メインリポジトリ以外の worktree（ブランチ名で照合）

## Phase 2: 削除対象の提示と確認

Phase 1 の結果をもとに、以下の形式でユーザーに削除対象を提示する。

```
削除対象:

[gone] ブランチ:
  - feature/xxx (worktree: /path/to/worktree)
  - feature/yyy

追跡なしブランチ (main 以外):
  - feature/zzz

不要な worktree:
  - /path/to/worktree [feature/xxx]
```

AskUserQuestion ツールを使って確認を取る:

- 「すべて削除」
- 「[gone] ブランチのみ削除」
- 「キャンセル」

## Phase 3: クリーンアップの実行

ユーザーの選択に基づいて削除を実行する。**worktree → ブランチの順で削除する**（逆にするとブランチ削除が失敗する）。

### 3-1. worktree の削除

worktree がある場合は、ブランチ削除前に worktree を先に削除する。

```bash
git worktree remove --force "<worktree-path>"
```

`git worktree remove` が失敗した場合（未コミットの変更がある等）は、そのブランチをスキップしてユーザーに報告する。

### 3-2. ブランチの削除

```bash
git branch -D "<branch-name>"
```

### 3-3. 結果の報告

削除結果を以下の形式で報告する:

```
クリーンアップ完了:
  - 削除したブランチ: N 件
  - 削除した worktree: N 件
  - スキップ（エラー）: N 件
  - 残っているブランチ: main
```

削除対象がなかった場合は「クリーンアップ不要です」と報告する。
