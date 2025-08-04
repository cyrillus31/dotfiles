#!/bin/bash

# Setup personal bin
LOCAL_BIN="$HOME/bin"
mkdir "$LOCAL_BIN" &>/dev/null
export PATH="$LOCAL_BIN:$PATH"

# Common setup
ZSHRC_DIR="$HOME/.shellrc.d"
if [[ -d $ZSHRC_DIR ]]; then
	# '-L' for recursive search of symlinced directories
	# '-type f' and '-type l' for searching fils respectively
	# '-o' works as logical OR 
	for file in $(find -L "$ZSHRC_DIR" -name "*.sh" -type f -o -type l); do
		source "$file"
	done
fi
