# Define the targets that correspond to directories
STOW_DIRS := aerospace iterm2 kitty shell shell_bash_fedora shell_yandex starship tmux vim zsh private_files

# Define groups of configurations
COMMON_TARGETS := shell starship tmux vim kitty
FEDORA_TARGETS := common shell_bash_fedora
MACBOOK_TARGETS := common zsh aerospace
YANDEX_MACBOOK_TARGETS := macbook shell_yandex

# Default target when running just 'make'
.PHONY: default
default:
	@echo "Please specify a target: fedora, macbook, yandex_macbook, or a specific config"
	@echo "Available configs: $(STOW_DIRS)"

# Define phony targets to avoid conflicts with directory names
.PHONY: $(STOW_DIRS) common fedora macbook yandex_macbook backup all

# Rule for all stow directories - automatically generated
$(STOW_DIRS):
	stow -R $@

# Rule for unstowing all directories
unstow:
	stow -D $(STOW_DIRS)

# Special case for backup which uses a script
backup:
	./backup.sh

# Meta targets
common: $(COMMON_TARGETS)

fedora: $(FEDORA_TARGETS)

macbook: $(MACBOOK_TARGETS)

yandex_macbook: $(YANDEX_MACBOOK_TARGETS)

# Install everything
all: $(STOW_DIRS)

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  fedora          - Setup for Fedora ($(FEDORA_TARGETS))"
	@echo "  macbook         - Setup for MacBook ($(MACBOOK_TARGETS))"
	@echo "  yandex_macbook  - Setup for Yandex MacBook ($(YANDEX_MACBOOK_TARGETS))"
	@echo "  common          - Common configurations ($(COMMON_TARGETS))"
	@echo "  all             - Install everything"
	@echo "  backup          - Run backup script"
	@echo "Individual configs: $(STOW_DIRS)"
