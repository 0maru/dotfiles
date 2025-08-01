source "$ZDOTDIR/nonlazy.zsh"

# export
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="$HOME/workspaces/github.com/0maru/tools/go/build:$PATH"
export PIPENV_VENV_IN_PROJECT=1

# brew でインストールしたsheldon を使いたいので先にbrew を有効化する
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
eval "$(sheldon source)"
eval "$(mise activate zsh)"

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
setopt hist_no_store
setopt hist_expand
setopt share_history
setopt no_beep

autoload -U compinit
compinit
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:setopt:*' menu true select

# fzf のシェル統合
source <(fzf --zsh)
# ghq + fzf でgit のリポジトリを一覧で表示してリポジトリを切り替える
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

# fzf でgit のブランチを一覧で表示してブランチを切り替える
function git-branches-fzf() {
  local branch=$(
    git branch -a |
    fzf --preview="echo {} | tr -d ' *' | xargs git plog --color=always" |
    head -n 1 |
    perl -pe "s/\s//g; s/\*//g; s/remotes\/origin\///g"
  )
  if [ -n "$branch" ]; then
    BUFFER="git switch $branch"
    zle accept-line
  fi
  zle -R -c
}
zle -N git-branches-fzf
bindkey '^b' git-branches-fzf


function open_lazygit() {
  lazygit
}
zle -N open_lazygit
bindkey '^l' open_lazygit

alias d='docker'
alias diclean='d image prune'
alias dcclean='d container prune'
alias ccu='npx ccusage@latest'
export PATH="$PATH:/$HOME/Library/Android/sdk/platform-tools"
export PATH="$PATH:$HOME/workspaces/github.com/0maru/cwm"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
