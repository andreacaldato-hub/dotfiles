#!/usr/bin/env bash
# Print "repo_name:branch" for the current pane directory

pane_dir="$(tmux display-message -p -F "#{pane_current_path}")"

if [ -d "$pane_dir/.git" ] || git -C "$pane_dir" rev-parse --git-dir >/dev/null 2>&1; then
  repo_name=$(basename "$(git -C "$pane_dir" rev-parse --show-toplevel)")
  echo "$repo_name"
fi
