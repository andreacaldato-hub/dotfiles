# ~/.bashrc - Simple and practical

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ----------------------
# Prompt
# ----------------------
PS1="\[\e[32m\]\u@\h\[\e[m\]:\[\e[34m\]\w\[\e[m\]\$ "

# ----------------------
# Aliases
# ----------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'

# ----------------------
# Useful environment variables
# ----------------------
export EDITOR=nano
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# ----------------------
# PATH additions (example)
# ----------------------
export PATH="$HOME/bin:$PATH"

# ----------------------
# Enable color for ls
# ----------------------
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# ----------------------
# Custom functions
# ----------------------
# Quickly go up directories
up() {
    cd "$(printf '%0.s../' $(seq 1 $1))" || return
}

# Search command history
hgrep() {
    history | grep "$1"
}

# ----------------------
# Load bash completion if available
# ----------------------
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
