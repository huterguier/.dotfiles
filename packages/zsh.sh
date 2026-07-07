#!/usr/bin/env bash
set -euo pipefail

if ! command -v zsh >/dev/null; then
  case "$(uname -s)" in
    Darwin) brew install zsh ;;
    Linux)  sudo apt install -y zsh ;;
  esac
fi

if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
fi
