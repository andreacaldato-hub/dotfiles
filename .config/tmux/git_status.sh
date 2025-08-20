#!/usr/bin/env bash

# Get the current pane's PID
pane_pid=$(tmux display-message -p "#{pane_pid}")

# Try to find a running Neovim attached to this pane
nvim_socket=$(lsof -p "$pane_pid" | awk '/nvim$/ {print $9; exit}')

# Determine the path to check
if [ -n "$nvim_socket" ] && [ -S "$nvim_socket" ]; then
  # Ask Neovim for the current file
  FILE=$(nvim --headless --listen "$nvim_socket" +'echo expand("%:p")' +qa 2>/dev/null)
else
  # Fallback to the pane's current path
  FILE=$(tmux display-message -p -F "#{pane_current_path}")
fi

# Get Git repo info for the file or folder
repo=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$repo" ]; then
  branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD)
  echo "$(basename "$repo") | $branch"
else
  echo "no repo"
fi
