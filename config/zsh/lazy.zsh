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
alias e='code-insiders'

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

# lazygit
alias lg=lazygit

# flutter
alias fcg='flutter clean && flutter pub get'
alias fbb='flutter pub run build_runner build --delete-conflicting-outputs'
alias fbw='flutter pub run build_runner watch'

alias globalip='curl -s https://inet-ip.info'

# docker
alias dredis='docker run -d --rm -p 6379:6379 redis:latest's
