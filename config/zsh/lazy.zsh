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
alias e=code

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

