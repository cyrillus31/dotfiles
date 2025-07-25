#!/bin/bash

for file in $(ls -1 "$(pwd)"); do
	if [[ -d $file ]]; then
		echo "running: stow -R $file"
		stow -R "$file"
	fi
done
