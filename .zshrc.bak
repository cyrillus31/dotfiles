# starship command prompts setup
eval "$(starship init zsh)"

dockerfix ()
{
  docker_config_path="$HOME/.docker/config.json"
  if [[ -f $docker_config_path ]]; then
    rm $docker_config_path;
    echo $docker_config_path file was successfully removed
  else
    echo $docker_config_path file doesn\'t exist
  fi;
  
}


export LC_ALL=en_US.UTF-8

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#
# The follwing is copied from my original .zshrc
alias prj="cd /Users/kirill/Desktop/Projects"
alias python3.9='/usr/bin/python3'
alias remote='ssh cyrillus@213.159.208.102'

# this makes so that 'python' command calls python3.11 even inside 3.9 environment 
alias python=/opt/homebrew/bin/python3.11

alias nvimk='NVIM_APPNAME="nvim-kickstart" nvim'

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"


# Autoomplete
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
