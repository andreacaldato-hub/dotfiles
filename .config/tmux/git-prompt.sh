#!/usr/bin/env zsh
pane_dir="#{pane_current_path}"

# Only if we're in a git repo
if git -C "$pane_dir" rev-parse --git-dir >/dev/null 2>&1; then
  repo=$(basename "$(git -C "$pane_dir" rev-parse --show-toplevel)")
  # Gitmux handles branch + flags
  flags=$(~/go/bin/gitmux -C "$pane_dir" -cfg ~/.config/tmux/gitmux.yml)
  echo "$repo: $flags"
fi
