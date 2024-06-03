#!/bin/bash

# This script changes between different Starship prompt configs

to_config_file=$(find -name 'starship*' | fzf)

function _get_config_name () {
  echo $(head -n 1 $1 | sed -E 's/[# ]*//')
}

config_from=$(_get_config_name ./starship.toml)
config_to=$(_get_config_name $to_config_file)

mv ./starship.toml ./starship_${config_from}.toml
mv $to_config_file ./starship.toml

echo \#\#\# Starship config was changed from $config_from to $config_to \#\#\#
