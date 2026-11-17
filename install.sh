#!/usr/bin/env bash
#
# install.sh — Installer interattivo per CachyOS + niri + Noctalia
# Ripristina TUTTA la configurazione di Andrea da zero.
#
# Uso:
#   ./install.sh
#
# Lo script e' idempotente: puoi rilanciarlo piu' volte in sicurezza.

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Colori e helper
# ─────────────────────────────────────────────────────────────────────────────
c_reset=$'\e[0m'
c_bold=$'\e[1m'
c_dim=$'\e[2m'
c_red=$'\e[31m';   c_green=$'\e[32m';  c_yellow=$'\e[33m'
c_blue=$'\e[34m';  c_magenta=$'\e[35m'; c_cyan=$'\e[36m'

info()    { printf "${c_cyan}==>${c_reset} %s\n" "$*"; }
step()    { printf "\n${c_bold}${c_magenta}── %s ──────────────────────────────${c_reset}\n" "$*"; }
ok()      { printf "${c_green}  ✔${c_reset} %s\n" "$*"; }
warn()    { printf "${c_yellow}  ! %s${c_reset}\n" "$*"; }
err()     { printf "${c_red}  ✖ %s${c_reset}\n" "$*"; }
skip()    { printf "${c_dim}  – %s${c_reset}\n" "$*"; }

# Chiede conferma (default: y)
confirm() {
  local msg="${1:-Continuare?}"
  local def="${2:-y}"
  local ans
  printf "${c_yellow}${c_bold}?${c_reset} %s " "$msg"
  if [ "$def" = "y" ]; then printf "[Y/n] "; else printf "[y/N] "; fi
  read -r ans
  ans="${ans:-$def}"
  case "$ans" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# Chiede un valore con default
ask() {
  local prompt="$1" def="$2" ans
  printf "${c_yellow}${c_bold}?${c_reset} %s [${c_cyan}%s${c_reset}]: " "$prompt" "$def"
  read -r ans
  echo "${ans:-$def}"
}

need_sudo() {
  sudo -v
}

# ─────────────────────────────────────────────────────────────────────────────
# Configurazione di default
# ─────────────────────────────────────────────────────────────────────────────
USERNAME="andrea"
DOTFILES_REPO="git@github.com:andreacaldato-hub/dotfiles.git"
NVIM_REPO="git@github.com:andreacaldato-hub/Neovim.git"
AUR_HELPER="yay"
SDDM_THEME="orbital"          # variante clockwork attiva

# Pacchetti base (repo ufficiali / cachyos)
PACMAN_PKGS=(
  git stow zsh neovim tmux alacritty eza fzf zoxide bat neofetch
  brightnessctl wl-clipboard cliphist loupe niri noctalia sddm firefox
  wireplumber pipewire pipewire-pulse pipewire-alsa pipewire-jack grim slurp
  noto-fonts noto-fonts-cjk noto-fonts-emoji
  ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-fantasque-nerd ttf-meslo-nerd
  tectonic opencode spotify-launcher
  curl wget rsync unzip openssh xdg-utils
)

# Pacchetti AUR (opzionali)
AUR_PKGS=()

# ─────────────────────────────────────────────────────────────────────────────
# 0. Banner
# ─────────────────────────────────────────────────────────────────────────────
clear
printf "${c_bold}${c_magenta}"
cat <<'EOF'
 ██████╗ █████╗  ██████╗██╗  ██╗██╗   ██╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝██╔═══██╗██╔════╝
██║     ███████║██║     ███████║ ╚████╔╝ ██║   ██║███████╗
██║     ██╔══██║██║     ██╔══██║  ╚██╔╝  ██║   ██║╚════██║
╚██████╗██║  ██║╚██████╗██║  ██║   ██║   ╚██████╔╝███████║
 ╚═════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
EOF
printf "${c_reset}"
printf "${c_bold}Installer dotfiles — CachyOS + niri + Noctalia${c_reset}\n\n"
info "Questo script reinstalla l'intera configurazione da zero."

# ─────────────────────────────────────────────────────────────────────────────
# 1. Pre-flight
# ─────────────────────────────────────────────────────────────────────────────
step "Controlli preliminari"

if [ ! -f /etc/os-release ]; then
  err "Non riesco a leggere /etc/os-release. Sei su Arch/CachyOS?"
  exit 1
fi
. /etc/os-release
info "Sistema rilevato: ${PRETTY_NAME:-$NAME}"

command -v sudo >/dev/null 2>&1 || { err "sudo non trovato. Installalo prima."; exit 1; }
command -v pacman >/dev/null 2>&1 || { err "pacman non trovato."; exit 1; }
ok "pacman e sudo presenti"

# ─────────────────────────────────────────────────────────────────────────────
# 2. Domande interattive
# ─────────────────────────────────────────────────────────────────────────────
step "Configurazione installazione"

USERNAME="$(ask "Username (la config usa /home/andrea)" "andrea")"
HOME_DIR="/home/$USERNAME"

DOTFILES_REPO="$(ask "URL repo dotfiles" "$DOTFILES_REPO")"
NVIM_REPO="$(ask "URL repo Neovim" "$NVIM_REPO")"

# Wallpaper: repo git o cartella locale?
echo
printf "${c_bold}Come vuoi ripristinare i wallpaper?${c_reset}\n"
printf "  ${c_cyan}1${c_reset}) Repo git dedicato (clone)\n"
printf "  ${c_cyan}2${c_reset}) Cartella/tarball locale (copia)\n"
printf "  ${c_cyan}3${c_reset}) Salta (li copio a mano)\n"
read -r -p "Scelta [1/2/3]: " WALL_MODE
WALL_MODE="${WALL_MODE:-1}"

case "$WALL_MODE" in
  1)
    WALL_REPO="$(ask "URL repo wallpaper" "")"
    ;;
  2)
    WALL_SRC="$(ask "Percorso cartella o .tar/.tar.gz dei wallpaper" "")"
    ;;
  *)
    WALL_MODE="skip"
    ;;
