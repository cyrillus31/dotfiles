#!/bin/bash

# Helper function to modify the PATH
function append_path() {
  case ":$PATH:" in
    *:"$1":*) :;; # already in PATH, do nothing
    *) export PATH="${PATH:+"$PATH:"}$1";;
  esac
}

# Setup personal bin
LOCAL_BIN="$HOME/bin"
mkdir "$LOCAL_BIN" &>/dev/null
append_path "$LOCAL_BIN"

# Setup golang path
append_path "/usr/local/go/bin"


# Common setup
SHRC_DIR="$HOME/.shellrc.d"
if [[ -d $SHRC_DIR ]]; then
	# '-L' for recursive search of symlinced directories
	# '-type f' and '-type l' for searching fils respectively
	# '-o' works as logical OR 
	for file in $(find -L "$SHRC_DIR" -name "*.sh" -type f -o -type l); do
		source "$file"
	done
fi
