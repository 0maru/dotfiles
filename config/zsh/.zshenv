# XDG Base Directory (https://wiki.archlinux.jp/index.php/XDG_Base_Directory)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# sheldon (https://sheldon.cli.rs/)
export SHELDON_CONFIG_DIR="$ZDOTDIR"

