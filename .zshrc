# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh" # Set name of the theme to load --- if set to "random", it will load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="jbergantine"
# =============================
# ZINIT
# =============================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"
# =============================
# ZINIT PLUGINS
# =============================
zinit light zsh-users/zsh-completions
autoload -Uz compinit
compinit
# Plugins that require completion
zinit light Aloxaf/fzf-tab
# Other plugins
zinit light zsh-users/zsh-autosuggestions
# Snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit cdreplay -q
zinit ice wait"0" lucid
zinit light zsh-users/zsh-syntax-highlighting
# =============================
# KEYBINDINGS
# =============================
bindkey -M viins '^F' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
# =============================
# HISTORY
# =============================
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
# COMPLETION STYLING
# =============================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
# =============================
# FZF-TAB PREVIEWS (FILES + DIRS)
# =============================
zstyle ':fzf-tab:*' fzf-preview '
if [ -d "$realpath" ]; then
  eza --tree --level=2 --icons --color=always "$realpath"
elif [ -f "$realpath" ]; then
  bat --style=numbers --color=always "$realpath"
fi
'

# Make fzf-tab preview window taller
zstyle ':fzf-tab:*' fzf-flags --preview-window=right:60%:nowrap

# =============================
# FZF DEFAULT PREVIEW
# =============================
export FZF_DEFAULT_OPTS='
--preview "
if [ -d {} ]; then
  eza --tree --level=3 --icons --color=always {}
else
  stat {}
  echo ----------------
  bat --style=numbers --color=always --line-range :2000 {}
fi
"
--preview-window=up:70%:wrap
--bind ctrl-u:preview-page-up,ctrl-d:preview-page-down
'

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
# FZF + TMUX helpers
fzf-tmux-session() {
  local dir
  dir=$(find ~ -type d \
          ! -path "$HOME/.cache*" \
          ! -path "$HOME/.gnupg*" \
          ! -path "$HOME/.gradle*" \
          ! -path "$HOME/.local*" \
          ! -path "$HOME/.npm*" \
          ! -path "$HOME/*.git*" \
          ! -path "$HOME/.pki*" \
          ! -path "$HOME/.ssh*" \
          ! -path "$HOME/.texlive*" \
          ! -path "$HOME/go*" \
          ! -path "$HOME/yay*" \
          ! -path "$HOME/.rustup/*" \
          ! -path "$HOME/.config/*" \
          2>/dev/null | fzf) || return

  [[ -z "$dir" ]] && return

  local session_name
  session_name=$(basename "$dir")

  if tmux has-session -t "$session_name" 2>/dev/null; then
    [[ -n "$TMUX" ]] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
  else
    [[ -n "$TMUX" ]] && tmux new-session -d -s "$session_name" -c "$dir"; tmux switch-client -t "$session_name" || tmux new-session -s "$session_name" -c "$dir"
  fi
}
zle -N fzf-tmux-session

fzf-tmux-switch() {
  local session=$(
    tmux list-sessions -F "#{session_name}" 2>/dev/null |
    fzf --no-preview
    ) || return

  [[ -n "$session" ]] && (
    [[ -n "$TMUX" ]] && tmux switch-client -t "$session" ||
    tmux attach -t "$session"
  )
}

fzf-tmux-gitrepo() {
  local dir=$(
    find ~ -type d -name ".git" -prune 2>/dev/null |
    while read -r gitdir; do
      repo="${gitdir%/.git}"
      url=$(git -C "$repo" remote get-url origin 2>/dev/null)

      if [[ "$url" == *"github.com:andreacaldato-hub/"* ]] || \
         [[ "$url" == *"github.com/andreacaldato-hub/"* ]]; then
        echo "$repo"
      fi
    done | fzf
  ) || return

  # exit if nothing selected
  [[ -z "$dir" ]] && return

  # session name from folder
  local session_name
  session_name=$(basename "$dir")

  # === Attach or create session exactly like fzf-tmux-session ===
  if tmux has-session -t "$session_name" 2>/dev/null; then
    [[ -n "$TMUX" ]] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
  else
    [[ -n "$TMUX" ]] && tmux new-session -d -s "$session_name" -c "$dir"; tmux switch-client -t "$session_name" || tmux new-session -s "$session_name" -c "$dir"
  fi
}
zle -N fzf-tmux-gitrepo


bindkey -s '^[G' 'fzf-tmux-gitrepo\n'
bindkey -s '^[T' 'fzf-tmux-session\n'
bindkey -s '^[F' 'fzf-tmux-switch\n'

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ll="eza -l --icons --group-directories-first"
alias la="eza -la --icons --group-directories-first"
alias cd="z"

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
