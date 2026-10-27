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

# Set signing before Git starts; hooks cannot change the parent Git process.
# Append to preserve Git settings inherited from the caller.
if [[ -n "${CODEX_THREAD_ID:-}" ]]; then
  export "GIT_CONFIG_KEY_${GIT_CONFIG_COUNT:-0}=commit.gpgsign"
  export "GIT_CONFIG_VALUE_${GIT_CONFIG_COUNT:-0}=false"
  export GIT_CONFIG_COUNT=$(( ${GIT_CONFIG_COUNT:-0} + 1 ))
fi

# venv
export PIPENV_VENV_IN_PROJECT=1

# 1Password ssh
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
