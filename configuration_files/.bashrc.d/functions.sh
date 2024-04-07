#!/bin/bash

function src {
  source $HOME/.bashrc
  echo \~/.bashrc was reloaded
  return 0
}


function activatev {
  if [[ -d ./venv ]]; then
    source ./venv/bin/activate;
  elif [[ -d ../venv ]]; then
    source ../venv/bin/activate;
  else
    echo "'venv' folder was not found in the current and parent directory";
    return 1
  fi;
  echo "Virtual environment was activated"
  return 0
}

function prj {
  if [[ -z $1 ]]; then
    target=$(find ~/Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf)
  else
    target=$(find ~/Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf -q $1)
  fi;

  if [[ $? == 0 ]]; then
    cd $target; 
    target_name=$(echo $target | sed -E 's/(.*)\/(.*$)/\2/')
    tmux_session="prj_$target_name";
    tmux ls | grep "$tmux_session": &>/dev/null
    if [[ $? != 0 ]]; then
      tmux new -s $tmux_session bash -c nvim .;
    else
      tmux attach -t $tmux_session;
    fi;
  fi;
}

function prjfzf {
  OPTIND=1
  root="$HOME/Projects/"
  while getopts :n:r:h opt; do
    case $opt in 
      n)

        new_folder=${OPTARG}
        mkdir -p "$root"/"$new_folder"
        cd "$root"/"$new_folder"
        return 0
        ;;

      r)
        0=${OPTARG}
        # cd $root
        return 0
        ;;

      h)
        o=$OPTARG
        help="DESCRIPTION\nprj - A tool to manage all your projects\n\nOPTIONS\n\t-h    Display help\n
  -n    Create new folder and enter it\n
  -r    cd into the root folder for your porjects\n
        "
        printf $help
        return 0
        ;;

    esac
  done
  echo ENDING!!!
  target=$(find ~/Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf)
  cd $target
  nvim .
}

