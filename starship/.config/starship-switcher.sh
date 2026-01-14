#!/bin/bash

# Starship Theme Switcher
# Interactive fzf-based theme switcher for Starship prompt

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="${SCRIPT_DIR}/starship-themes"
ACTIVE_THEME="${SCRIPT_DIR}/starship.toml"

# Check if themes directory exists
if [[ ! -d "$THEMES_DIR" ]]; then
    echo "Error: starship-themes directory not found at $THEMES_DIR"
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed. Please install fzf to use this switcher."
    exit 1
fi

# Get list of available themes
get_themes() {
    ls -1 "$THEMES_DIR"/*.toml 2>/dev/null | xargs -n1 basename | sed 's/\.toml$//' | sort
}

# Get current theme
get_current_theme() {
    if [[ -L "$ACTIVE_THEME" ]]; then
        basename "$(readlink "$ACTIVE_THEME")" | sed 's/\.toml$//'
    elif [[ -f "$ACTIVE_THEME" ]]; then
        echo "unknown"
    else
        echo "none"
    fi
}

# Display theme selection menu with fzf
select_theme() {
    local current=$(get_current_theme)
    local selected
    
    selected=$(get_themes | fzf \
        --preview "cat ${THEMES_DIR}/{}.toml | head -20" \
        --preview-window=right:50% \
        --header "Current theme: $current" \
        --height=50% \
        --reverse)
    
    if [[ -z "$selected" ]]; then
        echo "No theme selected."
        exit 0
    fi
    
    echo "$selected"
}

# Apply selected theme
apply_theme() {
    local theme=$1
    local theme_file="${THEMES_DIR}/${theme}.toml"
    
    if [[ ! -f "$theme_file" ]]; then
        echo "Error: Theme file not found: $theme_file"
        exit 1
    fi
    
    # Remove old symlink/file if it exists
    if [[ -e "$ACTIVE_THEME" ]] || [[ -L "$ACTIVE_THEME" ]]; then
        rm "$ACTIVE_THEME"
    fi
    
    # Create symlink to selected theme
    ln -s "${THEMES_DIR}/${theme}.toml" "$ACTIVE_THEME"
    
    echo "✓ Switched to theme: $theme"
    echo ""
    echo "Starting a new shell to apply the theme..."
    echo ""
    
    # Start a new shell to avoid prompt conflicts
    exec $SHELL
}

# Main execution
main() {
    local selected_theme
    selected_theme=$(select_theme)
    apply_theme "$selected_theme"
}

main
