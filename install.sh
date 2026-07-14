#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

echo "==> Wiring up zsh"
touch "$HOME/.zshrc"
SOURCE_LINE="source \"$DOTFILES_DIR/zsh/zshrc.sh\""
grep -qxF "$SOURCE_LINE" "$HOME/.zshrc" || echo "$SOURCE_LINE" >> "$HOME/.zshrc"

echo "==> Wiring up vim"
touch "$HOME/.vimrc"
VIM_SOURCE_LINE="source $DOTFILES_DIR/vim/vimrc.vim"
grep -qxF "$VIM_SOURCE_LINE" "$HOME/.vimrc" || echo "$VIM_SOURCE_LINE" >> "$HOME/.vimrc"

echo "==> Installing fonts"
if [ "$OS" = "Darwin" ]; then
  FONT_DIR="$HOME/Library/Fonts"; FONT_CMD="cp -f"
else
  FONT_DIR="$HOME/.local/share/fonts"; FONT_CMD="ln -sf"
fi
mkdir -p "$FONT_DIR"
for f in "$DOTFILES_DIR"/fonts/*/*.ttf; do
  $FONT_CMD "$f" "$FONT_DIR/$(basename "$f")"
done
command -v fc-cache >/dev/null && fc-cache -f "$FONT_DIR" >/dev/null

echo "==> Installing packages"
command -v sudo >/dev/null && sudo -v || export NO_SUDO=1
for f in "$DOTFILES_DIR"/packages/*.sh; do
  # scripts that reference NO_SUDO handle the no-root case themselves
  if [ -n "${NO_SUDO:-}" ] && grep -qw sudo "$f" && ! grep -qw NO_SUDO "$f"; then
    echo "==> Skipping $(basename "$f") (needs sudo)"
    continue
  fi
  echo "==> Running $(basename "$f")"
  bash "$f"
done

echo "==> Done"
