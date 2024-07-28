# history
export HISTFILE="$XDG_STATE_HOME/zsh_history"
export HISTSIZE=1000
export SAVEHIST=30000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_save_no_dups

source "$ZDOTDIR/nonlazy.zsh"

# brew でインストールしたsheldon を使いたいので先にbrew を有効化する
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(sheldon source)"

zstyle ':completion:*:setopt:*' menu true select

function ghq-fzf() {
  local src=$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^g' ghq-fzf
