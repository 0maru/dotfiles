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
  local ghq_root="$(ghq root)"
  local src=$(ghq list \
    | grep -E '^github\.com/' \
    | grep -vE '^(company|personal)-agent-runs/' \
    | fzf --preview "bat --color=always --style=header,grid --line-range :80 ${ghq_root}/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd ${ghq_root}/$src"
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
  local selected branch worktree_path
  selected=$(
    git for-each-ref --format='%(refname)%09%(refname:short)%09%(worktreepath)' refs/heads refs/remotes |
    awk -F '\t' '
      $1 == "refs/remotes/origin/HEAD" { next }
      $1 ~ "^refs/heads/" {
        name = $2
        local_seen[name] = 1
        worktree[name] = $3
        local_order[++local_count] = name
        next
      }
      $1 ~ "^refs/remotes/origin/" {
        name = $2
        sub(/^origin\//, "", name)
        if (!(name in remote_seen)) {
          remote_seen[name] = $2
          remote_order[++remote_count] = name
        }
      }
      END {
        for (i = 1; i <= local_count; i++) {
          name = local_order[i]
          printf "%s\t%s\n", name, worktree[name]
        }
        for (i = 1; i <= remote_count; i++) {
          name = remote_order[i]
          if (!(name in local_seen)) {
            printf "%s\t\n", remote_seen[name]
          }
        }
      }
    ' |
    fzf --delimiter=$'\t' --with-nth=1,2 --preview='branch=$(printf "%s" {} | cut -f1); git plog --color=always "$branch" 2>/dev/null || git plog --color=always "${branch#origin/}"'
  )
  if [ -n "$selected" ]; then
    branch=${selected%%$'\t'*}
    worktree_path=${selected#*$'\t'}
    if [ "$worktree_path" = "$selected" ]; then
      worktree_path=""
    fi
    branch=${branch#origin/}
    if [ -n "$worktree_path" ]; then
      BUFFER="cd ${(q)worktree_path}"
    else
      BUFFER="git switch ${(q)branch}"
    fi
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
bindkey 'x;' run_claude

# codex
function run_codex() {
  BUFFER="codex"
  zle accept-line
}
zle -N run_codex
bindkey 'z;' run_codex

alias ccu='bunx ccusage@latest'
