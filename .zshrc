fastfetch --config os.jsonc
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


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
zinit light zsh-users/zsh-syntax-highlighting
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
# =============================
# KEYBINDINGS
# =============================
bindkey -M viins '^F' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
# FZF + TMUX helpers
fzf-tmux-session() {
  local dir=$(find ~ -type d -maxdepth 3 2>/dev/null | fzf) || return
  local session_name=$(basename "$dir")
  if tmux has-session -t "$session_name" 2>/dev/null; then
    [[ -n "$TMUX" ]] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
  else
    [[ -n "$TMUX" ]] && tmux new-session -d -s "$session_name" -c "$dir"; tmux switch-client -t "$session_name" || tmux new-session -s "$session_name" -c "$dir"
  fi
}
zle -N fzf-tmux-session

fzf-tmux-switch() {
  local session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf) || return
  [[ -n "$session" ]] && ([[ -n "$TMUX" ]] && tmux switch-client -t "$session" || tmux attach -t "$session")
}
zle -N fzf-tmux-switch

fzf-tmux-gitrepo() {
  local dir=$(find ~ -type d -name ".git" -prune ! -path "$HOME/.local/*" ! -path "$HOME/.cache/*" 2>/dev/null | sed 's|/\.git||' | fzf) || return
  local session_name=$(basename "$dir")
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
# =============================
# COMPLETION STYLING
# =============================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
#Alias
alias grep='grep --color=auto'
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias fastfetch='fastfetch --config os.jsonc'
# =============================
# SYNTAX HIGHLIGHTING COLORS
# =============================
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#76946A'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#76946A'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#76946A'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#B63E42'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#C0A36E'
ZSH_HIGHLIGHT_STYLES[path]='fg=#687FAE'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#C0A36E'

# =============================
# FZF INTEGRATION
# =============================
eval "$(fzf --zsh)"

# =============================
# NEOFETCH (moved to end to avoid instant prompt warning)
# =============================
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
