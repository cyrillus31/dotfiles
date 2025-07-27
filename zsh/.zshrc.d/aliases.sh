#!/bin/zsh

# Import aliases that are not for sharing in version control
source $HOME/.bashrc.d/private.sh &>/dev/null || true

alias bpy="cd $ARC_DIR/taxi/backend-py3/"
alias bgo="cd $ARC_DIR/taxi/backend-go/"

