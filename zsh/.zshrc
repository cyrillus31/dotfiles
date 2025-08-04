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

# Run my common setup entrypoint
source "$HOME/.shellrc.sh"
