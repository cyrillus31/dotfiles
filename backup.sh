#!/bin/bash

# The default still moves configs out of the way before installation.
# --copy adds a non-disruptive snapshot option.
set -u
mode=${1:-move}
case "$mode" in
  move|--copy) ;;
  *) echo "Usage: $0 [--copy]" >&2; exit 2 ;;
esac
backup_dir=$(mktemp -d "$HOME/.dotfiles-backup.XXXXXXXX") || exit 1
result=0
create_backup() {
  local source=$1 destination="$backup_dir/${1#"$HOME/"}"
  if [[ -e "$source" || -L "$source" ]]; then
    mkdir -p "$(dirname "$destination")" || return 1
    if [[ "$mode" == --copy ]]; then
      cp -RP "$source" "$destination" || return 1
    else
      mv "$source" "$destination" || return 1
    fi
    echo "Backup created: $destination"
  else
    echo "File '$source' doesn't exist"
  fi
}
for relative in .zshrc .zshrc.d .zprofile .bashrc .bashrc.d .profile .config/starship.toml .tmux.conf .vimrc .sqliterc .shellrc.sh .shellrc.d; do
  create_backup "$HOME/$relative" || result=1
done
exit "$result"
