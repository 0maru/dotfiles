source "$ZDOTDIR/nonlazy.zsh"

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# starship
eval "$(/opt/homebrew/bin/brew shellenv)"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

eval "$(starship init zsh)"
eval "$(sheldon source)"
eval "$(mise activate zsh)"

# history
export HISTFILE="$XDG_STATE_HOME/zsh_history"
export HISTSIZE=1000
export SAVEHIST=30000

# gpg
export GPG_TTY=$(tty)

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

# Load local settings (not tracked by git)
[[ -f "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"