esac

# Firefox: profilo da ripristinare?
echo
printf "${c_bold}Come vuoi ripristinare il profilo Firefox?${c_reset}\n"
printf "  ${c_cyan}1${c_reset}) Tarball .tar.gz\n"
printf "  ${c_cyan}2${c_reset}) Cartella locale\n"
printf "  ${c_cyan}3${c_reset}) Salta\n"
read -r -p "Scelta [1/2/3]: " FF_MODE
FF_MODE="${FF_MODE:-3}"

case "$FF_MODE" in
  1) FF_SRC="$(ask "Percorso del tarball del profilo Firefox" "")" ;;
  2) FF_SRC="$(ask "Percorso cartella del profilo (firefox/)" "")" ;;
  *) FF_MODE="skip" ;;
esac

if command -v yay >/dev/null 2>&1; then AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then AUR_HELPER="paru"; fi

echo
info "Riepilogo:"
info "  Utente        : ${c_bold}$USERNAME${c_reset}"
info "  Dotfiles repo : $DOTFILES_REPO"
info "  Neovim repo   : $NVIM_REPO"
case "$WALL_MODE" in
  1) info "  Wallpaper     : clone $WALL_REPO" ;;
  2) info "  Wallpaper     : copia da $WALL_SRC" ;;
  *) info "  Wallpaper     : ${c_dim}saltati${c_reset}" ;;
esac
case "$FF_MODE" in
  1) info "  Firefox       : tarball $FF_SRC" ;;
  2) info "  Firefox       : cartella $FF_SRC" ;;
  *) info "  Firefox       : ${c_dim}saltato${c_reset}" ;;
esac
info "  Tema SDDM     : clockwork/$SDDM_THEME"
echo

