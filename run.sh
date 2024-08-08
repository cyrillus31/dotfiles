#!/bin/bash

# sudo apt install stow


function rec_link() {
  root=$1
  dotfiles_path=$2
  for file in $(ls -A $root); do
    echo $root/$file
    ln $root/$file $dotfiles_path/$file
    # if [[ -f $file ]]; then
    #   ln $file
  done;
}

for smth in $(ls -A); do
  dotfiles_path=$(pwd)
  path=$smth
  if [[ -d $smth && $smth != "." && $smth != ".."  && $smth != ".git" ]]; then
    # echo $HOME/$path
    check_path=$HOME/$path  
    rec_link $check_path $dotfiles_path
  fi;
  break
done;

