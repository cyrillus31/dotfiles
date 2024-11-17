#!/bin/bash

read -p "Do you want 'stow' to Apply or Delete changes? (a/d): " response

STOW_DIR='../configuration_files'

case $response in
	a|A)
		stow -d $STOW_DIR -t $HOME *
		;;

	d|D)
		stow --delete -d $STOW_DIR -t $HOME *
		;;
	*)
		echo "Nothing was specified. Stow did nothing."
		;;
esac

