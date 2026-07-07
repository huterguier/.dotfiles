#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

clone_if_missing() {
  local name="$1" url="$2"
  local dest="$HOME/.config/$name"
  if [ -d "$dest" ]; then
    echo "==> $name already present, skipping clone"
  else
    echo "==> Cloning $name into $dest"
    git clone "$url" "$dest"
  fi
}

echo "==> Cloning tool configs"
clone_if_missing nvim git@github.com:huterguier/nvim.git
clone_if_missing tmux git@github.com:huterguier/tmux.git
clone_if_missing alacritty git@github.com:huterguier/alacritty.git

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
case "$OS" in
  Darwin)
    if command -v brew >/dev/null; then
      brew bundle --file="$DOTFILES_DIR/packages/Brewfile"
    else
      echo "homebrew not found, skipping Brewfile"
    fi
    ;;
  Linux)
    if [ -s "$DOTFILES_DIR/packages/apt.txt" ]; then
      xargs -a "$DOTFILES_DIR/packages/apt.txt" sudo apt install -y
    fi
    if [ "$SHELL" != "$(command -v zsh)" ]; then
      chsh -s "$(command -v zsh)"
    fi
    ;;
  *)
    echo "Unrecognized OS '$OS', skipping package manager install"
    ;;
esac

if [ -s "$DOTFILES_DIR/packages/custom.sh" ]; then
  bash "$DOTFILES_DIR/packages/custom.sh"
fi

echo "==> Done"
