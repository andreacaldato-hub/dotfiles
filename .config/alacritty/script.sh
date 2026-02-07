#!/usr/bin/env bash

CONFIG="$HOME/.config/alacritty/alacritty.toml"
THEME="$1"

if [[ -z "$THEME" ]]; then
    echo "Usage: set-alacritty-theme <theme-name>"
    echo "Example: set-alacritty-theme sonokai"
    exit 1
fi

THEME_PATH="~/.config/alacritty/themes/themes/$THEME.toml"

# Backup
cp "$CONFIG" "$CONFIG.bak"

# Replace import line
sed -i "s|~/.config/alacritty/themes/themes/.*\.toml|$THEME_PATH|" "$CONFIG"

echo "Theme set to: $THEME"
