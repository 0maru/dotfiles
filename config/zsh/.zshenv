# ~/.zshenvが読み込まれてから~/.config/sh 内のファイルの順番で読み込まれる
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# XDG Base Directory (https://wiki.archlinux.jp/index.php/XDG_Base_Directory)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# sheldon (https://sheldon.cli.rs/)
export SHELDON_CONFIG_DIR="$ZDOTDIR"

# git
GIT_CONFIG="$XDG_CONFIG_HOME/git/config"

# starship
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# venv
export PIPENV_VENV_IN_PROJECT=1

# mysql-client
export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql-client@8.0/lib/pkgconfig"

# brew shellenv の静的展開（eval不要で高速）
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
