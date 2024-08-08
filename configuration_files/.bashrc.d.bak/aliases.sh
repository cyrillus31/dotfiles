#!/bin/bash

# Import aliases that are not for sharing in version control
source $HOME/.bashrc.d/private_aliases.sh

# alias prj="cd $HOME/Projects/; ls"
# alias prj="cd $(find ~/Projects/ -maxdepth 2 -type d -not -name '.*' -and -not -name 'Projects' |  fzf); nvim .;"

alias sysd="cd /etc/systemd/system/"
alias open="gnome-open"
alias wacomsetup='_wacomsetup' # see functions.sh