confirm "Procedere con l'installazione?" || { info "Annullato."; exit 0; }

# ─────────────────────────────────────────────────────────────────────────────
# 3. Pacchetti base
# ─────────────────────────────────────────────────────────────────────────────
step "Installazione pacchetti base (pacman)"
need_sudo
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
ok "Pacchetti base installati"

# ─────────────────────────────────────────────────────────────────────────────
# 4. AUR helper + pacchetti AUR
# ─────────────────────────────────────────────────────────────────────────────
if [ "${#AUR_PKGS[@]}" -gt 0 ]; then
  step "Installazione pacchetti AUR"
  if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
    info "Installo $AUR_HELPER..."
    cd /tmp
    git clone "https://aur.archlinux.org/${AUR_HELPER}.git"
    cd "$AUR_HELPER"
    makepkg -si --noconfirm
    cd ~
  fi
  "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}"
  ok "Pacchetti AUR installati"
else
  skip "Nessun pacchetto AUR richiesto"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 5. oh-my-zsh + zinit
# ─────────────────────────────────────────────────────────────────────────────
step "Shell: oh-my-zsh e zinit"

if [ -d "$HOME_DIR/.oh-my-zsh" ]; then
  skip "oh-my-zsh già presente"
else
  info "Installo oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "oh-my-zsh installato"
fi

ZINIT_HOME="$HOME_DIR/.local/share/zinit/zinit.git"
if [ -d "$ZINIT_HOME" ]; then
  skip "zinit già presente"
else
  info "Clono zinit..."
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  ok "zinit clonato"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 6. Git e SSH (necessario prima dei clone via SSH)
# ─────────────────────────────────────────────────────────────────────────────
step "Git e SSH"

GIT_NAME="$(ask "Git user.name" "andreacaldato-hub")"
GIT_EMAIL="$(ask "Git user.email" "andreacaldato6@gmail.com")"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
ok "git config impostato ($GIT_NAME <$GIT_EMAIL>)"

SSH_KEY="$HOME_DIR/.ssh/id_ed25519"
if [ -f "$SSH_KEY" ]; then
  ok "chiave SSH già presente (~/.ssh/id_ed25519)"
else
  if confirm "Generare una nuova chiave SSH ed25519?"; then
    mkdir -p "$HOME_DIR/.ssh"
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
    # evita il prompt "authenticity of host" durante i clone
    ssh-keyscan -t ed25519 github.com >> "$HOME_DIR/.ssh/known_hosts" 2>/dev/null || true
    ok "chiave SSH generata in ~/.ssh/id_ed25519"
  fi
fi

# Mostra la chiave pubblica da aggiungere a GitHub
if [ -f "$SSH_KEY.pub" ]; then
  echo
  info "La tua chiave pubblica (aggiungila su GitHub → Settings → SSH and GPG keys):"
  printf "${c_bold}"
  cat "$SSH_KEY.pub"
  printf "${c_reset}\n"
  if confirm "Aprire il browser su github.com/settings/ssh/new?"; then
    xdg-open "https://github.com/settings/ssh/new" >/dev/null 2>&1 || true
  fi
  echo
  if ! confirm "Hai aggiunto la chiave a GitHub? Continuare con il clone?"; then
    info "Interrompo: aggiungi la chiave e poi rilancia ./install.sh"
    exit 0
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 7. Clone dotfiles
# ─────────────────────────────────────────────────────────────────────────────
step "Repository dotfiles"

DOTDIR="$HOME_DIR/dotfiles"
if [ -d "$DOTDIR/.git" ]; then
  info "dotfiles già presente, aggiorno..."
  git -C "$DOTDIR" pull --rebase || warn "pull fallito (continuo comunque)"
else
  info "Clono dotfiles in $DOTDIR ..."
  git clone "$DOTFILES_REPO" "$DOTDIR"
  ok "dotfiles clonato"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 8. Clone Neovim (repo separata, annidata in dotfiles/.config/nvim)
