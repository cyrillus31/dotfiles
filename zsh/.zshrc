# Homebrew
export PATH="/opt/homebrew/opt/unzip/bin:$PATH"

# ~/.zshrc reload
alias src="source ~/.zshrc; echo ~/.zshrc file was reloaded"

# Autocomplete
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Starship
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)


ZSHRC_DIR="$HOME/.zshrc.d"
if [[ -d $ZSHRC_DIR ]] then
	for file in $ZSHRC_DIR/*; do
		source $file
	done
fi
