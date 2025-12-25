# ~/.zshrc reload
alias src="source ~/.zshrc; echo ~/.zshrc file was reloaded"

# Autocomplete in zsh
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Starship
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# zsh-autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# WARN: Run my common setup entrypoint
source "$HOME/.shellrc.sh"
