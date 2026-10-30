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
append_path "$HOME/go/bin"

# Setup cargo path
append_path "$HOME/.cargo/bin"

# Setup Homebrew (linuxbrew) when installed
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Common setup
SHRC_DIR="$HOME/.shellrc.d"
if [[ -d $SHRC_DIR ]]; then
    # Bash and Zsh both support NUL-delimited reads and process substitution.
    while IFS= read -r -d '' file; do
        source "$file"
    done < <(find -L "$SHRC_DIR" -type f -name '*.sh' -print0)
fi
