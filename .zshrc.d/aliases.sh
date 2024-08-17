# The follwing is copied from my original .zshrc
alias prj="cd /Users/kirill/Desktop/Projects"
alias python3.9='/usr/bin/python3'
alias remote='ssh cyrillus@213.159.208.102'
alias devscience='ssh ivan@10.242.107.104'

alias src="source ~/.zshrc; echo ~/.zshrc file was reloaded"
alias clown="echo this is from clown"

# this makes so that 'python' command calls python3.11 even inside 3.9 environment 
alias python=/opt/homebrew/bin/python3.11

alias nvimk='NVIM_APPNAME="nvim-kickstart" nvim'

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"


# Autocomplete
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


# NeoVim
alias n=_run_and_update_nvim
