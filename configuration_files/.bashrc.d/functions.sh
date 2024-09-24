# DOCKER

function _remove_all_containers {
  docker rm $(docker ps -a -q)
}

function _stop_all_containers {
  docker stop $(docker ps -a -q)
  _remove_all_containers
}

function _docker_ls {
  # this function is supposed to run ls command with fzf over:
  # container, image, volume, network
  echo placeholder
}

function _enter_docker {

	# if [[ -z $1 ]]; then 
	# 	echo "Pass a name of the container as an argument"
	# 	return 1
	# fi;

	container_name=$(\
			docker ps |\
			awk 'NR > 1 { print $2 }' |\
			fzf --preview 'docker ps | grep {}'\
			)

	container_id=$(docker ps | grep $container_name | awk '{ print $1 }')

	docker exec -it $container_id sh

}

function src {
  source $HOME/.bashrc
  echo \~/.bashrc was reloaded
  return 0
}


function activatev {
  env_location='./venv/bin/activate'
  if [[ -d ./venv ]]; then
    true
  # elif [[ -d ../venv ]]; then
  #   env_location="../venv/bin/activate"
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
    target=$(find ~/Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf --height=80% --reverse --border --ansi --preview='ls -a -1 {}' --preview-window=right:30%)
  else
    target=$(find ~/Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf -q $1 --height=80% --reverse --border --ansi --preview='ls -a -1 {}' --preview-window=right:30%)
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


function notes () {
  folder="$HOME/Documents/Obsidian Vault/Notes/"
  file=$(find $folder -type f -name '*.txt' -o -name '*.md' | fzf) 
  if [[ $? -eq 0 ]]; then
    nvim $file
  fi;
}


# This commnad caches the last output of neofetch
# and returns it next time instantaneously 
function neofetch_hello () {
  cache=$HOME/.cache/neofetch.cache
  neofetch_binary=$(find /usr/bin/ -name '*neofetch*')

  if [[ -f $cache ]]; then
    cat $cache
    ($neofetch_binary > $cache && \
    echo "                        *cached at $(date)" >> $cache &)
    echo '                        *cache_updated'

  else
    $neofetch_bin | tee $cache
  fi
}

function wacomsetup_function {
  stylus_id=$(xinput | grep stylus | sed -E 's/.+id=([0-9]+).*/\1/')
  output_device=$(xrandr | grep -E '\bconnected' | fzf --header='Pick output device' | awk '{print $1}')
  xinput map-to-output $stylus_id $output_device
}

# Function for configuring RUSTYVIBES
function rv {
  if [[ -z $1 ]]; then
    kill $(ps aux | grep '[r]ustyvibes' | awk '{print $2}') &>/dev/null
    FOLDER=$HOME/Documents/Keyboard_Soundpacks
    echo $FOLDER
    SOUNDPACK=$(ls $FOLDER | fzf --reverse --prompt 'Pick a soundpack> ' --header 'RUSTYVIBES Soundpacks: ')
    if [[ -z $SOUNDPACK ]]; then
      echo "You need to pick a soundpack" >&2
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
RUSTYVIBES WRAPPER 
(by cyrillus31)

Usage: rv [OPTIONS]

Options:
  -k, --kill      Kill the process
  -h, --help      Show this help message and exit

Examples:
  rv --kill
  rv -h

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
