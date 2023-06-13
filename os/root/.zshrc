. ~/.bash_aliases

setopt +o nomatch

eval $(rtx env)

[ -z "$PS1" ] && return

. ~/.zinit.zsh
eval "$(rtx activate --quiet zsh)"

autoload -Uz compinit && compinit -u

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
setopt extended_glob

eval "$(atuin init zsh --disable-up-arrow)"
