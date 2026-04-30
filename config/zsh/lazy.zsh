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

# codex
function run_codex() {
  BUFFER="codex"
  zle accept-line
}
zle -N run_codex
bindkey 'x;' run_codex

# Claude Code と OpenAI Codex の daily 使用量をまとめて表示する
function ccu() {
  emulate -L zsh -o pipefail

  local cc_json cx_json current_month previous_month year month previous_year previous_month_number
  current_month=$(date +%Y-%m) || return
  year=$(date +%Y) || return
  month=$(date +%m) || return

  if (( 10#$month == 1 )); then
    previous_year=$((year - 1))
    previous_month_number=12
  else
    previous_year=$year
    previous_month_number=$((10#$month - 1))
  fi
  previous_month=$(printf "%04d-%02d" "$previous_year" "$previous_month_number") || return

  cc_json=$(pnpm dlx ccusage daily --json "$@") || return
  cx_json=$(pnpm dlx @ccusage/codex@latest daily --json "$@") || return

  {
    print -r -- "$cc_json"
    print -r -- "$cx_json"
  } | jq -r -s --arg previous_month "$previous_month" --arg current_month "$current_month" '
    def pad2:
      tostring | if length == 1 then "0" + . else . end;
    def month_number($month):
      {
        Jan: "01", Feb: "02", Mar: "03", Apr: "04",
        May: "05", Jun: "06", Jul: "07", Aug: "08",
        Sep: "09", Oct: "10", Nov: "11", Dec: "12"
      }[$month] // $month;
    def normalize_date:
      if type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$") then
        .
      elif type == "string" and test("^[A-Z][a-z]{2} [0-9]{1,2}, [0-9]{4}$") then
        capture("^(?<month>[A-Z][a-z]{2}) (?<day>[0-9]{1,2}), (?<year>[0-9]{4})$") as $date |
        "\($date.year)-\(month_number($date.month))-\($date.day | tonumber | pad2)"
      else
        .
      end;
    def daily_by_date($cost_key):
      reduce .[] as $row (
        {};
        ($row.date | normalize_date) as $date |
        .[$date].totalTokens += (($row.totalTokens // 0) | tonumber) |
        .[$date].cost += (($row[$cost_key] // 0) | tonumber)
      );

    .[0] as $cc |
    .[1] as $cx |
    ($cc.daily // []) as $ccDaily |
    ($cx.daily // []) as $cxDaily |
    ($ccDaily | daily_by_date("totalCost")) as $ccByDate |
    ($cxDaily | daily_by_date("costUSD")) as $cxByDate |
    (($ccByDate | keys) + ($cxByDate | keys) | unique | sort |
      map(select((.[0:7] == $previous_month) or (.[0:7] == $current_month)))) as $dates |
    ($dates | map(
      . as $date |
      [
        $date,
        ($ccByDate[$date].totalTokens // 0),
        ($ccByDate[$date].cost // 0),
        ($cxByDate[$date].totalTokens // 0),
        ($cxByDate[$date].cost // 0),
        (($ccByDate[$date].totalTokens // 0) + ($cxByDate[$date].totalTokens // 0)),
        (($ccByDate[$date].cost // 0) + ($cxByDate[$date].cost // 0))
      ]
    )) as $rows |
    ($rows[]),
    [
      "Total",
      ($rows | map(.[1]) | add // 0),
      ($rows | map(.[2]) | add // 0),
      ($rows | map(.[3]) | add // 0),
      ($rows | map(.[4]) | add // 0),
      ($rows | map(.[5]) | add // 0),
      ($rows | map(.[6]) | add // 0)
    ] | @tsv
  ' |
    awk -F '\t' '
      BEGIN {
        print "Date\tClaude Tokens\tClaude USD\tChatGPT Tokens\tChatGPT USD\tTotal Tokens\tTotal USD"
      }
      {
        printf "%s\t%d\t$%.2f\t%d\t$%.2f\t%d\t$%.2f\n", $1, $2, $3, $4, $5, $6, $7
      }
    ' |
    column -t -s $'\t'
}
