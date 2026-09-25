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

外部 tap の SketchyBar と AeroSpace は Brewfile の `trusted: true` で個別に信頼する。AeroSpace は cask として導入する。仕様は [Homebrew の Tap Trust](https://docs.brew.sh/Tap-Trust) と [Brewfile の trusted](https://docs.brew.sh/Brew-Bundle-and-Brewfile#trusted) を参照。

Brewfile 内の Mac App Store アプリには App Store へのサインインが必要になる。`mas "Xcode"` はフル版 Xcode の指定で、最初に確認する Command Line Tools とは別に扱う。

スクリプトの回帰テストと静的チェックは次で実行する。回帰テストは実際の OS・パッケージ導入を行わない。

```bash
python3 -B -m unittest discover -s scripts/tests -p 'test_*.py' -v
shellcheck -x install.sh scripts/setup.sh scripts/setup-brew.sh
```
