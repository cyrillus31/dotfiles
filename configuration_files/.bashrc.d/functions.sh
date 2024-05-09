#!/bin/bash

function src {
  source $HOME/.bashrc
  echo \~/.bashrc was reloaded
  return 0
}


function activatev {
  env_location='./venv/bin/activate'
  if [[ -d ./venv ]]; then
    true
  elif [[ -d ../venv ]]; then
    env_location="../venv/bin/activate"
  else
    echo "'venv/' was not found in the current or parent directory";
    echo "Creating one in the current directory...";
    python -m venv venv;
  fi;
  source $env_location
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
    activatev;
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


function _wacomsetup {
  stylus_id=$(xinput | grep stylus | sed -E 's/.+id=([0-9]+).*/\1/')
  output_device=$(xrandr | grep -E '\bconnected' | fzf --header='Pick output device' | awk '{print $1}')
  xinput map-to-output $stylus_id $output_device
}
