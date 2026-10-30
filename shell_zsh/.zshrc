# ~/.zshrc reload
alias src="source ~/.zshrc; echo ~/.zshrc file was reloaded"

# Autocomplete in zsh
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Starship
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# zsh-autosuggestions
[[ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# WARN: Run my common setup entrypoint
source "$HOME/.shellrc.sh"
