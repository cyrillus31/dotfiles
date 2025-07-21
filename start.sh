#!/bin/bash

mv $HOME/.zshrc $HOME/.zshrc.bak && echo ".zshrc.bak created" || true
mv $HOME/.zshrc.d $HOME/.zshrc.d.bak && echo ".zhsrc.d.bak created" || true

brew install stow
