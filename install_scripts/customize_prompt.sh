#!/bin/bash

sudo apt install curl -y
sudo curl -sS https://starship.rs/install.sh | sh
starship preset no-nerd-font -o ~/.config/starship.toml