# ─────────────────────────────────────────────────────────────────────────────
step "Repository Neovim"

NVIM_DIR="$DOTDIR/.config/nvim"
if [ -d "$NVIM_DIR/.git" ]; then
  skip "Neovim già presente"
else
  # rimuovi eventuale directory vuota lasciata dal clone
  rm -rf "$NVIM_DIR"
  git clone "$NVIM_REPO" "$NVIM_DIR"
  ok "Neovim clonato"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 9. Plugin tmux (TPM + kanagawa-tmux)
# ─────────────────────────────────────────────────────────────────────────────
step "Plugin tmux (TPM)"

TMUX_PLUGIN_DIR="$DOTDIR/.config/tmux/plugins"
mkdir -p "$TMUX_PLUGIN_DIR"

if [ -d "$TMUX_PLUGIN_DIR/tpm/.git" ]; then
  skip "TPM già presente"
else
  rm -rf "$TMUX_PLUGIN_DIR/tpm"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR/tpm"
  ok "TPM clonato"
fi

if [ -d "$TMUX_PLUGIN_DIR/kanagawa-tmux/.git" ]; then
  skip "kanagawa-tmux già presente"
else
  rm -rf "$TMUX_PLUGIN_DIR/kanagawa-tmux"
  git clone --depth 1 https://github.com/obergodmar/kanagawa-tmux "$TMUX_PLUGIN_DIR/kanagawa-tmux"
  ok "kanagawa-tmux clonato"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 10. Stow
# ─────────────────────────────────────────────────────────────────────────────
step "Stow dei dotfiles (symlink)"

cd "$HOME_DIR"
# `stow dotfiles` riproduce esattamente i symlink attuali (~/.zshrc -> dotfiles/.zshrc, ecc.)
stow --target="$HOME_DIR" \
     --ignore='^\.git$' \
     --ignore='^\.gitignore$' \
     --ignore='^install\.sh$' \
     --ignore='^backup\.sh$' \
     --ignore='^README' \
     dotfiles
ok "dotfiles stowati in $HOME_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# 11. Wallpaper
# ─────────────────────────────────────────────────────────────────────────────
step "Wallpaper"

WALL_DIR="$HOME_DIR/Pictures/Wallpapers"
case "$WALL_MODE" in
  1)
    if [ -d "$WALL_DIR/.git" ]; then
      skip "wallpaper già clonati"
    else
      [ -n "${WALL_REPO:-}" ] || { err "Nessun URL fornito per i wallpaper."; }
      if [ -n "${WALL_REPO:-}" ]; then
        mkdir -p "$HOME_DIR/Pictures"
        git clone "$WALL_REPO" "$WALL_DIR"
        ok "wallpaper clonati in $WALL_DIR"
      fi
    fi
    ;;
  2)
    if [ -z "${WALL_SRC:-}" ]; then
      warn "Nessun percorso fornito per i wallpaper: salto."
    elif [ -f "$WALL_SRC" ]; then
      mkdir -p "$HOME_DIR/Pictures"
      info "Estraggo $WALL_SRC ..."
      tar -xf "$WALL_SRC" -C "$HOME_DIR/Pictures"
      ok "wallpaper estratti"
    elif [ -d "$WALL_SRC" ]; then
      mkdir -p "$HOME_DIR/Pictures"
      rsync -a "$WALL_SRC/" "$WALL_DIR/"
      ok "wallpaper copiati"
    else
      err "Percorso wallpaper non valido: $WALL_SRC"
    fi
    ;;
  *)
    skip "wallpaper saltati (li ripristinerai a mano)"
    ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# 12. Profilo Firefox
# ─────────────────────────────────────────────────────────────────────────────
step "Profilo Firefox"

