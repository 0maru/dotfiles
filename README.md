# dotfiles

## Installing

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/0maru/dotfiles/main/install.sh)"
```

## ツールの更新

ツールは `nixpkgs-unstable` から入り、バージョンは `flake.lock` にピン留めされています（パッケージ一覧は `nix/home.nix` の `home.packages`）。更新は「flake input の更新 → 再適用」の流れで行います。

```bash
# 1. flake input を更新（nixpkgs / home-manager / nix-darwin の lock を最新に）
nix flake update

# 2. 差分を確認（どの input がどこまで上がったか）
git diff flake.lock

# 3. 適用（scripts/setup-nix.sh と同じコマンド）
sudo nix run .#darwin-rebuild -- switch --flake ".#$USER"

# 4. 問題なければコミット
git add flake.lock && git commit -m "chore: update flake inputs"
```

### 補足

- **個別更新**: 全部上げると差分の切り分けが難しくなるため、`nix flake update nixpkgs` のように input 単位で上げることもできます。
- **ロールバック**: `darwin-rebuild` は世代管理されるため、不調なら `darwin-rebuild --rollback`、または `flake.lock` を `git revert` して再適用すれば戻せます。
- **頻度**: unstable 追従なので週1〜隔週程度が目安です。

## Zsh ファイル構成

`config/zsh/` 内のファイルは役割ごとに分かれています。新しい設定を追加する際は以下の基準で配置先を決めてください。

### 読み込み順

```
.zshenv → .zshrc → nonlazy.zsh（即時）
                  → lazy.zsh（zsh-defer で遅延）
                  → local.zsh（最後）
```

### 各ファイルの役割

| ファイル | 役割 | 追加する設定の例 |
|---|---|---|
| `.zshenv` | 環境変数（全シェルで必要なもの） | `XDG_*`, `LANG`, `EDITOR`, `SSH_AUTH_SOCK` |
| `.zshrc` | シェルの初期化 | `eval "$(ツール init zsh)"`, `setopt`, `compinit` |
| `nonlazy.zsh` | PATH 設定 | `export PATH="...:$PATH"` |
| `lazy.zsh` | エイリアス・関数・キーバインド | `alias`, `function`, `bindkey` |
| `local.zsh` | マシン固有の設定（git 管理外） | 仕事用トークン、社内ツールの PATH、環境別エイリアス |
| `plugins.toml` | sheldon プラグイン定義 | zsh プラグインの追加・削除 |

### 判断フロー

1. **非インタラクティブシェル（スクリプト実行時）でも必要？** → `.zshenv`
2. **PATH の追加？** → `nonlazy.zsh`
3. **ツールの初期化（eval）や setopt？** → `.zshrc`
4. **エイリアス・関数・キーバインド？** → `lazy.zsh`
5. **このマシンだけの設定？** → `local.zsh`
