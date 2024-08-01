#!/bin/bash

function src {
  source $HOME/.bashrc
  echo \~/.bashrc was reloaded
  return 0
}

function _dactyl () {
  for device in /dev/hidraw*; do
    sudo chown $USER:$USER $device; 
    echo Dactyl chmod done!
  done;
}

function activatev {
  env_location='./venv/bin/activate'
  if [[ -d ./venv ]]; then
    true
  elif [[ -d ../venv ]]; then
    env_location="../venv/bin/activate"
  elif [[ ! -z $(find . -maxdepth 2 -name '*.py') ]]; then 
    echo "'venv/' was not found in the current or parent directory";
    echo "Creating one in the current directory...";
    python -m venv venv;
  else
    echo "This folder doesn't contain python files."
    return 1
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

function rv {
  if [[ -z $1 ]]; then
    kill $(ps aux | grep '[r]ustyvibes' | awk '{print $2}') &>/dev/null
    FOLDER=/home/cyrillus/Documents/Keyboard_Soundpacks
    SOUNDPACK=$(ls $FOLDER | fzf)
    if [[ -z $SOUNDPACK ]]; then
      echo "You have to pick a soundpack" >&2
      return 1
    fi
    (rustyvibes $FOLDER/$SOUNDPACK &)
    echo "Rustyvibes is running!"
  else
    case $1 in
    -k|--kill)
      process_id=$(ps aux | grep '[r]ustyvibes' | awk '{print $2}')
      if [[ -z $process_id ]]; then
        echo "Rustyvibes is not running"
        return 0
      fi
      kill $process_id 2>/dev/null
      echo "RUSTYVIBES process was terminated."
      return 0
      ;;
    -h|--help)
      cat << EOF
Usage: rv [OPTIONS]

Options:
  -k, --kill      Kill the process
  -h, --help      Show this help message and exit

Examples:
  rv -k     
  rv --help 

Run 'rv [OPTION]' to run RUSTYVIBES.
EOF
      ;;
    *)
      echo "Invalid option $1. Use -h or --help for an overview of the commands." >&2
      return 1
      ;;
    esac
  fi
}
