#!/bin/bash

# Function to control RUSTYVIBES
function rv {
  local FOLDER="$HOME/rustyvibes_soundpacks/"
  local VOLUME=""
  local SOUNDPACK=""

  # Kill running rustyvibes process
  _rv_kill() {
    local process_id
    # process_id=$(ps aux | grep '[r]ustyvibes' | awk '{print $2}')
    process_id=$(pgrep -f rustyvibes)
    if [[ -n "$process_id" ]]; then
      kill "$process_id" 2>/dev/null
      return 0
    fi
    return 1
  }

  # Launch rustyvibes
  _rv_start() {
    local sp="$1"
    local vol="$2"
    _rv_kill
    if [[ -n "$vol" ]]; then
      (rustyvibes -v "$vol" "$sp" &)
      echo "Rustyvibes is running! (volume: $vol)"
    else
      (rustyvibes "$sp" &)
      echo "Rustyvibes is running!"
    fi
  }

  # No arguments - interactive soundpack selection
  if [[ -z "$1" ]]; then
    SOUNDPACK=$(find "$FOLDER" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | \
      fzf --reverse --prompt 'Pick a soundpack> ' --header 'RUSTYVIBES Soundpacks')
    if [[ -z "$SOUNDPACK" ]]; then
      echo "You need to pick a soundpack" >&2
      return 1
    fi
    _rv_start "$FOLDER/$SOUNDPACK"
    return 0
  fi

  # Parse all arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -k|--kill)
        if _rv_kill; then
          echo "RUSTYVIBES process was terminated."
        else
          echo "Rustyvibes is not running"
        fi
        return 0
        ;;
      -h|--help)
        cat << EOF
RUSTYVIBES WRAPPER 
(by cyrillus31)

Usage: rv [OPTIONS]

Options:
  -k, --kill            Kill the process
  -h, --help            Show this help message and exit
  -l, --list            List available soundpacks
  -v, --volume <0-100>  Set volume (requires -s)
  -s, --soundpack <name> Select soundpack by name

Examples:
  rv                    Interactive soundpack selection
  rv -s cherrymx-blue   Start with specified soundpack
  rv -s nk-cream -v 80  Start with soundpack and volume
  rv --kill             Stop rustyvibes
EOF
        return 0
        ;;
      -l|--list)
        printf "++ Available soundpacks ++\n\n"
        ls -1 "$FOLDER"
        return 0
        ;;
      -v|--volume)
        if [[ -z "$2" || "$2" == -* ]]; then
          echo "You didn't specify the volume." >&2
          return 1
        fi
        VOLUME="$2"
        shift 2
        ;;
      -s|--soundpack)
        if [[ -z "$2" || "$2" == -* ]]; then
          echo "You didn't specify the soundpack." >&2
          return 1
        fi
        local SP
        SP=$(find "$FOLDER" -mindepth 1 -maxdepth 1 -type d -name "*$2*" | head -1)
        if [[ -z "$SP" ]]; then
          echo "Soundpack '$2' not found." >&2
          return 1
        fi
        SOUNDPACK="$SP"
        shift 2
        ;;
      *)
        echo "Invalid option '$1'. Use -h or --help for help." >&2
        return 1
        ;;
    esac
  done

  # Volume without soundpack is an error
  if [[ -n "$VOLUME" && -z "$SOUNDPACK" ]]; then
    echo "Volume requires a soundpack. Use -s to specify one." >&2
    return 1
  fi

  # Soundpack specified - start it
  if [[ -n "$SOUNDPACK" ]]; then
    _rv_start "$SOUNDPACK" "$VOLUME"
  fi
}
