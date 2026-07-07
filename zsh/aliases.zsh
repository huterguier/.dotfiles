case "$(uname -s)" in
  Darwin) alias ls='ls -G' ;;
  Linux)  alias ls='ls --color=auto' ;;
esac

alias ll='ls -lh'
alias la='ls -lAh'

alias vim='nvim'
alias vi='nvim'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gp='git pull'
