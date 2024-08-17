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

# Function for configuring RUSTYVIBES
function rv {
  if [[ -z $1 ]]; then
    kill $(ps aux | grep '[r]ustyvibes' | awk '{print $2}') &>/dev/null
    FOLDER=$HOME/Documents/Keyboard_Soundpacks
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


dockerfix ()
{
  docker_config_path="$HOME/.docker/config.json"
  if [[ -f $docker_config_path ]]; then
    rm $docker_config_path;
    echo $docker_config_path file was successfully removed
  else
    echo $docker_config_path file doesn\'t exist
  fi;
  
}


function _nvim_update() {
  NVIM_FOLDER='nvim'
  SRC_BRANCH='custom-astra'
  (
    cd $HOME/.config/$NVIM_FOLDER
    git fetch; git rebase origin/${SRC_BRANCH} >/dev/null
  )
  echo "Nvim was updated from branch: '$SRC_BRANCH'"
}

function _run_and_update_nvim() {
  nvim_binary="/opt/homebrew/bin/nvim"
  if [[ ! -z $1 ]]; then
    case $1 in
      -h|--help)
        $nvim_binary $1
        echo '\nFrom alias:'
        echo "  -u, --update          Update local Nvim setup"
        return 0
        ;;
      -u|--update)
        _nvim_update
        return 0
        ;;
      *)
        echo Wrong argument: \"$1\"
        return 1
        ;;
    esac
  else
    $nvim_binary
  fi
}
