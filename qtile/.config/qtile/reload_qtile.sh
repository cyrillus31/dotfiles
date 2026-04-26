#!/bin/bash

# Reload qtile config without restarting

APP=${APP:-$(python -c "from libqtile.utils import guess_terminal; print(guess_terminal())")}

if [ -z "$APP" ]; then
    APP="kitty"
fi

echo "Reloading Qtile config..."
$APP --hold -e "qtile cmd-obj -o cmd -f reload_config" 2>/dev/null || echo "Failed to reload config"