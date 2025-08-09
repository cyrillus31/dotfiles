#!/bin/bash

(mv "$HOME/.zshrc" "$HOME/.zshrc.bak" && echo ".zshrc.bak created") 2>/dev/null  || true
(mv "$HOME/.zshrc.d" "$HOME/.zshrc.d.bak" && echo ".zhsrc.d.bak created") 2>/dev/null || true
(mv "$HOME/.zprofile" "$HOME/.zprofile.bak" && echo ".zprofile.bak created") 2>/dev/null  || true

(mv "$HOME/.bashrc" "$HOME/.bashrc.bak" && echo ".bashrc.bak created") 2>/dev/null  || true
(mv "$HOME/.bashrc.d" "$HOME/.bashrc.d.bak" && echo ".bashrc.d.bak created") 2>/dev/null  || true
(mv "$HOME/.profile" "$HOME/.profile.bak" && echo ".profile.bak created") 2>/dev/null || true
