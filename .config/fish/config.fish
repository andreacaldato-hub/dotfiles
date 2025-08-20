if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ~/.config/fish/config.fish

# Better prompt (using fish built-in)
# Created by `pipx` on 2025-08-19 13:20:23
# PATH
set -gx PATH $HOME/.local/bin $PATH

# Shortcuts

# Git bare repo dotfiles config
alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

# Useful
alias update='sudo pacman -Syu'

# Enable vi keybindings
fish_vi_key_bindings
neofetch
