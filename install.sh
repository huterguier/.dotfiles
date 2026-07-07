#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

echo "==> Wiring up zsh"
touch "$HOME/.zshrc"
SOURCE_LINE="source \"$DOTFILES_DIR/zsh/zshrc.sh\""
grep -qxF "$SOURCE_LINE" "$HOME/.zshrc" || echo "$SOURCE_LINE" >> "$HOME/.zshrc"

echo "==> Installing fonts"
if [ "$OS" = "Darwin" ]; then
  FONT_DIR="$HOME/Library/Fonts"
else
  FONT_DIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONT_DIR"
for f in "$DOTFILES_DIR"/fonts/*.ttf; do
  if [ "$OS" = "Darwin" ]; then
    cp -f "$f" "$FONT_DIR/$(basename "$f")"
  else
    ln -sf "$f" "$FONT_DIR/$(basename "$f")"
  fi
done
[ "$OS" != "Darwin" ] && command -v fc-cache >/dev/null && fc-cache -f "$FONT_DIR" >/dev/null

echo "==> Installing packages"
for f in "$DOTFILES_DIR"/packages/*.sh; do
  echo "==> Running $(basename "$f")"
  bash "$f"
done

echo "==> Done"
