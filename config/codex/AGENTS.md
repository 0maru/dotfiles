# 作業方針

- まず関連ファイル・既存実装・設定を確認してから編集する
- 変更は依頼範囲に限定し、無関係な差分を巻き込まない
- 既存のコーディング規約・ツールチェーン・ディレクトリ構成を優先する
- 方針が固まったら、小さく安全な単位で自走して進める

# ローカル便利ツール

- 簡単な自作 CLI や便利ツールは、原則として `~/workspaces/github.com/0maru/tools` に実装する
- 既存の便利ツールを探すときも、dotfiles だけでなく `tools` を確認する

# Git リポジトリ配置

- Git リポジトリを clone するときは `git clone` ではなく `ghq get {url}` を使い、`~/workspaces` 配下に配置する
- GitHub リポジトリのローカルパスは通常 `~/workspaces/github.com/{owner}/{repo}` になる
- リポジトリの取得・探索では `ghq get {url}`、`ghq list -p -e {owner}/{repo}`、`ghq list -p` を優先して使う
- `ghq` の設定はこの dotfiles リポジトリ内の `config/git/conf.d/ghq.conf` にあり、`config/git/config` から include されている
- 別リポジトリを探す必要がある場合は、未取得と決めつける前に `ghq` と `~/workspaces` 配下を確認する

# 実装作業のデフォルトフロー

- Git 管理されたリポジトリで実装・修正を依頼されたら、編集を始める前に専用の worktree と作業ブランチを用意する
- 同じタスクの worktree・ブランチ・PR が存在する場合は再利用し、重複して作成しない
- 実装と必要な検証後は、commit・push・Ready for review の PR 作成まで進める。既存 PR があれば更新する。これらは実装・修正依頼に含まれるものとして、追加の指示や確認を待たずに進める
- 質問・調査・レビューのみの依頼は、このフローの対象外とする
- ユーザーが作業場所や終了地点を指定した場合は、その指示を優先する

# 変更と検証

- 変更後は対象に応じてテスト・lint・format・型チェックを実行する
- 実行できなかった検証や既知のリスクは最後に明示する
- 影響範囲が広い変更は、先に分割して安全に進められないか検討する

# Git と外部操作

- 破壊的な Git 操作は自動実行しない
- commit、push、PR 作成、issue 作成など履歴や外部状態を変える操作は確認可能な形で扱う
- Codex が PR を作成する場合、明示指示がない限り Draft ではなく Ready for review にする
- GitHub plugin / yeet 系のフローでも、Draft PR 作成指示より Ready for review 方針を優先する
- 既存 PR を返す場合に Draft なら、PR URL 返却前に `gh pr ready` で Ready for review にする
- ユーザーが作成した差分を勝手に巻き戻さない

# 応答言語

- ユーザーへの回答は原則として日本語で行う
- コード、コマンド、ログ、エラーメッセージ、固有名詞は必要に応じて原文のまま扱う

# コメントとドキュメント

- コメントは日本語で記載する
- 追加する説明は簡潔にし、コードから読み取りづらい判断理由だけを書く

## 注意事項

以下のリポジトリでは英語でコメントする

- gh-zen

## GitHub PR

- Codex が PR を作成・更新する場合、PR タイトルに `[codex]`、codex:`、`Codex` などのエージェント識別子を含めない
- PR タイトルは squash merge のコミットタイトルに使われる前提で、変更内容だけを簡潔に書く
- Codex が新規作成するブランチ名は `agent/codex/<変更内容>` 形式にする
- 複数 PR をまとめて作成する場合、関連・依存のある変更は stacked PR を基本方針にする
- stacked PR では後続 PR の base を直前の PR ブランチにし、完全に独立した変更のみ `main` などの共通ベースで並列 PR にする
- GitHub Issue 起因の実装では Issue の内容と完了条件を確認し、PR 本文に元 Issue を紐づける。対応を完了する Issue ごとに `Closes #<番号>`（別リポジトリなら `Closes <owner>/<repo>#<番号>`）を記載し、マージ時に Completed として自動クローズされるようにする
- Issue の一部だけを対応する PR は `Refs #<番号>` で参照し、対応がすべて完了する最終 PR にだけ closing keyword を付ける。PR 作成時点では Issue をクローズしない
- closing keyword による自動クローズは default branch へのマージ時に働く。stacked PR をまとめて取り込む場合は、完了対象 Issue の closing keyword を default branch にマージする PR の本文へ引き継ぐ。base の変更時にも紐づけを確認する
- リポジトリで自動クローズが無効など、紐づけだけでは閉じられない場合はその理由を報告する。手動で閉じる場合も、必要な変更のマージと Issue の完了を確認してから `gh issue close <Issue URL> --reason completed` を使う
- PR レビューコメントの修正を依頼された場合、修正・検証後に対象の GitHub review thread へ必ず返信する
- 返信できない場合は、理由と投稿すべき返信文を最終回答に含める
- review thread の resolve は、明示指示がある場合のみ実行する
- PR のレビュー監視では、コメントだけでなく PR 本文のリアクションも確認する。`chatgpt-codex-connector[bot]` の 👍（`+1`）があればレビュー完了と判断し、追加確認を求めずに監視を終了する
