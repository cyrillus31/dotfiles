alias src="source ~/.bashrc && echo '~/.bashrc file was succesfully reloaded.'"

# DOCKER
alias denter="_enter_docker"
alias dc="docker-compose"
alias drm="_remove_all_containers"
alias dstop="_stop_all_containers"

alias sysd="cd /etc/systemd/system/"

alias ll="ls -l --color=auto"
alias la="ls -A --color=auto"
alias lla="ls -lA --color=auto"

# alias python="/usr/local/bin/python3.10"
# alias pip="/usr/local/bin/pip3.10"
alias amend="git add .; git commit --amend"


# NeoVim
# alias nvimk='NVIM_APPNAME="nvim-kickstart" nvim'
# alias nvim='NVIM_APPNAME="nvim-kickstart" nvim'

# Wacom Drawing Tablet Setup
alias wacomsetup="wacomsetup_function"


PRIVATE=$HOME/.bashrc.d/private_aliases.sh
if [ -f $PRIVATE ]; then surce $PRIVATE; fi;
