#fastfetch
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
    fzf --preview '
      tmux capture-pane -ep -t {} 2>/dev/null |
      tail -300 |
      bat --style=plain --color=always --paging=never
    '
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
#Alias
alias grep='grep --color=auto'
alias cd='z'
alias lg='lazygit'
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias fastfetch='fastfetch --config os.jsonc'
# =============================
# SYNTAX HIGHLIGHTING COLORS
# =============================
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#88DF51'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#88DF51'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#88DF51'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#E75672'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#CBAD50'
ZSH_HIGHLIGHT_STYLES[path]='fg=#FFAF5F,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#FFAF5F'
# =============================
# FZF INTEGRATION
# =============================
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/go/bin
