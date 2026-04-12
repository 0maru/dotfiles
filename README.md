# dotfiles

## Installing

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/0maru/dotfiles/main/install.sh)"
```

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
