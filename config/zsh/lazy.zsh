# git
alias g=git
alias P='git pull origin $(git branch --show-current)'

# cd
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# editor
alias v=nvim
alias vim=v
alias vi=v
e() { code "${@:-.}"; }

# ls
alias ei='eza --icons'
alias ls=ei
alias ea='eza -a --icons'
alias la=ea
alias ee='eza -aal --icons'
alias ll=ee
alias et='eza -T -L 3 -I "node_modules|.git|.cache" --icons'
alias lt=et
alias eta='eza -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
alias lta=eta

# ghq
alias update='ghq list | ghq get --update --parallel'

# tmux
alias t='tmux attach || tmux'

# flutter
alias fcg='flutter clean && flutter pub get'
alias fbb='flutter pub run build_runner build --delete-conflicting-outputs'
alias fbw='flutter pub run build_runner watch'

alias globalip='curl -s https://inet-ip.info'

# docker
alias d='docker'
alias dredis='docker run -d --rm -p 6379:6379 redis:latest'
alias diclean='d image prune'
alias dcclean='d container prune'

# wezterm のタブを4分割する
# ┌──────┬────────────┬──────┐
# │      │            │      │
# │ 25%  │    50%     │ 25%  │
# │      │            │      │
# │      │            ├──────┤
# │      │            │      │
# └──────┴────────────┴──────┘
4pane() {
  local ratios=(25 50 25)  # 左, 中央, 右
  local total=$((ratios[1] + ratios[2] + ratios[3]))
  local right_pct=$(( (ratios[2] + ratios[3]) * 100 / total ))
  local far_right_pct=$(( ratios[3] * 100 / (ratios[2] + ratios[3]) ))

  local pane_right=$(wezterm cli split-pane --right --percent $right_pct)
  local pane_mid=$(wezterm cli split-pane --right --percent $far_right_pct --pane-id "$pane_right")
  wezterm cli split-pane --bottom --percent 30 --pane-id "$pane_mid"
  wezterm cli activate-pane-direction Left
  wezterm cli activate-pane-direction Left
}

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
bindkey -M viins '^g' ghq-fzf
bindkey -M vicmd '^g' ghq-fzf

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
bindkey '^o' open_lazygit

# claude
function run_claude() {
  BUFFER="claude --permission-mode auto"
  zle accept-line
}
zle -N run_claude
bindkey 'c;' run_claude
