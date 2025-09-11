#!/bin/bash

# Function to configur RUSTYVIBES
function rv {
  FOLDER=$HOME/rustyvibes_soundpacks/
  if [[ -z $1 ]]; then
    kill $(ps aux | grep '[r]ustyvibes' | awk '{print $2}') &>/dev/null
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
    -l|--list)
      printf "++ Here are all available soundpacks ++\n\n"
      ls -1 $FOLDER
      ;;
    -s|--soundpack)
      if [[ -z $2 ]]; then echo "You didn't specify the soundpack."; exit 1; fi;
      SP=$(find $FOLDER | grep $2 -m 1)
      (rustyvibes $SP &)
      ;;
    *)
      echo "Invalid option $1. Use -h or --help for an overview of the commands." >&2
      return 1
      ;;
    esac
  fi
}
