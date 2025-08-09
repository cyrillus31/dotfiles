.PHONY: fedora
fedora: common shell_bash_fedora

.PHONY: macbook
macbook: common zsh aerospace

.PHONY: yandex_macbook
yandex_macbook: macbook shell_yandex

.PHONY: shell starship tmux vim kitty
common: shell starship tmux vim kitty

.PHONY: backup aerospace iterm2 kitty shell_bash_fedora shell_yandex zsh 
backup:
	./backup.sh

aerospace:
	stow -R aerospace

iterm2:
	stow -R iterm2

kitty:
	stow -R kitty

shell:
	stow -R shell

shell_bash_fedora:
	stow -R shell_bash_fedora

shell_yandex:
	stow -R shell_yandex

starship:
	stow -R starship

tmux:
	stow -R tmux

vim:
	stow -R vim

zsh:
	stow -R zsh

