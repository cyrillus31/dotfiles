#!/bin/bash

function create_backup () {
  if [[ -f $1 ]]; then 
    d="$(date +'_%Y-%m-%d_%H-%M')"
    mv  "$1"{,$d.bak} && \
    echo "Backup file '$1$d.bak' was created" >&/dev/null || \
    echo "Something went wrong with file '$1'!"
  else
    echo "File '$1' doesn't exist"
  fi
}

create_backup "$HOME/.zshrc";
create_backup "$HOME/.zshrc.d";
create_backup "$HOME/.zprofile";

create_backup "$HOME/.bashrc";
create_backup "$HOME/.bashrc.d";
create_backup "$HOME/.profile";
