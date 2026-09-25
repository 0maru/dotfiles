# macOS のセットアップ

`install.sh` は Command Line Tools を確認してから dotfiles を取得・更新し、Nix、Homebrew、設定ファイルの順にセットアップする。

Command Line Tools が未導入なら macOS のインストール画面が開く。画面でインストールを承認すると、スクリプトは完了を最大30分待って続行する。画面を閉じた場合は `Ctrl-C` で中止し、導入完了後に再実行する。画面を表示できない環境では、先に Command Line Tools を導入する。

既に dotfiles を取得している場合は、リポジトリのルートで実行する。

```bash
bash scripts/setup.sh
```

Homebrew の処理からやり直す場合は次を実行する。Command Line Tools の確認はこの入口でも行う。

```bash
bash scripts/setup-brew.sh
```

Apple Silicon の `/opt/homebrew`、Intel Mac の `/usr/local` にある Homebrew は、PATH が未設定でも検出する。

Homebrew が作成した `$XDG_CONFIG_HOME/homebrew`（通常は `~/.config/homebrew`）は実ディレクトリのまま残し、`Brewfile` だけをリンクする。`trust.json` などの既存データは保持する。旧構成のディレクトリ単位のリンクは引き続き利用できる。

リンク作成で止まった場合は、修正を取り込んだ後に次で再開できる。

```bash
bash scripts/setup-link.sh
```

外部 tap の SketchyBar と AeroSpace は Brewfile の `trusted: true` で個別に信頼する。AeroSpace は cask として導入する。仕様は [Homebrew の Tap Trust](https://docs.brew.sh/Tap-Trust) と [Brewfile の trusted](https://docs.brew.sh/Brew-Bundle-and-Brewfile#trusted) を参照。

Brewfile 内の Mac App Store アプリには App Store へのサインインが必要になる。`mas "Xcode"` はフル版 Xcode の指定で、最初に確認する Command Line Tools とは別に扱う。

スクリプトの静的チェックは次で実行する。

```bash
shellcheck -x install.sh scripts/setup.sh scripts/setup-brew.sh
```

## AI エージェントの Git 作業

Codex / Claude Code の実装用 worktree では、それぞれ `agent/codex/...` / `agent/claude/...` の名前付きブランチを使う。`agent/**` では条件付き include によりエージェント用の作者情報と `commit.gpgsign=false` が適用される。detached HEAD ではこの条件に一致しない。

Git 2.54 以降の設定フックで、新規ブランチの命名と detached HEAD でのコミットを検査する。`CODEX_THREAD_ID` または `CLAUDECODE` がある場合のみ動作し、既存のリポジトリフックと併用できる。署名処理前の [`prepare-commit-msg`](https://git-scm.com/docs/githooks#_prepare_commit_msg) で停止するため、案内に従って作業ブランチを作成してから再実行する。調査用の detached worktree と、名前付きブランチの rebase 中に Git が一時的に作る detached HEAD は許容する。

共通指示は `config/codex/AGENTS.md` と `config/claude/CLAUDE.md` で管理する。スキルが detached worktree を作成する場合も、編集前に名前付きブランチへ切り替える。既存 PR への push は一時作業ブランチ名ではなく、確認した PR の head ブランチを明示する。