FF_DIR="$HOME_DIR/.config/mozilla/firefox"
case "$FF_MODE" in
  1)
    if [ -z "${FF_SRC:-}" ] || [ ! -f "$FF_SRC" ]; then
      warn "Tarball Firefox non trovato: ${FF_SRC:-<vuoto>} (salto)."
    else
      mkdir -p "$HOME_DIR/.config/mozilla"
      info "Estraggo $FF_SRC ..."
      tar -xzf "$FF_SRC" -C "$HOME_DIR/.config/mozilla"
      ok "profilo Firefox estratto in $FF_DIR"
    fi
    ;;
  2)
    if [ -z "${FF_SRC:-}" ] || [ ! -d "$FF_SRC" ]; then
      warn "Cartella Firefox non trovata: ${FF_SRC:-<vuoto>} (salto)."
    else
      mkdir -p "$HOME_DIR/.config/mozilla"
      rsync -a "$FF_SRC/" "$FF_DIR/"
      ok "profilo Firefox copiato in $FF_DIR"
    fi
    ;;
  *)
    skip "profilo Firefox saltato"
    ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# 13. Tema SDDM "clockwork" (qylock)
# ─────────────────────────────────────────────────────────────────────────────
step "Tema SDDM clockwork (qylock)"

need_sudo
SDDM_THEMES_DIR="/usr/share/sddm/themes"
QLOCK_DIR="$DOTDIR/qylock/themes/clockwork"

if [ -d "$QLOCK_DIR" ]; then
  for variant in orbital tape neo-orbital; do
    if [ -d "$QLOCK_DIR/$variant" ]; then
      info "Installo variante '$variant' ..."
      sudo rm -rf "$SDDM_THEMES_DIR/$variant"
      sudo cp -r "$QLOCK_DIR/$variant" "$SDDM_THEMES_DIR/$variant"
      ok "  $variant -> $SDDM_THEMES_DIR/$variant"
    fi
  done

  # Installa il font Outfit usato dal tema (se non già presente)
  OUTFIT_TTF="$QLOCK_DIR/orbital/font/Outfit-Black.ttf"
  if [ -f "$OUTFIT_TTF" ] && ! fc-list 2>/dev/null | grep -qi outfit; then
    info "Installo il font Outfit..."
    sudo mkdir -p /usr/share/fonts/TTF
    sudo cp "$OUTFIT_TTF" /usr/share/fonts/TTF/Outfit-Black.ttf
    sudo fc-cache -f >/dev/null 2>&1
    ok "font Outfit installato"
  else
    skip "font Outfit già presente (o tema senza font)"
  fi

  # Imposta il tema corrente
  info "Imposto il tema SDDM su '$SDDM_THEME'..."
  sudo mkdir -p /etc/sddm.conf.d
  printf '[Theme]\nCurrent=%s\n' "$SDDM_THEME" | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null
  ok "tema SDDM configurato"
else
  warn "Cartella qylock non trovata in dotfiles ($QLOCK_DIR). Salto il tema SDDM."
fi

# ─────────────────────────────────────────────────────────────────────────────
# 14. Binari custom (ski)
# ─────────────────────────────────────────────────────────────────────────────
step "Binari custom"

# hyprpicker 0.4.7 è già in dotfiles/.local/bin (stowato). Verifica.
if [ -x "$HOME_DIR/.local/bin/hyprpicker" ]; then
  ok "hyprpicker presente (~/.local/bin)"
else
  warn "hyprpicker non trovato in ~/.local/bin: il color picker non funzionerà."
fi

# 'ski' (file manager custom, /usr/local/bin) non è pacchettizzato.
if command -v ski >/dev/null 2>&1; then
  ok "ski presente ($(command -v ski))"
