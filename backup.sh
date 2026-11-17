#!/usr/bin/env bash
#
# backup.sh — Prepara il backup da portare sul nuovo PC.
#
# Raccoglie ciò che NON sta in git (o che vive fuori da dotfiles):
#   1) committa i cambi nel repo dotfiles (opzionale)
#   2) wallpaper -> repo git dedicato O tarball
#   3) binario custom 'ski' (/usr/local/bin/ski)
#
# Uso:
#   ./backup.sh

set -euo pipefail

c_reset=$'\e[0m'; c_bold=$'\e[1m'; c_cyan=$'\e[36m'
c_yellow=$'\e[33m'; c_green=$'\e[32m'; c_red=$'\e[31m'

info() { printf "${c_cyan}==>${c_reset} %s\n" "$*"; }
ok()   { printf "${c_green}  ✔${c_reset} %s\n" "$*"; }
warn() { printf "${c_yellow}  ! %s${c_reset}\n" "$*"; }

confirm() {
  local msg="${1:-Continuare?}" ans
  printf "${c_yellow}${c_bold}?${c_reset} %s [Y/n] " "$msg"
  read -r ans
  case "${ans:-y}" in [yY]|[yY][eE][sS]) return 0;; *) return 1;; esac
}

DOTDIR="${1:-$HOME/dotfiles}"
BACKUP_DIR="$HOME/backup-cachyos"
mkdir -p "$BACKUP_DIR"

echo
info "Backup verso: ${c_bold}$BACKUP_DIR${c_reset}"

# ── 1. Commit dotfiles ────────────────────────────────────────────────────────
echo
if [ -d "$DOTDIR/.git" ]; then
  if confirm "Committare i cambi non committati nel repo dotfiles?"; then
    git -C "$DOTDIR" add -A
    git -C "$DOTDIR" status --short
    if confirm "Confermi il commit di queste modifiche?"; then
      git -C "$DOTDIR" commit -m "backup: snapshot pre-reinstall"
      ok "dotfiles committato"
    fi
  fi
  # push opzionale
  if confirm "Fare push di dotfiles sul remote?"; then
    git -C "$DOTDIR" push
    ok "push eseguito"
  fi
else
  warn "repo dotfiles non trovato in $DOTDIR"
fi

# ── 2. Wallpaper ──────────────────────────────────────────────────────────────
echo
WALL_DIR="$HOME/Pictures/Wallpapers"
if [ ! -d "$WALL_DIR" ]; then
  warn "cartella wallpaper non trovata: $WALL_DIR"
else
  SIZE="$(du -sh "$WALL_DIR" | cut -f1)"
  COUNT="$(ls -1 "$WALL_DIR" | wc -l)"
  info "Wallpaper: $COUNT file, $SIZE"

  printf "Come vuoi salvarli?\n"
  printf "  1) Repo git dedicato (clone sul nuovo PC)\n"
  printf "  2) Tarball .tar.gz (copia su chiavetta)\n"
  printf "  3) Salta\n"
  read -r -p "Scelta [1/2/3]: " ans

  case "${ans:-2}" in
    1)
      if [ -d "$WALL_DIR/.git" ]; then
        git -C "$WALL_DIR" add -A
        git -C "$WALL_DIR" commit -m "backup wallpaper" 2>/dev/null || true
      else
        git -C "$WALL_DIR" init
        git -C "$WALL_DIR" add -A
        git -C "$WALL_DIR" commit -m "backup wallpaper"
      fi
      read -r -p "Remote del repo wallpaper (es. git@github.com:you/wallpapers.git): " WALL_REMOTE
      if [ -n "$WALL_REMOTE" ]; then
        git -C "$WALL_DIR" remote add origin "$WALL_REMOTE" 2>/dev/null || git -C "$WALL_DIR" remote set-url origin "$WALL_REMOTE"
        git -C "$WALL_DIR" push -u origin HEAD
        ok "wallpaper pushati su $WALL_REMOTE"
      else
        warn "nessun remote impostato: pushalo tu con 'git -C $WALL_DIR push'"
      fi
      ;;
    2)
      TARBALL="$BACKUP_DIR/wallpapers.tar.gz"
      info "Creo $TARBALL ... (può richiedere un po')"
      tar -czf "$TARBALL" -C "$HOME/Pictures" Wallpapers
      ok "tarball creato: $TARBALL ($(du -sh "$TARBALL" | cut -f1))"
      ;;
    *) skip="1" ;;
  esac
fi

# ── 3. Profilo Firefox ────────────────────────────────────────────────────────
echo
FF_DIR="$HOME/.config/mozilla/firefox"
if [ -d "$FF_DIR" ]; then
  info "Profilo Firefox: $(du -sh "$FF_DIR" | cut -f1) ($FF_DIR)"
  if confirm "Salvare il profilo Firefox in un tarball (escludendo cache/crash)?"; then
    FF_TARBALL="$BACKUP_DIR/firefox-profile.tar.gz"
    info "Creo $FF_TARBALL ... (può richiedere un po')"
    tar -czf "$FF_TARBALL" \
      --exclude='firefox/Crash Reports' \
      --exclude='firefox/Pending Pings' \
      --exclude='firefox/cache2' \
      --exclude='firefox/crashes' \
      --exclude='firefox/minidumps' \
      --exclude='firefox/saved-telemetry-pings' \
      -C "$HOME/.config/mozilla" firefox
    ok "profilo Firefox salvato: $FF_TARBALL ($(du -sh "$FF_TARBALL" | cut -f1))"
    warn "ATTENZIONE: contiene cookie, password ed estensioni. Non pubblicarlo in repo pubbliche."
  fi
else
  warn "profilo Firefox non trovato in $FF_DIR"
fi

# ── 4. Binario custom 'ski' ───────────────────────────────────────────────────
echo
if [ -f /usr/local/bin/ski ]; then
  if confirm "Salvare il binario 'ski' ($(du -h /usr/local/bin/ski | cut -f1))?"; then
    cp /usr/local/bin/ski "$BACKUP_DIR/ski"
    ok "ski copiato in $BACKUP_DIR/ski"
  fi
else
  warn "ski non trovato in /usr/local/bin"
fi

# ── Riepilogo ─────────────────────────────────────────────────────────────────
echo
info "Backup completato in ${c_bold}$BACKUP_DIR${c_reset}"
echo "  Porta sul nuovo PC:"
echo "    - il repo dotfiles (push) e il repo Neovim"
echo "    - il repo/tarball dei wallpaper"
echo "    - $BACKUP_DIR/firefox-profile.tar.gz (se salvato)"
echo "    - $BACKUP_DIR/ski (se salvato)"
