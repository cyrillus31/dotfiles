# Starship Configuration

This directory contains Starship prompt configuration and theme management.

## Directory Structure

```
starship/
├── .config/
│   ├── starship.toml              # Active theme (local-only, not committed)
│   ├── starship-themes/           # Theme definitions
│   │   ├── pure.toml              # Pure theme (simple and clean)
│   │   ├── custom-pure.toml       # Custom Pure variant (with fancy borders)
│   │   ├── gruvbox-rainbow.toml   # Gruvbox Rainbow theme (colorful)
│   │   └── debian.toml            # Debian-themed variant
│   ├── starship-switcher.sh       # Theme switcher script
│   └── symbols.md                 # Symbol reference documentation
├── README.md                       # This file
└── .stow-local-ignore             # Stow configuration
```

## Available Themes

### pure
Simple and clean theme based on the Pure shell prompt. Minimal visual noise, great for focused work.

### custom-pure
Enhanced Pure theme with fancy Unicode box-drawing characters and borders. Includes Arcadia integration for monorepo support.

### gruvbox-rainbow
Colorful theme using Gruvbox palette with rainbow-like color blocks for different sections. Great for visual distinction between prompt elements.

### debian
Debian-inspired theme with red accent color and comprehensive symbol support for various OS platforms.

## Using the Theme Switcher

### Interactive Selection

Run the theme switcher to browse and select themes:

```bash
~/.config/starship-switcher.sh
```

This will:
1. Display an interactive fzf menu with all available themes
2. Show a preview of the first 20 lines of each theme configuration
3. Switch to your selected theme immediately
4. Update `starship.toml` with the selected theme

### Requirements

- `fzf` - Fuzzy finder (required for the switcher)
- `bash` - Shell environment

If fzf is not installed, you can install it via:
```bash
brew install fzf  # macOS
# or your package manager of choice
```

## Creating New Themes

To create a new theme:

1. Copy an existing theme file as a template:
   ```bash
   cp ~/.config/starship-themes/pure.toml ~/.config/starship-themes/my-theme.toml
   ```

2. Edit the new file with your desired configuration:
   ```bash
   vim ~/.config/starship-themes/my-theme.toml
   ```

3. Test it by running the switcher and selecting your new theme

4. Commit it to your dotfiles (the switcher will handle the active state)

## How It Works

- **Theme files** in `starship-themes/` are committed to git (shared across machines)
- **Active theme file** (`starship.toml`) is updated by the switcher and **NOT committed** (local preference)
- Each time you run the switcher, it copies your selected theme to `starship.toml`
- Starship automatically loads the active config on the next prompt
- Fresh machines will use whatever theme was last set (local to that machine)

## Notes

- `starship.toml` is listed in `.gitignore` and `.stow-local-ignore` to keep it local-only
- Theme previews in fzf show the first 20 lines of the configuration
- All themes support common modules: directory, git, time, OS symbols, and more