else
  warn "ski NON trovato. È un binario custom (36MB in /usr/local/bin)."
  if [ -n "${SKI_SRC:-}" ] || confirm "Hai un backup di 'ski' da copiare?"; then
    read -r -p "Percorso del binario 'ski': " SKI_SRC
    if [ -f "$SKI_SRC" ]; then
      sudo install -Dm755 "$SKI_SRC" /usr/local/bin/ski
      ok "ski installato in /usr/local/bin"
    else
      err "Percorso non valido: $SKI_SRC"
    fi
  else
    skip "ski saltato (il bind Super+E non aprirà il file manager)"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 15. Noctalia
# ─────────────────────────────────────────────────────────────────────────────
step "Noctalia"

# La config.toml è già stowata in ~/.config/noctalia. Se l'username cambia,
# correggi i percorsi hardcoded /home/andrea.
NOCT_CFG="$HOME_DIR/.config/noctalia/config.toml"
if [ -f "$NOCT_CFG" ]; then
  if [ "$USERNAME" != "andrea" ] && grep -q '/home/andrea' "$NOCT_CFG"; then
    info "Aggiorno i percorsi /home/andrea -> /home/$USERNAME ..."
    sed -i "s#/home/andrea#/home/$USERNAME#g" "$NOCT_CFG"
    ok "percorsi aggiornati"
  fi
  if command -v noctalia >/dev/null 2>&1; then
    noctalia config validate 2>&1 | sed 's/^/  /' || true
  fi
  ok "config noctalia pronta"
else
  warn "config noctalia non trovata in $NOCT_CFG"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 16. opencode
# ─────────────────────────────────────────────────────────────────────────────
step "opencode"

# pacchetto già installato in fase 3. La config (cli.json) è stowata.
# service.json (contiene un segreto) NON è in dotfiles: va ricreato al primo avvio.
if command -v opencode >/dev/null 2>&1; then
  ok "opencode $(opencode --version 2>/dev/null || echo '') presente"
else
  warn "opencode non trovato (installalo con: pacman -S opencode)"
fi
if [ -f "$HOME_DIR/.config/opencode/cli.json" ]; then
  ok "config opencode stowata (cli.json)"
fi
warn "service.json (secret) escluso dal repo: opencode lo rigenera al primo avvio."

# ─────────────────────────────────────────────────────────────────────────────
# 17. Shell di default + SDDM
# ─────────────────────────────────────────────────────────────────────────────
step "Finalizzazione"

if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
  if confirm "Impostare zsh come shell di default?"; then
    chsh -s /usr/bin/zsh "$USERNAME"
    ok "shell di default -> zsh"
  fi
else
  skip "zsh è già la shell di default"
fi

if systemctl --quiet is-enabled sddm 2>/dev/null; then
  skip "SDDM già abilitato"
else
  if confirm "Abilitare SDDM (display manager) all'avvio?"; then
    need_sudo
    sudo systemctl enable sddm
    ok "SDDM abilitato"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 18. Riepilogo finale
# ─────────────────────────────────────────────────────────────────────────────
step "Fatto!"
cat <<EOF
${c_green}Installazione completata.${c_reset}

Riepilogo di ciò che è stato configurato:
  • dotfiles          -> stow in $HOME_DIR
  • Neovim            -> $DOTDIR/.config/nvim
  • tmux + TPM        -> $DOTDIR/.config/tmux/plugins
  • Noctalia          -> $NOCT_CFG
  • opencode          -> pacchetto + config (senza secret)
  • SDDM "clockwork"  -> tema '$SDDM_THEME'
  • Wallpaper         -> $WALL_DIR (se richiesti)

Prossimi passi:
  1. Riavvia: ${c_bold}sudo reboot${c_reset}
  2. Al primo avvio di tmux, premi ${c_bold}Ctrl-Space + I${c_reset} per installare
     i plugin TPM (kanagawa-tmux), oppure lancialo una volta e aspetta.
  3. In Neovim i plugin lazy.nvim si installano da soli al primo avvio.
  4. Noctalia leggerà la config al primo login (verifica con 'noctalia config validate').
EOF
