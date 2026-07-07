#!/usr/bin/env bash
set -euo pipefail

# neovim (>=0.12) — apt/brew can lag or be missing a build for your release,
# so install the official release tarball directly on both platforms
NVIM_INSTALL_DIR="$HOME/.local/share/nvim"

if [ ! -x "$NVIM_INSTALL_DIR/bin/nvim" ]; then
  case "$(uname -s)" in
    Darwin) NVIM_OS="macos" ;;
    Linux)  NVIM_OS="linux" ;;
  esac

  case "$(uname -m)" in
    arm64|aarch64) NVIM_ARCH="arm64" ;;
    x86_64)        NVIM_ARCH="x86_64" ;;
  esac

  echo "==> Installing neovim (nvim-${NVIM_OS}-${NVIM_ARCH})"
  curl -sL "https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_OS}-${NVIM_ARCH}.tar.gz" -o /tmp/nvim.tar.gz
  mkdir -p "$NVIM_INSTALL_DIR"
  tar -xzf /tmp/nvim.tar.gz -C "$NVIM_INSTALL_DIR" --strip-components=1
  rm /tmp/nvim.tar.gz
fi

NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_CONFIG_DIR" ]; then
  echo "==> Cloning nvim config into $NVIM_CONFIG_DIR"
  git clone git@github.com:huterguier/nvim.git "$NVIM_CONFIG_DIR"
fi
