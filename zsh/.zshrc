# Add user's bin/
export PATH="$HOME/bin:$PATH"

# ~/.zshrc reload
alias src="source ~/.zshrc; echo ~/.zshrc file was reloaded"

# Autocomplete in zsh
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Starship
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Setup personal bin
LOCAL_BIN="$HOME/bin"
mkdir $LOCAL_BIN &>/dev/null
export PATH="$LOCAL_BIN:$PATH"

ZSHRC_DIR="$HOME/.zshrc.d"
if [[ -d $ZSHRC_DIR ]] then
	for file in $ZSHRC_DIR/*; do
		source $file
	done
fi


# Mount ARCADIA monorepository
ARC_DIR="$HOME/arcadia"
if [[ ! "$(ls -A "$ARC_DIR")" ]]; then
	echo "Mounting arcadia..."
	arc mount "$ARC_DIR"
	echo "Arcadia mounted"
fi

# Setup ya 
if ! which ya &>/dev/null ; then
	echo "Linking ya..."
	# Recommended option 1
	rm -f "$LOCAL_BIN/ya" &>/dev/null || true
	ln -s "$ARC_DIR/ya"  "$LOCAL_BIN/ya"

	# Recommended option 2
	# alias ya="$ARC_DIR/arcadia/ya"

	# save token localy to avoid issues with tmux (as per documentation)
	ya whoami --save-token  &>/dev/null
	echo "ya linked!"
fi
