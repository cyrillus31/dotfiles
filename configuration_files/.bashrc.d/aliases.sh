#!/bin/bash

# alias prj="cd $HOME/Projects/; ls"
# alias prj="cd $(find ~/Projects/ -maxdepth 2 -type d -not -name '.*' -and -not -name 'Projects' |  fzf); nvim .;"

function _remote() {
 if [[ -z $1 ]]; then 
    ssh cyrillus@213.159.208.102;
  else
    ssh $1@213.159.208.102;
 fi;
}

alias remote='clear; _remote'
alias sysd="cd /etc/systemd/system/"
alias open="gnome-open"
alias devscience='clear; ssh ivan@10.242.107.104'
alias wacomsetup='_wacomsetup' # see functions.sh
